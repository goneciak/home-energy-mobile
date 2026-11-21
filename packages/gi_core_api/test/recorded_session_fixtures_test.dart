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
        'SettingsController_getSystem',
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
