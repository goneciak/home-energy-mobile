import 'dart:async';
import 'dart:collection';

import 'package:gi_edge_sim/src/config.dart';
import 'package:gi_edge_sim/src/device_model.dart';
import 'package:gi_edge_sim/src/edge_client.dart';
import 'package:gi_edge_sim/src/identity_store.dart';

/// Failure injection. Everything resets with `{"mode": "normal"}`.
class Scenario {
  /// `offline`: no push at all, `stale_heartbeat`: telemetry and poll go on but
  /// the heartbeat stops, so `lastSeenAt` moves while the diagnostics freeze.
  bool offline = false;
  bool staleHeartbeat = false;

  /// `no_ack`: commands are executed but the ack never reaches Core.
  bool noAck = false;

  /// `ack_failed`: commands are not executed, the ack says FAILED with this.
  String? ackFailedError;
  Duration ackLatency = Duration.zero;
  Duration commandLatency = Duration.zero;
  int clockSkewSeconds = 0;

  Map<String, Object?> toJson() => {
    'offline': offline,
    'staleHeartbeat': staleHeartbeat,
    'noAck': noAck,
    'ackFailedError': ackFailedError,
    'ackLatencyMs': ackLatency.inMilliseconds,
    'commandLatencyMs': commandLatency.inMilliseconds,
    'clockSkewSeconds': clockSkewSeconds,
  };
}

/// One polled command and what the device did with it.
class CommandRecord {
  new({
    required this.at,
    required this.correlationId,
    required this.type,
    required this.entityKey,
    required this.outcome,
    this.error,
    this.ackStatus,
  });

  final DateTime at;
  final String correlationId;
  final String type;
  final Object? entityKey;

  /// `ACCEPTED`, `FAILED` or `NOT_EXECUTED`.
  final String outcome;
  final String? error;

  /// Core's HTTP status for the ack, `null` when no ack was sent.
  final int? ackStatus;

  Map<String, Object?> toJson() => {
    'at': at.toUtc().toIso8601String(),
    'correlationId': correlationId,
    'type': type,
    'entityKey': entityKey,
    'outcome': outcome,
    if (error != null) 'error': error,
    'ackStatus': ackStatus,
  };
}

class ActivationResult {
  const new({required this.ok, this.deviceId, this.message});

  final bool ok;
  final String? deviceId;
  final String? message;

  Map<String, Object?> toJson() => {
    'ok': ok,
    'deviceId': deviceId,
    'message': message,
  };
}

/// The simulated controller: owns the model, pushes to Core and answers its
/// commands. Loops are plain timers around methods that tests call directly.
class Simulator {
  new({
    required this.config,
    required this.identity,
    DateTime Function()? clock,
    this.log,
  }) : _clock = clock ?? DateTime.now {
    model = DeviceModel(config: config);
    identity.bootCount++;
    identity.save();
    client = EdgeClient(
      identity: identity,
      coreUrl: () => _coreUrl,
      deviceClock: deviceNow,
      timeout: config.requestTimeout,
      onPush: _recordPush,
    );
  }

  final SimConfig config;
  final IdentityStore identity;
  final void Function(String message)? log;
  final DateTime Function() _clock;

  late final DeviceModel model;
  late final EdgeClient client;
  final Scenario scenario = Scenario();
  final Queue<PushRecord> pushes = Queue();
  final Queue<CommandRecord> commands = Queue();
  final Set<String> _busy = {};
  Timer? _tickTimer;
  Timer? _heartbeatTimer;
  Timer? _telemetryTimer;
  Timer? _pollTimer;
  String? _activatedCoreUrl;
  int _consecutive401 = 0;
  DateTime _nextSelfHeal = DateTime.fromMillisecondsSinceEpoch(0);
  int unauthorizedCount = 0;
  ActivationResult? lastActivation;

  String get _coreUrl =>
      config.coreUrl ?? _activatedCoreUrl ?? 'http://localhost:3000';

  DateTime deviceNow() =>
      _clock().add(Duration(seconds: scenario.clockSkewSeconds));

