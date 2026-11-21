import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/home/domain/heating_strategy.dart';

import '../../support/fixtures.dart';

void main() {
  Map<String, Object?> strategy(num target, num hysteresis, String mode) => {
    'targetTemperatureCelsius': target,
    'hysteresisCelsius': hysteresis,
    'mode': mode,
  };

  DeviceDetail detail({
    Map<String, Object?>? effective,
    Map<String, Object?>? base,
    bool suspended = false,
    bool pvBoostActive = false,
    Map<String, Object?>? pvHeatingConfig,
  }) => fixtureDetail({
    'controlStrategy': effective,
    'baseControlStrategy': base,
    'heatingSuspended': suspended,
    'pvBoostActive': pvBoostActive,
    'pvHeatingConfig': pvHeatingConfig,
  });

  group('scheduleActive', () {
    test('effective equal to base: no schedule', () {
      final summary = HeatingStrategySummary.of(
        detail(
          effective: strategy(55, 4, 'AUTO'),
          base: strategy(55, 4, 'AUTO'),
        ),
      );
      expect(summary.scheduleActive, isFalse);
      expect(summary.shown?.targetTemperatureCelsius, 55);
    });

    test('a different target means a schedule', () {
      expect(
        HeatingStrategySummary.of(
          detail(
            effective: strategy(21, 4, 'AUTO'),
            base: strategy(55, 4, 'AUTO'),
          ),
        ).scheduleActive,
        isTrue,
      );
    });

    test('a different hysteresis means a schedule', () {
      expect(
        HeatingStrategySummary.of(
          detail(
            effective: strategy(55, 2, 'AUTO'),
            base: strategy(55, 4, 'AUTO'),
          ),
        ).scheduleActive,
        isTrue,
      );
    });

    test('mode alone is never compared', () {
      expect(
        HeatingStrategySummary.of(
          detail(
            effective: strategy(55, 4, 'OFF'),
            base: strategy(55, 4, 'AUTO'),
          ),
        ).scheduleActive,
        isFalse,
      );
    });

    test('never while suspended, even with a different target', () {
      final summary = HeatingStrategySummary.of(
        detail(
          effective: strategy(21, 4, 'OFF'),
          base: strategy(55, 4, 'AUTO'),
          suspended: true,
        ),
      );
      expect(summary.scheduleActive, isFalse);
      expect(summary.suspended, isTrue);
    });

    test('missing effective or base: no schedule; shown falls back', () {
      final onlyBase = HeatingStrategySummary.of(
        detail(base: strategy(40, 3, 'MANUAL')),
      );
      expect(onlyBase.scheduleActive, isFalse);
      expect(onlyBase.shown?.targetTemperatureCelsius, 40);

      final onlyEffective = HeatingStrategySummary.of(
        detail(effective: strategy(40, 3, 'MANUAL')),
      );
      expect(onlyEffective.scheduleActive, isFalse);

      final none = HeatingStrategySummary.of(detail());
      expect(none.shown, isNull);
      expect(none.scheduleActive, isFalse);
    });
  });

  group('pvBoost', () {
    test('inactive: null', () {
      expect(HeatingStrategySummary.of(detail()).pvBoost, isNull);
    });

    test('active: target derived from safeMax', () {
      final summary = HeatingStrategySummary.of(
        detail(
          pvBoostActive: true,
          pvHeatingConfig: {'mode': 'HYBRID', 'safeMaxTemperatureCelsius': 75},
        ),
      );
      const expected = PvBoost(derivedTargetCelsius: 75);
      expect(summary.pvBoost, expected);
      expect(summary.pvBoost.hashCode, expected.hashCode);
    });

    test('active without a configuration: unknown target', () {
      expect(
        HeatingStrategySummary.of(detail(pvBoostActive: true)).pvBoost,
        const PvBoost(derivedTargetCelsius: null),
      );
    });
  });
}
