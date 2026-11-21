import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

/// Fixtures recorded on the contract stack (`tools/seed_core.dart
/// --fixtures`): refresh, change password, logout and the provisioned fake
/// device. Plus the layout rules of plan §17.4.
void main() {
  final now = DateTime.utc(2026, 11, 19);

  group('recorded on the contract stack', () {
    test('refresh: token body and a rotated cookie on the refresh path', () {
      final body = fixtureObject('AuthController_refresh/ok.json');
      final response = RefreshResponse.fromJson(body);
      final selection = RefreshCookieCodec.select(
        [fixtureText('AuthController_refresh/ok.set-cookie.txt').trim()],
        now: now,
        generation: 3,
      );

      expect(response.expiresIn, 900);
      expect(unknownJsonFields(body, response.toJson()), isEmpty);
      final cookie = (selection as RefreshCookieFound).cookie;
      expect(cookie.path, '/api/v1/auth/refresh');
      expect(cookie.generation, 3);
      expect(cookie.absoluteExpiry, now.add(const Duration(days: 30)));
    });

    test('logout: 204 that clears the cookie, never a new one', () {
      final selection = RefreshCookieCodec.select([
        fixtureText('AuthController_logout/ok.set-cookie.txt').trim(),
      ], now: now);

      expect(selection, isA<RefreshCookieCleared>());
    });

    test('change password: only revokedSessions', () {
      final body = fixtureObject('UsersController_changePassword/ok.json');
      final result = ChangePasswordResult.fromJson(body);

      expect(result.revokedSessions, greaterThanOrEqualTo(0));
      expect(unknownJsonFields(body, result.toJson()), isEmpty);
    });

    test('the provisioned fake device decodes strictly', () {
      final body = fixtureObject('DevicesController_get/fake_esphome.json');
      final device = DeviceDetail.fromJson(body);
      final relay = device.entities.singleWhere(
        (e) => e.id == device.heatingRelayEntityId,
      );
      final temperature = device.entities.singleWhere(
        (e) => e.id == device.controlTemperatureEntityId,
      );

      expect(unknownJsonFields(body, device.toJson()), isEmpty);
      expect(device.status, ProductStatus.online);
      expect(device.connectivityState, ConnectivityState.online);
      expect(device.communicationMode, CommunicationMode.legacyEsphome);
      expect(relay.domain, EntityDomain.switch_);
      expect(relay.writable, isTrue);
      expect(relay.value, const EntityValue.boolean(false));
      expect(temperature.deviceClass, 'temperature');
      expect(temperature.value, const EntityValue.number(45.5));
      expect(device.baseControlStrategy?.mode, ControlStrategyMode.manual);
    });

    group('M2 writes on the legacy fake device', () {
      for (final (file, state) in [
        ('legacy_on.json', true),
        ('legacy_off.json', false),
      ]) {
        test('switch $file: confirmed echo, four keys', () {
          final body = fixtureObject(
            'DeviceEspHomeSyncController_setSwitchState/$file',
          );
          final result = SwitchCommandResult.fromJson(body);

          expect(body.keys, {
            'entityId',
            'state',
            'availability',
            'confirmedAt',
          });
          expect(unknownJsonFields(body, result.toJson()), isEmpty);
          expect(result.state, state);
          expect(result.availability, isTrue);
          expect(result.confirmedAt.isUtc, isTrue);
        });
      }

      for (final (file, status, code) in [
        ('error_entity_not_found.json', 404, 'DEVICE_ENTITY_NOT_FOUND'),
        ('error_entity_not_writable.json', 422, 'ENTITY_NOT_WRITABLE'),
        ('error_validation.json', 400, 'VALIDATION_FAILED'),
      ]) {
        test('switch $file: $status $code envelope', () {
          final envelope = ApiErrorEnvelope.tryParse(
            fixtureJson('DeviceEspHomeSyncController_setSwitchState/$file'),
          );

          expect(envelope?.statusCode, status);
          expect(envelope?.code, code);
        });
      }

      test('resume answers with the list-item shape', () {
        final body = fixtureObject('DevicesController_update/resumed.json');
        final device = DeviceListItem.fromJson(body);

        expect(device.status, DeviceListStatus.online);
        expect(device.heatingSuspended, isFalse);
        expect(device.dryRun, isFalse);
        expect(device.activeFaultCount, 0);
        expect(device.connectivityState, ConnectivityState.online);
      });

      test('seeded control strategy: effective equals base', () {
        final body = fixtureObject(
          'DevicesController_updateControlStrategy/seeded.json',
        );
        final result = ControlStrategyUpdateResult.fromJson(body);

        expect(unknownJsonFields(body, result.toJson()), isEmpty);
        expect(result.controlStrategy, result.baseControlStrategy);
        expect(result.baseControlStrategy?.mode, ControlStrategyMode.manual);
        expect(result.baseControlStrategy?.targetTemperatureCelsius, 55);
        expect(result.baseControlStrategy?.hysteresisCelsius, 4);
      });

      test('control strategy out of range: 400 VALIDATION_FAILED', () {
        final envelope = ApiErrorEnvelope.tryParse(
          fixtureJson(
            'DevicesController_updateControlStrategy/error_validation.json',
          ),
        );

        expect(envelope?.statusCode, 400);
        expect(envelope?.code, 'VALIDATION_FAILED');
      });
    });
  });

  group('fixture layout (plan §17.4)', () {
    test('backendRef is shortSha of contract/backend.lock', () {
      final lock = File('../../contract/backend.lock').readAsStringSync();
      final sha = RegExp(
        r'^sha=([0-9a-f]{40})$',
        multiLine: true,
      ).firstMatch(lock)?.group(1);

      expect(sha, isNotNull);
      expect(backendRef, hasLength(7));
      expect(sha, startsWith(backendRef));
      expect(Directory(fixturesDir).existsSync(), isTrue);
    });

    test('nothing is left flat in test/fixtures', () {
      final flat = Directory('test/fixtures').listSync().whereType<File>();

      expect(flat.map((f) => f.path), isEmpty);
    });

    test('every folder is a catalog id, an operationId or _unrouted', () {
      final catalogIds = {for (final e in GiEndpoints.all) e.id};
      const outsideCatalog = {
        'AuthController_listSessions',
        'SetupController_initialize',
        '_unrouted',
      };
      final folders = [
        for (final entry in Directory(fixturesDir).listSync())
          entry.uri.pathSegments.where((s) => s.isNotEmpty).last,
      ];

      expect(folders, isNotEmpty);
      for (final folder in folders) {
        expect(
          catalogIds.contains(folder) || outsideCatalog.contains(folder),
          isTrue,
          reason: '$folder is neither a GiEndpoints id nor listed here',
        );
      }
      // Every catalog entry has at least one recorded response.
      expect(catalogIds.difference(folders.toSet()), isEmpty);
    });

    test('case files are <case>.json or <case>.set-cookie.txt', () {
      final files = Directory(fixturesDir)
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last);

      for (final name in files) {
        expect(
          name,
          matches(RegExp(r'^[a-z0-9_]+(\.json|\.set-cookie\.txt)$')),
        );
      }
    });
  });
}
