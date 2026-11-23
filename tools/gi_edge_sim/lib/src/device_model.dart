import 'dart:math';

import 'package:gi_edge_sim/src/config.dart';

/// The firmware's device states (`DeviceState` in energy_controller).
enum DeviceState {
  boot('BOOT'),
  selfTest('SELF_TEST'),
  ready('READY'),
  idle('IDLE'),
  heatingRequested('HEATING_REQUESTED'),
  heatingVerifying('HEATING_VERIFYING'),
  heating('HEATING'),
  stopping('STOPPING'),
  fault('FAULT'),
  safeMode('SAFE_MODE');

  new(this.wire);
  final String wire;

  bool get isHeating =>
      this == heatingRequested || this == heatingVerifying || this == heating;
}

/// One relay: `commanded` is the intent, `output` the driven pin. In dry-run
/// the output stays low whatever is commanded.
class RelayState {
  bool commanded = false;
  bool output = false;
}

/// The device's answer to a command: the firmware only ever sends ACCEPTED or
/// FAILED (success is ACCEPTED, which stays non-terminal in Core).
class CommandAck {
  const new accepted(this.resultingState) : state = 'ACCEPTED', error = null;
  const new failed(String this.error) : state = 'FAILED', resultingState = null;

  final String state;
  final String? resultingState;
  final String? error;

  Map<String, Object?> toBody(String correlationId) => {
    'correlationId': correlationId,
    'state': state,
    if (resultingState != null) 'result': {'resultingState': resultingState},
    if (error != null) 'error': error,
  };
}

/// Behaviour of the controller: state machine, relays, sensors, faults and a
/// simple thermal plant. Pure and clock-free: time only advances through
/// [tick], so tests are deterministic.
class DeviceModel {
  new({required this.config, Random? random}) : _random = random ?? Random(7) {
    reboot(resetReason: 'POWERON');
  }

  final SimConfig config;
  final Random _random;

  static const _supplyRom = '0x1c0000b5a1c42128';
  static const _returnRom = '0x7a0000b5a1d82a28';
  static const _requiredSupplyRise = 3.0;
  static const _requiredReturnRise = 1.5;
  static const _requiredDelta = 4.0;

  double uptimeSeconds = 0;
  DeviceState state = DeviceState.boot;
  DeviceState previousState = DeviceState.boot;
  double stateSinceSeconds = 0;
  String resetReason = 'POWERON';

  /// The firmware default until Core pushes `dryRun:false` with a poll.
  bool dryRun = true;
  final RelayState relay1 = RelayState();
  final RelayState relay2 = RelayState();

  double supply = 45.5;
  double returnTemp = 38;
  String supplyStatus = 'VALID';
  String returnStatus = 'VALID';
  double _supplySinceValid = 0;
  double _returnSinceValid = 0;
  int _supplyValidReads = 0;
  int _returnValidReads = 0;

  /// Injected by the scenario endpoint; a sensor that is not VALID.
  String? injectedSupplyStatus;
  String? injectedReturnStatus;

  /// Forced by the scenario endpoint: the controller sits in SAFE_MODE.
  bool forcedSafeMode = false;

  final Set<String> activeFaults = {};
  final Set<String> latchedFaults = {};

  bool verificationConfirmed = false;
  bool verificationLost = false;
  bool verificationFailed = false;
  double _supplyAtStart = 0;
  double _returnAtStart = 0;
  double _verificationStartedAt = 0;
  double _stoppingStartedAt = 0;

  /// Set by every poll; `null` until the first one (then relay_2 is not yet
  /// known as the heating relay).
  String? heatingRelayEntityKey;
  int strategyVersion = 0;
  double strategyTarget = 60;
  double strategyHysteresis = 2;
  String strategyMode = 'OFF';

  final Map<String, CommandAck> _seen = {};

  bool get safetyInterlockActive =>
      state == DeviceState.fault ||
      state == DeviceState.safeMode ||
      latchedFaults.isNotEmpty;

  bool get sensorsReady =>
      _supplyValidReads >= config.requiredValidReads &&
      _returnValidReads >= config.requiredValidReads;