  bool get provisioned => identity.provisioned;

  // ---------------------------------------------------------------- loops

  void start() {
    _tickTimer = Timer.periodic(config.tickInterval, (_) => tick());
    _heartbeatTimer = Timer.periodic(
      config.heartbeatInterval,
      (_) => unawaited(sendHeartbeat()),
    );
    _telemetryTimer = Timer.periodic(
      config.telemetryInterval,
      (_) => unawaited(sendTelemetry()),
    );
    _pollTimer = Timer.periodic(
      config.pollInterval,
      (_) => unawaited(pollCommands()),
    );
  }

  void stop() {
    for (final timer in [
      _tickTimer,
      _heartbeatTimer,
      _telemetryTimer,
      _pollTimer,
    ]) {
      timer?.cancel();
    }
  }

  /// One sensor read; also drives the self-heal retry.
  void tick() {
    model.tick(config.tickInterval.inMilliseconds / 1000);
    if (!provisioned &&
        identity.selfHealArmed &&
        !scenario.offline &&
        !_clock().isBefore(_nextSelfHeal)) {
      _nextSelfHeal = _clock().add(config.selfHealRetry);
      unawaited(selfHeal());
    }
  }

  bool get _silent => scenario.offline || !provisioned;

  Future<T?> _exclusive<T>(String key, Future<T> Function() body) async {
    if (!_busy.add(key)) return null;
    try {
      return await body();
    } finally {
      _busy.remove(key);
    }
  }

  // ---------------------------------------------------------------- pushes

  Map<String, Object?> _envelope(int sequence) => {
    'schemaVersion': '1.1.0',
    'deviceId': identity.deviceId,
    'firmwareVersion': '0.1.0',
    'buildVersion': 'sim-0.1.0',
    'hardwareRevision': 'gi-controller-2ch',
    'uptimeMs': (model.uptimeSeconds * 1000).round(),
    'timestamp': deviceNow().toUtc().toIso8601String(),
    'clockSynced': true,
    'sequence': sequence,
    'freeHeap': 182340 - (sequence % 17) * 64,
    'minimumFreeHeap': 151200,
    'wifi': {
      'connected': true,
      'rssi': -80 - (sequence % 13),
      'ip': config.ip,
      'reconnectCount': 0,
    },
    'bootCount': identity.bootCount,
    'resetReason': model.resetReason,
    'rebootLoopDetected': false,
    'brownoutResetCount': 0,
    'recentResetStreak': 0,
  };

  Future<CoreResponse?> sendHeartbeat() async {
    if (_silent || scenario.staleHeartbeat) return null;
    return await _exclusive('heartbeat', () async {
      final response = await client.signedPost('/edge/heartbeat', (sequence) {
        return {..._envelope(sequence), ...model.diagnosticsFragment()};
      }, kind: 'heartbeat');
      _afterPush(response);
      return response;
    });
  }

  Future<CoreResponse?> sendTelemetry() async {
    if (_silent) return null;
    return await _exclusive('telemetry', () async {
      final response = await client.signedPost('/edge/telemetry', (sequence) {
        return {
          'readings': [
            {
              'entityKey': 'device_uptime',
              'unit': 's',
              'value': model.uptimeSeconds.round(),
            },
          ],
          ..._envelope(sequence),
          ...model.diagnosticsFragment(),
        };
      }, kind: 'telemetry');
      _afterPush(response);
      return response;
    });
  }

  /// One command poll: adopts dryRun/strategy/relay key, runs every command
  /// that came back and acknowledges it.
  Future<CoreResponse?> pollCommands() async {
    if (_silent) return null;
    return await _exclusive('poll', () async {
      final response = await client.signedPost(
        '/edge/commands/poll',
        (_) => <String, Object?>{},
        kind: 'poll',
      );
      _afterPush(response);
      if (!response.ok) return response;
      final data = response.dataMap;
      model.adoptPoll(data);
      final list = data['commands'];
      if (list is List<Object?>) {
        for (final item in list) {
          if (item is Map<String, Object?>) await _process(item);
        }
      }
      return response;
    });
  }

