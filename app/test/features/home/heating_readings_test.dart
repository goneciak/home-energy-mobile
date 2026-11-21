import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/home/domain/heating_readings.dart';

import '../../support/fixtures.dart';

void main() {
  DeviceDetail detail([Map<String, Object?> overrides = const {}]) =>
      fixtureDetail({...entityRichDetailJson(), ...overrides});

  DeviceEntity entity(Map<String, Object?> changes) => DeviceEntity.fromJson({
    ...(entityRichDetailJson()['entities']! as List)
        .cast<Map<String, Object?>>()
        .first,
    ...changes,
  });

  test('heating cards poll every 15 s and are stale after 30 s', () {
    expect(FreshnessPolicy.heatingCard.interval, const Duration(seconds: 15));
    expect(FreshnessPolicy.heatingCard.staleAfter, const Duration(seconds: 30));
  });

  test('readings of the recorded entity shape', () {
    expect(
      HeatingReadings.of(detail()),
      const HeatingReadings(
        boilerRelay: RelayState.on,
        pumpRelay: RelayState.off,
        controlTemperature: TemperatureReading(
          status: ReadingStatus.ok,
          value: 54.25,
          unit: '°C',
        ),
      ),
    );
  });

  test('entities that are not configured give no reading', () {
    final readings = HeatingReadings.of(
      detail({'pumpRelayEntityId': null, 'controlTemperatureEntityId': null}),
    );

    expect(readings.pumpRelay, isNull);
    expect(readings.controlTemperature, isNull);
  });

  test('a configured entity the device lacks has no data', () {
    final readings = HeatingReadings.of(
      detail({
        'heatingRelayEntityId': 'gone',
        'controlTemperatureEntityId': 'gone',
      }),
    );

    expect(readings.boilerRelay, RelayState.noData);
    expect(readings.controlTemperature!.status, ReadingStatus.noData);
  });

  group('relay values', () {
    final cases = <Object?, RelayState>{
      true: RelayState.on,
      false: RelayState.off,
      1: RelayState.on,
      0: RelayState.off,
      'ON': RelayState.on,
      ' off ': RelayState.off,
      'true': RelayState.on,
      2: RelayState.noData,
      'maybe': RelayState.noData,
      null: RelayState.noData,
      const {'state': true}: RelayState.noData,
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      test('$key is $value', () {
        expect(HeatingReadings.relayStateOf(entity({'value': key})), value);
      });
    }

    test('a disabled or unavailable relay is never on or off', () {
      expect(
        HeatingReadings.relayStateOf(entity({'enabled': false})),
        RelayState.unavailable,
      );
      expect(
        HeatingReadings.relayStateOf(entity({'availability': false})),
        RelayState.unavailable,
      );
    });
  });

  group('temperature values', () {
    test('numeric text is a reading', () {
      expect(
        HeatingReadings.temperatureOf(entity({'value': ' 41.5 ', 'unit': ''})),
        const TemperatureReading(status: ReadingStatus.ok, value: 41.5),
      );
    });

    test('anything else has no data', () {
      for (final value in [null, 'warm', true, const <int>[]]) {
        expect(
          HeatingReadings.temperatureOf(entity({'value': value})).status,
          ReadingStatus.noData,
          reason: '$value',
        );
      }
    });

    test('an unavailable sensor is unavailable', () {
      expect(
        HeatingReadings.temperatureOf(entity({'availability': false})).status,
        ReadingStatus.unavailable,
      );
    });
  });
}
