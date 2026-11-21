import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';

void main() {
  final pl = lookupAppLocalizations(const Locale('pl'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('temperatures have exactly one decimal (plan §13.3)', () {
    test('in °C, with the separator of the app language', () {
      String format(AppLocalizations l10n, num value) =>
          formatEntityValue(l10n, EntityValue.number(value), unit: '°C');

      expect(format(pl, 54.25), '54,3 °C');
      expect(format(en, 54.25), '54.3 °C');
      expect(format(pl, 21), '21,0 °C');
      expect(format(en, 21), '21.0 °C');
      expect(format(pl, -3.04), '-3,0 °C');
      expect(format(en, 0.06), '0.1 °C');
    });

    test('of the temperature device class, whatever the unit text', () {
      expect(
        formatEntityValue(
          pl,
          const EntityValue.number(48.123),
          deviceClass: 'temperature',
        ),
        '48,1',
      );
      expect(
        formatEntityValue(
          en,
          const EntityValue.number(48),
          unit: 'C',
          deviceClass: 'temperature',
        ),
        '48.0 C',
      );
    });

    test('also with the one-character ℃ sign', () {
      expect(
        formatEntityValue(pl, const EntityValue.number(20.55), unit: '℃'),
        '20,6 ℃',
      );
    });

    test('formatTemperature', () {
      expect(formatTemperature(pl, 7), '7,0');
      expect(formatTemperature(en, 7.25), '7.3');
      // Grouping follows the language too.
      expect(formatTemperature(en, 1200), '1,200.0');
    });
  });

  group('other units keep at most two decimals', () {
    test('percent, watts and plain numbers', () {
      expect(
        formatEntityValue(pl, const EntityValue.number(45.678), unit: '%'),
        '45,68 %',
      );
      expect(
        formatEntityValue(en, const EntityValue.number(45.678), unit: '%'),
        '45.68 %',
      );
      expect(
        formatEntityValue(pl, const EntityValue.number(1500), unit: 'W'),
        // Polish groups thousands with a non-breaking space.
        '1 500 W',
      );
      expect(formatEntityValue(en, const EntityValue.number(3)), '3');
      expect(
        formatEntityValue(
          pl,
          const EntityValue.number(0.5),
          deviceClass: 'humidity',
          unit: '%',
        ),
        '0,5 %',
      );
    });

    test('a temperature as text is shown as sent', () {
      expect(
        formatEntityValue(pl, const EntityValue.text('21.55'), unit: '°C'),
        '21.55 °C',
      );
    });
  });

  test('isTemperature', () {
    expect(isTemperature(unit: '°C'), isTrue);
    expect(isTemperature(unit: ' ° C '), isTrue);
    expect(isTemperature(deviceClass: 'Temperature'), isTrue);
    expect(isTemperature(unit: '%'), isFalse);
    expect(isTemperature(unit: '°F'), isFalse);
    expect(isTemperature(), isFalse);
  });
}