  /// Simulates a power cycle or reset: RAM state is lost, the NVS content (the
  /// identity store) is not the model's business.
  void reboot({String resetReason = 'SOFTWARE'}) {
    this.resetReason = resetReason;
    uptimeSeconds = 0;
    state = DeviceState.boot;
    previousState = DeviceState.boot;
    stateSinceSeconds = 0;
    dryRun = true;
    for (final relay in [relay1, relay2]) {
      relay
        ..commanded = false
        ..output = false;
    }
    activeFaults.clear();
    latchedFaults.clear();
    _resetVerification();
    _seen.clear();
    _supplyValidReads = 0;
    _returnValidReads = 0;
    heatingRelayEntityKey = null;
    strategyMode = 'OFF';
  }

  // ---------------------------------------------------------------- ticking

  /// Advances the simulated world by [seconds] (one sensor read).
  void tick(double seconds) {
    uptimeSeconds += seconds;
    _simulatePlant(seconds);
    _readSensors(seconds);
    switch (state) {
      case DeviceState.boot:
        _enter(DeviceState.selfTest);
      case DeviceState.selfTest:
        _enter(DeviceState.ready);
      case DeviceState.ready:
        _enter(forcedSafeMode ? DeviceState.safeMode : DeviceState.idle);
      case DeviceState.idle:
        if (forcedSafeMode) _enter(DeviceState.safeMode);
      case DeviceState.heatingRequested:
        _setRelays(on: true);
        _startVerification();
        _enter(DeviceState.heatingVerifying);
      case DeviceState.heatingVerifying:
        _verify();
      case DeviceState.heating:
        _watchHeating();
      case DeviceState.stopping:
        if (uptimeSeconds - _stoppingStartedAt >=
            config.stoppingDuration.inMilliseconds / 1000) {
          _enter(DeviceState.idle);
        }
      case DeviceState.fault:
        _setRelays(on: false);
      case DeviceState.safeMode:
        _setRelays(on: false);
        if (!forcedSafeMode) _enter(DeviceState.idle);
    }
    _syncSensorFaults();
  }

  void _enter(DeviceState next) {
    if (next == state) return;
    previousState = state;
    state = next;
    stateSinceSeconds = uptimeSeconds;
  }

  void _simulatePlant(double seconds) {
    final speed = config.thermalSpeed;
    final boilerHeating = relay2.output;
    final supplyTarget = boilerHeating ? 72.0 : 24.0;
    final supplyRate = (boilerHeating ? 0.02 : 0.004) * speed;
    supply += (supplyTarget - supply) * (1 - exp(-supplyRate * seconds));
    final returnTarget = boilerHeating ? supply - 6 : 23.0;
    final returnRate = (boilerHeating ? 0.015 : 0.004) * speed;
    returnTemp +=
        (returnTarget - returnTemp) * (1 - exp(-returnRate * seconds));
    if (config.noise > 0) {
      supply += (_random.nextDouble() - 0.5) * 2 * config.noise;
      returnTemp += (_random.nextDouble() - 0.5) * 2 * config.noise;
    }
  }

  void _readSensors(double seconds) {
    supplyStatus = injectedSupplyStatus ?? 'VALID';
    returnStatus = injectedReturnStatus ?? 'VALID';
    if (supplyStatus == 'VALID') {
      _supplyValidReads++;
      _supplySinceValid = 0;
    } else {
      _supplyValidReads = 0;
      _supplySinceValid += seconds;
    }
    if (returnStatus == 'VALID') {
      _returnValidReads++;
      _returnSinceValid = 0;
    } else {
      _returnValidReads = 0;
      _returnSinceValid += seconds;
    }
  }

  void _syncSensorFaults() {
    void sync(String code, {required bool bad}) {
      if (bad) {
        if (activeFaults.add(code) && state.isHeating) _shutdown();
      } else {
        activeFaults.remove(code);
      }
    }

    sync('SENSOR_SUPPLY_INVALID', bad: supplyStatus != 'VALID');
    sync('SENSOR_RETURN_INVALID', bad: returnStatus != 'VALID');
  }

  // ----------------------------------------------------------- heating flow

  void _startVerification() {
    _resetVerification();
    _supplyAtStart = supply;
    _returnAtStart = returnTemp;
    _verificationStartedAt = uptimeSeconds;
  }

  void _resetVerification() {
    verificationConfirmed = false;
    verificationLost = false;
    verificationFailed = false;
    _supplyAtStart = 0;
    _returnAtStart = 0;
    _verificationStartedAt = 0;
  }

