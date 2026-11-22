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

  group('device command codes', () {
    final cases = <ApiFailure, String Function(AppLocalizations)>{
      const ApiFailure.notFound(code: GiErrorCodes.deviceEntityNotFound): (l) =>
          l.errorDeviceEntityNotFound,
      const ApiFailure.notFound(code: GiErrorCodes.deviceNotFound): (l) =>
          l.errorDeviceNotFound,
      const ApiFailure.domain(
        statusCode: 409,
        code: GiErrorCodes.heatingSuspended,
      ): (l) =>
          l.errorHeatingSuspended,
      const ApiFailure.domain(
        statusCode: 409,
        code: GiErrorCodes.entityDisabled,
      ): (l) =>
          l.errorEntityDisabled,
      const ApiFailure.domain(
        statusCode: 422,
        code: GiErrorCodes.entityNotWritable,
      ): (l) =>
          l.errorEntityNotWritable,
      const ApiFailure.server(
        statusCode: 503,
        errorCode: GiErrorCodes.deviceOffline,
      ): (l) =>
          l.errorDeviceOffline,
      const ApiFailure.server(
        statusCode: 503,
        errorCode: GiErrorCodes.espHomeDeviceUnreachable,
      ): (l) =>
          l.errorDeviceUnreachable,
      const ApiFailure.server(
        statusCode: 502,
        errorCode: GiErrorCodes.espHomeCommandRejected,
      ): (l) =>
          l.errorCommandUnconfirmed,
      const ApiFailure.server(
        statusCode: 502,
        errorCode: GiErrorCodes.espHomeCommandUnconfirmed,
      ): (l) =>
          l.errorCommandUnconfirmed,
      const ApiFailure.server(
        statusCode: 504,
        errorCode: GiErrorCodes.espHomeCommandTimeout,
      ): (l) =>
          l.errorCommandTimeout,
      const ApiFailure.domain(
        statusCode: 400,
        code: GiErrorCodes.espHomeHostForbidden,
      ): (l) =>
          l.errorDeviceHostForbidden,
    };

    for (final MapEntry(key: failure, value: text) in cases.entries) {
      test(failure.code, () {
        for (final l10n in [pl, en]) {
          expect(failureMessage(l10n, failure), text(l10n));
          expect(failureMessage(l10n, failure), isNot(l10n.errorGeneric));
        }
      });
    }

    test('no text claims that a relay switched', () {
      for (final failure in cases.keys) {
        expect(
          failureMessage(pl, failure).toLowerCase(),
          isNot(matches(RegExp('przełączył|włączył|wyłączył'))),
        );
        expect(
          failureMessage(en, failure).toLowerCase(),
          isNot(matches(RegExp('(has|was) (been )?(switched|turned)'))),
        );
      }
    });

    test('an unconfirmed command says the state is unknown', () {
      const failure = ApiFailure.server(
        statusCode: 502,
        errorCode: GiErrorCodes.espHomeCommandUnconfirmed,
      );

      expect(failureMessage(pl, failure), contains('nieznany'));
      expect(failureMessage(en, failure), contains('unknown'));
    });

    test('RBAC, validation and other codes keep the generic texts', () {
      const forbidden = ApiFailure.forbidden(code: GiErrorCodes.forbidden);
      const validation = ApiFailure.validation(details: {});

      expect(deviceCommandFailureMessage(pl, forbidden), isNull);
      expect(failureMessage(pl, forbidden), pl.errorForbidden);
      expect(failureMessage(pl, validation), pl.errorValidation);
      expect(
        failureMessage(pl, const ApiFailure.notFound(code: 'X')),
        pl.errorNotFound,
      );
    });
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