  Future<void> _process(Map<String, Object?> command) async {
    final correlationId = '${command['correlationId']}';
    final payload = command['payload'];
    final entityKey = payload is Map<String, Object?>
        ? payload['entityKey']
        : null;
    if (scenario.commandLatency > Duration.zero) {
      await Future<void>.delayed(scenario.commandLatency);
    }
    final injected = scenario.ackFailedError;
    final ack = injected == null
        ? model.handleCommand(command, now: deviceNow())
        : CommandAck.failed(injected);
    final executed = injected == null;
    int? ackStatus;
    if (scenario.noAck) {
      log?.call('command $correlationId executed, ack withheld (no_ack)');
    } else {
      if (scenario.ackLatency > Duration.zero) {
        await Future<void>.delayed(scenario.ackLatency);
      }
      final response = await client.signedPost(
        '/edge/commands/ack',
        (_) => ack.toBody(correlationId),
        kind: 'ack',
      );
      _afterPush(response);
      ackStatus = response.status;
    }
    commands.addFirst(
      CommandRecord(
        at: _clock(),
        correlationId: correlationId,
        type: '${command['type']}',
        entityKey: entityKey,
        outcome: executed ? ack.state : 'NOT_EXECUTED',
        error: ack.error,
        ackStatus: ackStatus,
      ),
    );
    while (commands.length > 50) {
      commands.removeLast();
    }
  }

  void _recordPush(PushRecord record) {
    pushes.addFirst(record);
    while (pushes.length > 50) {
      pushes.removeLast();
    }
  }

  /// Three 401 answers in a row (after the boot grace) wipe the credential
  /// and reboot, then the device tries to self-heal with its MAC.
  void _afterPush(CoreResponse response) {
    if (response.status == 401) {
      unauthorizedCount++;
      final pastGrace =
          model.uptimeSeconds >= config.bootGrace.inMilliseconds / 1000;
      if (pastGrace) _consecutive401++;
      log?.call('401 ${response.code ?? ''} (${_consecutive401}x)');
      if (_consecutive401 >= 3) {
        log?.call('3 consecutive 401: wiping credential, rebooting');
        _consecutive401 = 0;
        identity.wipeCredential();
        client.corruptSecret = false;
        _nextSelfHeal = _clock();
        reboot();
      }
    } else if (response.ok) {
      _consecutive401 = 0;
    }
  }

  // --------------------------------------------------------- provisioning

  /// `POST /gi-provision` (or `/fake/activate`): exchange the one-time token
  /// for the shared secret and adopt the identity Core returns.
  Future<ActivationResult> activate({
    required String deviceId,
    required String activationToken,
    String? coreUrl,
  }) async {
    _activatedCoreUrl = coreUrl;
    final response = await client.unsignedPost('/edge/activate', {
      'deviceId': deviceId,
      'activationToken': activationToken,
      'physicalMac': config.physicalMac,
    }, kind: 'activate');
    final data = response.dataMap;
    final secret = data['sharedSecret'];
    final adopted = data['deviceId'];
    final result = response.ok && secret is String && adopted is String
        ? ActivationResult(ok: true, deviceId: adopted)
        : ActivationResult(
            ok: false,
            message: '${response.status} ${response.code ?? response.message}',
          );
    if (result.ok) {
      identity.adopt(
        deviceId: adopted! as String,
        sharedSecret: secret! as String,
      );
      _consecutive401 = 0;
      model.heatingRelayEntityKey = null;
    }
    lastActivation = result;
    log?.call('activation: ${result.ok ? 'ok' : result.message}');
    return result;
  }

  Future<ActivationResult> selfHeal() async {
    final response = await client.unsignedPost('/edge/self-heal', {
      'physicalMac': config.physicalMac,
    }, kind: 'self-heal');
    final data = response.dataMap;
    final secret = data['sharedSecret'];
    final adopted = data['deviceId'];
    if (response.ok && secret is String && adopted is String) {
      identity.adopt(deviceId: adopted, sharedSecret: secret);
      log?.call('self-heal ok');
      return ActivationResult(ok: true, deviceId: adopted);
    }
    log?.call('self-heal failed: ${response.status} ${response.code}');
    return ActivationResult(
      ok: false,
      message: '${response.status} ${response.code ?? response.message}',
    );
  }

