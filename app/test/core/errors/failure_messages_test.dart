import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';

void main() {
  final pl = lookupAppLocalizations(const Locale('pl'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('a denied local network asks for the permission in Settings', () {
    const failure = ApiFailure.localNetworkDenied(reason: 'EPERM');

    expect(
      failureMessage(pl, failure),
      'GI Home nie ma dostępu do sieci lokalnej. Zezwól na dostęp w '
      'Ustawieniach telefonu.',
    );
    expect(failureMessage(en, failure), contains('local network'));
    expect(failureMessage(en, failure), contains('Settings'));
  });

  test('a reset appliance asks to finish its setup', () {
    const failure = ApiFailure.applianceReset();

    expect(failureMessage(pl, failure), pl.errorApplianceReset);
    expect(failureMessage(pl, failure), contains('Dokończ'));
    expect(failureMessage(en, failure), en.errorApplianceReset);
  });

  test('new failures have their own text, not the generic one', () {
    for (final l10n in [pl, en]) {
      for (final failure in const [
        ApiFailure.localNetworkDenied(),
        ApiFailure.applianceReset(),
        ApiFailure.differentAppliance(),
        ApiFailure.tlsUntrusted(host: 'gi.example.com'),
      ]) {
        expect(
          failureMessage(l10n, failure),
          isNot(l10n.errorGeneric),
          reason: '${l10n.localeName} ${failure.code}',
        );
      }
    }
  });
}
