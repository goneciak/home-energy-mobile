import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/platform/backup_exclusion.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';

/// The `gi_home/backup` channel of plan §8.3 (native side:
/// `ios/Runner/AppDelegate.swift`, unverified until built on macOS).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late Directory support;

  void answer(Future<Object?> Function(MethodCall call) handler) =>
      messenger.setMockMethodCallHandler(BackupExclusion.channel, (call) {
        calls.add(call);
        return handler(call);
      });

  setUp(() {
    calls = [];
    support = Directory.systemTemp.createTempSync('gi-support-');
    addTearDown(() => support.deleteSync(recursive: true));
    answer((_) async => null);
    addTearDown(
      () => messenger.setMockMethodCallHandler(BackupExclusion.channel, null),
    );
  });

  test('on iOS the Application Support directory is excluded', () async {
    await BackupExclusion.exclude(support, platform: TargetPlatform.iOS);

    expect(calls, hasLength(1));
    expect(calls.single.method, 'excludeFromBackup');
    expect(calls.single.arguments, {'path': support.absolute.path});
  });

  test('on Android nothing is called: the manifest already keeps the data '
      'out of backups', () async {
    await BackupExclusion.exclude(support, platform: TargetPlatform.android);

    expect(calls, isEmpty);
  });

  test('a platform failure is swallowed and reported', () async {
    answer((_) async => throw PlatformException(code: 'exclude_failed'));
    final errors = <Object>[];

    await BackupExclusion.exclude(
      support,
      platform: TargetPlatform.iOS,
      onError: (error, _) => errors.add(error),
    );

    expect(errors.single, isA<PlatformException>());
  });

  test('a missing native handler is swallowed too', () async {
    messenger.setMockMethodCallHandler(BackupExclusion.channel, null);

    await expectLater(
      BackupExclusion.exclude(
        support,
        platform: TargetPlatform.iOS,
        onError: (_, _) => throw StateError('diagnostics down'),
      ),
      completes,
    );
  });

  group('at start-up', () {
    late DiagnosticsService diagnostics;

    setUp(() {
      diagnostics = DiagnosticsService();
      addTearDown(diagnostics.dispose);
    });

    test('iOS excludes the support directory', () async {
      await excludeFromBackup(
        support,
        diagnostics,
        platform: TargetPlatform.iOS,
      );

      expect(calls.single.arguments, {'path': support.absolute.path});
      expect(diagnostics.errors, isEmpty);
    });

    test('Android makes no call', () async {
      await excludeFromBackup(
        support,
        diagnostics,
        platform: TargetPlatform.android,
      );

      expect(calls, isEmpty);
    });

    test('a failure ends up in the diagnostics, not in a crash', () async {
      answer((_) async => throw PlatformException(code: 'exclude_failed'));

      await excludeFromBackup(
        support,
        diagnostics,
        platform: TargetPlatform.iOS,
      );

      final entry = diagnostics.errors.single;
      expect(entry.kind, ErrorKind.platform);
      expect(entry.message, contains('backup exclusion'));
    });
  });
}