  double get _supplyRise => supply - _supplyAtStart;
  double get _returnRise => returnTemp - _returnAtStart;
  bool get supplyRiseMet => _supplyRise >= _requiredSupplyRise;
  bool get returnRiseMet => _returnRise >= _requiredReturnRise;
  bool get meaningfulDeltaPresent => supply - returnTemp >= _requiredDelta;

  void _verify() {
    if (supplyRiseMet && returnRiseMet && meaningfulDeltaPresent) {
      verificationConfirmed = true;
      _enter(DeviceState.heating);
      return;
    }
    final elapsed = uptimeSeconds - _verificationStartedAt;
    if (elapsed >= config.verificationWindow.inMilliseconds / 1000) {
      verificationFailed = true;
      raiseFault('HEATING_EFFECT_NOT_CONFIRMED');
    }
  }

  void _watchHeating() {
    if (supply > 85) {
      raiseFault('MAX_PIPE_TEMPERATURE_EXCEEDED');
    } else if (!relay2.output && !dryRun) {
      verificationLost = true;
      raiseFault('HEATING_EFFECT_LOST');
    }
  }

  void _setRelays({required bool on}) {
    for (final relay in [relay1, relay2]) {
      relay
        ..commanded = on
        ..output = on && !dryRun;
    }
  }

  void _shutdown() {
    _setRelays(on: false);
    _enter(DeviceState.fault);
  }

  /// Latches a fault; faults that need a shutdown force relays off.
  void raiseFault(String code) {
    activeFaults.add(code);
    latchedFaults.add(code);
    if (state != DeviceState.safeMode) _shutdown();
  }

  /// Puts the controller into SAFE_MODE (relays off) until [releaseSafeMode].
  void forceSafeMode() {
    forcedSafeMode = true;
    _setRelays(on: false);
    _enter(DeviceState.safeMode);
  }

  void releaseSafeMode() => forcedSafeMode = false;

  /// The manual fault reset (and what a reboot or the `normal` scenario do).
  void clearFaults() {
    activeFaults.clear();
    latchedFaults.clear();
    verificationFailed = false;
    verificationLost = false;
    if (state == DeviceState.fault) _enter(DeviceState.idle);
  }

  void setDryRun({required bool enabled}) {
    dryRun = enabled;
    for (final relay in [relay1, relay2]) {
      relay.output = relay.commanded && !enabled;
    }
  }

  /// `request_heating` of the firmware: stop always succeeds, start only from
  /// IDLE with enough consecutive valid sensor reads.
  bool requestHeating({required bool on}) {
    if (!on) {
      if (state.isHeating) {
        _stop();
      }
      return true;
    }
    if (state != DeviceState.idle || !sensorsReady) return false;
    _enter(DeviceState.heatingRequested);
    return true;
  }

  void _stop() {
    _setRelays(on: false);
    _stoppingStartedAt = uptimeSeconds;
    _enter(DeviceState.stopping);
  }

  // ---------------------------------------------------------------- commands

  /// Applies one polled command and returns the ack the firmware would send.
  CommandAck handleCommand(
    Map<String, Object?> command, {
    required DateTime now,
  }) {
    final correlationId = '${command['correlationId']}';
    final type = '${command['type']}';
    final expiresAt = DateTime.tryParse('${command['expiresAt']}');
    if (expiresAt != null && expiresAt.isBefore(now)) {
      return const CommandAck.failed('expired before processing');
    }
    switch (type) {
      case 'TURN_ON' || 'TURN_OFF':
        final previous = _seen[correlationId];
        if (previous != null) {
          return previous.state == 'FAILED'
              ? CommandAck.failed(
                  'duplicate of correlationId $correlationId: ${previous.error}',
                )
              : CommandAck.accepted(state.wire);
        }
        final payload = command['payload'];
        final key = payload is Map<String, Object?>
            ? payload['entityKey']
            : null;
        final CommandAck ack;
        if (key == null || key != heatingRelayEntityKey) {
          ack = const CommandAck.failed(
            'entity not permitted for remote control',
          );
        } else if (!requestHeating(on: type == 'TURN_ON')) {
          ack = const CommandAck.failed('rejected by local safety policy');
        } else {
          ack = CommandAck.accepted(state.wire);
        }
        _seen[correlationId] = ack;
        return ack;
      case 'SET_DRY_RUN':
        final payload = command['payload'];
        final enabled = payload is Map<String, Object?>
            ? payload['enabled']
            : null;
        if (enabled is! bool) {
          return const CommandAck.failed('invalid payload');
        }
        setDryRun(enabled: enabled);
        return CommandAck.accepted(state.wire);
      default:
        return const CommandAck.failed(
          'unsupported command type for this device',
        );
    }
  }

