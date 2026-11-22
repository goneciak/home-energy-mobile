import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

/// What the app tells the stores: encryption export key, privacy manifest,
/// Android permissions and cleartext. docs/store/ answers the store forms from
/// these files, so a change here needs a change there.
void main() {
  // `flutter test` runs from app/; a Windows checkout may have CRLF.
  String read(String path) =>
      File(path).readAsStringSync().replaceAll('\r\n', '\n');

  /// The top-level `<dict>` of a plist as a Dart map (`dict`, `array`, `bool`
  /// and `string` values; enough for Info.plist and PrivacyInfo.xcprivacy).
  Map<String, Object?> parsePlist(String xml) {
    final doc = XmlDocument.parse(xml);
    if (doc.rootElement.name.local != 'plist') throw StateError('not a plist');
    return _dict(doc.rootElement.childElements.single);
  }

  group('iOS Info.plist', () {
    final plist = parsePlist(read('ios/Runner/Info.plist'));

    test('declares that it uses no non-exempt encryption', () {
      expect(plist['ITSAppUsesNonExemptEncryption'], isFalse);
    });

    test('allows local networking and explains the local network prompt', () {
      final ats = plist['NSAppTransportSecurity']! as Map;
      expect(ats['NSAllowsLocalNetworking'], isTrue);
      expect(plist['NSLocalNetworkUsageDescription'], isA<String>());
      expect(plist['NSLocalNetworkUsageDescription'], isNotEmpty);
    });

    test('does not switch off App Transport Security wholesale', () {
      final ats = plist['NSAppTransportSecurity']! as Map;
      expect(ats.keys, ['NSAllowsLocalNetworking']);
    });

    test('declares no Bonjour services: .local names resolve through the '
        'system and the multicast DNS fallback needs no declaration', () {
      expect(plist, isNot(contains('NSBonjourServices')));
    });

    test('asks for no permission the privacy policy does not mention', () {
      final usageKeys = plist.keys.where(
        (k) => k.startsWith('NS') && k.endsWith('UsageDescription'),
      );
      expect(usageKeys, ['NSLocalNetworkUsageDescription']);
    });
  });

  group('iOS privacy manifest', () {
    final manifest = parsePlist(read('ios/Runner/PrivacyInfo.xcprivacy'));

    test('has the four required keys', () {
      expect(
        manifest.keys,
        containsAll([
          'NSPrivacyTracking',
          'NSPrivacyTrackingDomains',
          'NSPrivacyCollectedDataTypes',
          'NSPrivacyAccessedAPITypes',
        ]),
      );
    });

    test('does not track and collects nothing', () {
      expect(manifest['NSPrivacyTracking'], isFalse);
      expect(manifest['NSPrivacyTrackingDomains'], isEmpty);
      expect(manifest['NSPrivacyCollectedDataTypes'], isEmpty);
    });

    test('declares UserDefaults with reason CA92.1 (shared_preferences)', () {
      final apis = (manifest['NSPrivacyAccessedAPITypes']! as List)
          .cast<Map<String, Object?>>();
      expect(apis, hasLength(1));
      expect(
        apis.single['NSPrivacyAccessedAPIType'],
        'NSPrivacyAccessedAPICategoryUserDefaults',
      );
      expect(apis.single['NSPrivacyAccessedAPITypeReasons'], ['CA92.1']);
    });

    test('is part of the Runner target (project file)', () {
      final project = read('ios/Runner.xcodeproj/project.pbxproj');
      final patterns = {
        'PBXBuildFile': RegExp(
          r'PrivacyInfo\.xcprivacy in Resources \*/ = \{isa = PBXBuildFile',
        ),
        'PBXFileReference': RegExp(
          r'PrivacyInfo\.xcprivacy \*/ = \{isa = PBXFileReference',
        ),
        'Runner group': RegExp(
          r'\n\t+[0-9A-F]{24} /\* PrivacyInfo\.xcprivacy \*/,\n',
        ),
        'Resources build phase': RegExp(
          r'\n\t+[0-9A-F]{24} /\* PrivacyInfo\.xcprivacy in Resources \*/,\n',
        ),
      };
      patterns.forEach((name, pattern) {
        expect(pattern.hasMatch(project), isTrue, reason: name);
      });
    });
  });

  group('Android manifest', () {
    final doc = XmlDocument.parse(
      read('android/app/src/main/AndroidManifest.xml'),
    );
    final permissions = doc.rootElement
        .findElements('uses-permission')
        .toList();

    test('requests exactly the documented permissions', () {
      final names = [
        for (final p in permissions) p.getAttribute('android:name')!,
      ]..sort();
      expect(names, [
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.CHANGE_WIFI_MULTICAST_STATE',
        'android.permission.INTERNET',
        'android.permission.NEARBY_WIFI_DEVICES',
      ]);
    });

    test('NEARBY_WIFI_DEVICES is never used to derive a location', () {
      final nearby = permissions.singleWhere(
        (p) =>
            p.getAttribute('android:name') ==
            'android.permission.NEARBY_WIFI_DEVICES',
      );
      expect(
        nearby.getAttribute('android:usesPermissionFlags'),
        'neverForLocation',
      );
    });

    test('cleartext goes only through network_security_config', () {
      final application = doc.rootElement.findElements('application').single;
      expect(application.getAttribute('android:usesCleartextTraffic'), isNull);
      expect(
        application.getAttribute('android:networkSecurityConfig'),
        '@xml/network_security_config',
      );
      final config = XmlDocument.parse(
        read('android/app/src/main/res/xml/network_security_config.xml'),
      ).rootElement;
      final base = config.findElements('base-config').single;
      expect(base.getAttribute('cleartextTrafficPermitted'), 'true');
      expect(config.findElements('domain-config'), isEmpty);
    });

    test('the app is not backed up and exports only the launcher activity', () {
      final application = doc.rootElement.findElements('application').single;
      expect(application.getAttribute('android:allowBackup'), 'false');
      final exported = doc.rootElement.descendantElements.where(
        (e) => e.getAttribute('android:exported') == 'true',
      );
      expect(exported.map((e) => e.getAttribute('android:name')), [
        '.MainActivity',
      ]);
    });
  });

  group('store documents', () {
    test('the Data safety sheet names the manifest permissions', () {
      final sheet = read('../docs/store/data-safety.md');
      for (final permission in [
        'INTERNET',
        'ACCESS_NETWORK_STATE',
        'NEARBY_WIFI_DEVICES',
        'CHANGE_WIFI_MULTICAST_STATE',
      ]) {
        expect(sheet, contains(permission), reason: permission);
      }
    });

    test(
      'the review notes cover demo, accounts, cleartext and local network',
      () {
        final notes = read('../docs/store/review-notes.md');
        for (final topic in [
          'Try the demo',
          'does not create accounts',
          'NSAllowsLocalNetworking',
          'NEARBY_WIFI_DEVICES',
        ]) {
          expect(notes, contains(topic), reason: topic);
        }
      },
    );
  });
}

Map<String, Object?> _dict(XmlElement e) {
  final children = e.childElements.toList();
  final result = <String, Object?>{};
  for (var i = 0; i < children.length; i += 2) {
    if (children[i].name.local != 'key') throw StateError('expected <key>');
    result[children[i].innerText] = _value(children[i + 1]);
  }
  return result;
}

Object? _value(XmlElement e) => switch (e.name.local) {
  'true' => true,
  'false' => false,
  'string' => e.innerText,
  'array' => [for (final c in e.childElements) _value(c)],
  'dict' => _dict(e),
  final other => throw StateError('unexpected plist element <$other>'),
};