  // ------------------------------------------------------------ scenarios

  /// A power cycle: RAM state is lost, identity and sequence persist.
  void reboot() {
    identity.bootCount++;
    identity.save();
    model.reboot();
    _consecutive401 = 0;
  }

  void resetScenario() {
    scenario
      ..offline = false
      ..staleHeartbeat = false
      ..noAck = false
      ..ackFailedError = null
      ..ackLatency = Duration.zero
      ..commandLatency = Duration.zero
      ..clockSkewSeconds = 0;
    client.corruptSecret = false;
    model
      ..injectedSupplyStatus = null
      ..injectedReturnStatus = null
      ..releaseSafeMode()
      ..clearFaults();
  }

  /// Applies one `POST /fake/scenario` body. Throws [FormatException] for an
  /// unknown mode or a missing parameter.
  void applyScenario(Map<String, Object?> json) {
    final mode = json['mode'];
    switch (mode) {
      case 'normal':
        resetScenario();
      case 'no_ack':
        scenario.noAck = true;
      case 'ack_failed':
        scenario.ackFailedError =
            (json['error'] as String?) ?? 'rejected by local safety policy';
      case 'offline':
        scenario.offline = true;
      case 'stale_heartbeat':
        scenario.staleHeartbeat = true;
      case 'sensor_invalid':
        final status = (json['status'] as String?) ?? 'TIMEOUT';
        final which = (json['sensor'] as String?) ?? 'both';
        if (which != 'return') model.injectedSupplyStatus = status;
        if (which != 'supply') model.injectedReturnStatus = status;
      case 'fault':
        final code = json['code'];
        if (code is! String) throw const FormatException('fault needs "code"');
        model.raiseFault(code);
      case 'safe_mode':
        model.forceSafeMode();
      case 'dry_run':
        final enabled = json['enabled'];
        if (enabled is! bool) {
          throw const FormatException('dry_run needs "enabled": true|false');
        }
        model.setDryRun(enabled: enabled);
      case 'clock_skew':
        final seconds = json['seconds'];
        if (seconds is! num) {
          throw const FormatException('clock_skew needs "seconds"');
        }
        scenario.clockSkewSeconds = seconds.toInt();
      case 'revoke':
        client.corruptSecret = true;
      case 'reboot':
        reboot();
      case 'ack_latency_ms':
        scenario.ackLatency = Duration(milliseconds: _ms(json));
      case 'command_latency_ms':
        scenario.commandLatency = Duration(milliseconds: _ms(json));
      default:
        throw FormatException('unknown mode: $mode');
    }
  }

  int _ms(Map<String, Object?> json) {
    final value = json['ms'];
    if (value is! num || value < 0) {
      throw const FormatException('needs "ms" >= 0');
    }
    return value.toInt();
  }

  /// `POST /fake/reset`: back to a blank, unprovisioned device.
  void factoryReset() {
    resetScenario();
    identity.factoryReset();
    reboot();
    pushes.clear();
    commands.clear();
    lastActivation = null;
    unauthorizedCount = 0;
  }

  Map<String, Object?> debugState() => {
    'provisioned': provisioned,
    'deviceId': identity.deviceId,
    'physicalMac': config.physicalMac,
    'coreUrl': _coreUrl,
    'sequence': identity.sequence,
    'bootCount': identity.bootCount,
    'selfHealArmed': identity.selfHealArmed,
    'unauthorizedCount': unauthorizedCount,
    'lastActivation': lastActivation?.toJson(),
    'scenario': scenario.toJson(),
    'device': model.debug(),
    'commands': commands.map((c) => c.toJson()).toList(),
    'pushes': pushes.map((p) => p.toJson()).toList(),
  };
}