  /// Adopts what every poll response pushes live.
  void adoptPoll(Map<String, Object?> data) {
    final dry = data['dryRun'];
    if (dry is bool) setDryRun(enabled: dry);
    heatingRelayEntityKey = data['heatingRelayEntityKey'] as String?;
    final strategy = data['controlStrategy'];
    if (strategy is Map<String, Object?>) {
      strategyVersion = (strategy['version'] as num?)?.toInt() ?? 0;
      strategyTarget =
          (strategy['targetTemperatureCelsius'] as num?)?.toDouble() ??
          strategyTarget;
      strategyHysteresis =
          (strategy['hysteresisCelsius'] as num?)?.toDouble() ??
          strategyHysteresis;
      strategyMode = '${strategy['mode'] ?? strategyMode}';
    }
  }

  // ------------------------------------------------------------ diagnostics

  Map<String, Object?> _sensor(
    double filtered,
    String status,
    double since,
    String rom,
  ) => {
    'raw': status == 'VALID' ? filtered : -127.0,
    'filtered': filtered,
    'status': status,
    'ageMs': (since * 1000).round(),
    'romAddress': rom,
  };

  Map<String, Object?> _relay(RelayState relay, String role) => {
    'commanded': relay.commanded,
    'output': relay.output,
    'physicalConfirmation': 'UNKNOWN',
    'role': role,
  };

  String get _verificationSummary {
    if (verificationFailed) return 'no plausible heating effect';
    if (verificationLost) return 'heating effect lost';
    if (verificationConfirmed) return 'heating effect confirmed';
    if (state == DeviceState.heatingVerifying) return 'verifying';
    return 'not started';
  }

  /// The energy controller part of the heartbeat (`build_diagnostics_json`).
  Map<String, Object?> diagnosticsFragment() {
    final estimateReliable =
        uptimeSeconds >= config.estimateDelay.inMilliseconds / 1000 &&
        supplyStatus == 'VALID';
    return {
      'currentState': state.wire,
      'previousState': previousState.wire,
      'stateSinceMs': (stateSinceSeconds * 1000).round(),
      'dryRun': dryRun,
      'supplyTemperature': _sensor(
        supply,
        supplyStatus,
        _supplySinceValid,
        _supplyRom,
      ),
      'returnTemperature': _sensor(
        returnTemp,
        returnStatus,
        _returnSinceValid,
        _returnRom,
      ),
      if (estimateReliable) 'boilerTemperatureEstimate': supply - 1.5,
      'relay1': _relay(relay1, 'pump'),
      'relay2': _relay(relay2, 'boiler'),
      'heatingVerification': {
        'confirmed': verificationConfirmed,
        'lost': verificationLost,
        'failed': verificationFailed,
        'supplyRiseMet': supplyRiseMet && state.isHeating,
        'returnRiseMet': returnRiseMet && state.isHeating,
        'meaningfulDeltaPresent': meaningfulDeltaPresent,
        'summary': _verificationSummary,
      },
      'activeFaults': activeFaults.toList(),
      'latchedFaults': latchedFaults.toList(),
      'safetyInterlockActive': safetyInterlockActive,
      'controlStrategy': {
        'version': strategyVersion,
        'targetCelsius': strategyTarget,
        'hysteresisCelsius': strategyHysteresis,
        'mode': strategyMode,
      },
    };
  }

  Map<String, Object?> debug() => {
    'state': state.wire,
    'previousState': previousState.wire,
    'uptimeSeconds': uptimeSeconds.round(),
    'dryRun': dryRun,
    'supply': supply,
    'return': returnTemp,
    'supplyStatus': supplyStatus,
    'returnStatus': returnStatus,
    'relay1': {'commanded': relay1.commanded, 'output': relay1.output},
    'relay2': {'commanded': relay2.commanded, 'output': relay2.output},
    'activeFaults': activeFaults.toList(),
    'latchedFaults': latchedFaults.toList(),
    'heatingRelayEntityKey': heatingRelayEntityKey,
    'strategyMode': strategyMode,
  };
}
