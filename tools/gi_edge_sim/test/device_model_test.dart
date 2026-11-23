import 'package:gi_edge_sim/gi_edge_sim.dart';
import 'package:test/test.dart';

const _config = SimConfig(noise: 0, estimateDelay: Duration(seconds: 30));

Map<String, Object?> _command(
  String type, {
  String key = 'relay_2',
  String id = 'c1',
  DateTime? expires,
}) => {
  'correlationId': id,
  'type': type,
  'payload': {'entityKey': key},
  'expiresAt': (expires ?? DateTime.now().add(const Duration(seconds: 30)))
      .toUtc()
      .toIso8601String(),
};

DeviceModel _idleModel({bool dryRun = false}) {
  final model = DeviceModel(config: _config);
  for (var i = 0; i < 8; i++) {
    model.tick(1);
  }
  model.adoptPoll({'dryRun': dryRun, 'heatingRelayEntityKey': 'relay_2'});
  return model;
}

void _run(DeviceModel model, int seconds) {
  for (var i = 0; i < seconds; i++) {
    model.tick(1);
  }
}

void main() {
  test('boots into IDLE with dry-run on until Core says otherwise', () {
    final model = DeviceModel(config: _config);
    expect(model.dryRun, isTrue);
    _run(model, 6);
    expect(model.state, DeviceState.idle);
  });

  test('TURN_ON heats: requested, verifying, heating, relays on', () {
    final model = _idleModel();
    final ack = model.handleCommand(_command('TURN_ON'), now: DateTime.now());
    expect(ack.state, 'ACCEPTED');
    expect(model.state, DeviceState.heatingRequested);
    model.tick(1);
    expect(model.state, DeviceState.heatingVerifying);
    expect(model.relay1.commanded && model.relay2.commanded, isTrue);
    expect(model.relay1.output && model.relay2.output, isTrue);
    _run(model, 19);
    expect(model.state, DeviceState.heating);
    expect(model.verificationConfirmed, isTrue);
    expect(model.supply, greaterThan(50));
  });

  test('TURN_OFF stops through STOPPING back to IDLE with relays off', () {
    final model = _idleModel();
    model.handleCommand(_command('TURN_ON'), now: DateTime.now());
    _run(model, 20);
    final ack = model.handleCommand(
      _command('TURN_OFF', id: 'c2'),
      now: DateTime.now(),
    );
    expect(ack.state, 'ACCEPTED');
    expect(model.state, DeviceState.stopping);
    expect(model.relay2.commanded, isFalse);
    _run(model, 4);
    expect(model.state, DeviceState.idle);
  });

  test('dry-run keeps the output low and fails the verification', () {
    final model = _idleModel(dryRun: true);
    model.handleCommand(_command('TURN_ON'), now: DateTime.now());
    model.tick(1);
    expect(model.relay2.commanded, isTrue);
    expect(model.relay2.output, isFalse);
    _run(model, 25);
    expect(model.state, DeviceState.fault);
    expect(model.activeFaults, contains('HEATING_EFFECT_NOT_CONFIRMED'));
    expect(model.relay2.commanded, isFalse);
    expect(model.safetyInterlockActive, isTrue);
    model.clearFaults();
    expect(model.state, DeviceState.idle);
  });

  test('rejects what the firmware rejects', () {
    final model = _idleModel();
    final now = DateTime.now();
    expect(
      model.handleCommand(_command('TURN_ON', key: 'relay_1'), now: now).error,
      'entity not permitted for remote control',
    );
    expect(
      model
          .handleCommand(
            _command(
              'TURN_ON',
              id: 'old',
              expires: now.subtract(const Duration(seconds: 1)),
            ),
            now: now,
          )
          .error,
      'expired before processing',
    );
    expect(
      model.handleCommand(_command('REBOOT', id: 'x'), now: now).error,
      'unsupported command type for this device',
    );
    model.handleCommand(_command('TURN_ON', id: 'a'), now: now);
    expect(
      model.handleCommand(_command('TURN_ON', id: 'b'), now: now).error,
      'rejected by local safety policy',
    );
    final duplicate = model.handleCommand(
      _command('TURN_ON', id: 'b'),
      now: now,
    );
    expect(duplicate.error, startsWith('duplicate of correlationId b'));
  });

  test('before the first poll no relay is permitted', () {
    final model = DeviceModel(config: _config);
    _run(model, 8);
    expect(
      model.handleCommand(_command('TURN_ON'), now: DateTime.now()).error,
      'entity not permitted for remote control',
    );
  });

  test('TURN_ON needs enough valid sensor reads', () {
    final model = _idleModel()..injectedSupplyStatus = 'TIMEOUT';
    model.tick(1);
    expect(model.activeFaults, contains('SENSOR_SUPPLY_INVALID'));
    expect(
      model.handleCommand(_command('TURN_ON'), now: DateTime.now()).error,
      'rejected by local safety policy',
    );
    final fragment = model.diagnosticsFragment();
    expect((fragment['supplyTemperature']! as Map)['status'], 'TIMEOUT');
  });

  test('SET_DRY_RUN is applied', () {
    final model = _idleModel(dryRun: true);
    final ack = model.handleCommand({
      'correlationId': 'd',
      'type': 'SET_DRY_RUN',
      'payload': {'enabled': false},
    }, now: DateTime.now());
    expect(ack.state, 'ACCEPTED');
    expect(model.dryRun, isFalse);
  });

  test('safe mode refuses heating and relays stay off', () {
    final model = _idleModel()..forceSafeMode();
    model.tick(1);
    expect(model.state, DeviceState.safeMode);
    expect(
      model.handleCommand(_command('TURN_ON'), now: DateTime.now()).error,
      'rejected by local safety policy',
    );
    model.releaseSafeMode();
    model.tick(1);
    expect(model.state, DeviceState.idle);
  });

  test('boiler estimate is omitted at first, floats stay numbers', () {
    final model = _idleModel();
    expect(
      model.diagnosticsFragment().containsKey('boilerTemperatureEstimate'),
      isFalse,
    );
    _run(model, 40);
    expect(
      model.diagnosticsFragment().containsKey('boilerTemperatureEstimate'),
      isTrue,
    );
  });

  test('reboot resets the controller to the firmware defaults', () {
    final model = _idleModel();
    model.handleCommand(_command('TURN_ON'), now: DateTime.now());
    _run(model, 3);
    model.reboot();
    expect(model.state, DeviceState.boot);
    expect(model.dryRun, isTrue);
    expect(model.relay2.commanded, isFalse);
    expect(model.uptimeSeconds, 0);
  });
}
