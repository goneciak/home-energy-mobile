import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/application/error_handlers.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('framework, platform and zone errors reach the ring buffer', () {
    final diagnostics = DiagnosticsService();
    final previousFlutter = FlutterError.onError;
    final previousPresent = FlutterError.presentError;
    final presented = <FlutterErrorDetails>[];
    try {
      FlutterError.presentError = presented.add;
      installErrorHandlers(diagnostics);

      FlutterError.onError!(
        FlutterErrorDetails(
          exception: StateError('layout failed for owner@example.com'),
          stack: StackTrace.fromString('#0 build (http://10.0.0.2/x)'),
          context: ErrorDescription('while laying out HomeScreen'),
        ),
      );
      final handled = platformErrorHandler(diagnostics)(
        const FormatException('token=abc'),
        StackTrace.empty,
      );
      runZonedGuarded(
        () => throw ArgumentError('zone 192.168.0.7'),
        zoneErrorHandler(diagnostics),
      );

      expect(handled, isTrue);
      expect(presented, hasLength(kDebugMode ? 1 : 0));
      final [flutter, platform, zone] = diagnostics.errors;
      expect(flutter.kind, ErrorKind.flutter);
      expect(
        flutter.message,
        allOf(
          contains('layout failed for <email>'),
          contains('while laying out HomeScreen'),
        ),
      );
      expect(flutter.stack, '#0 build (http://<host>/x)');
      expect(platform.kind, ErrorKind.platform);
      expect(platform.message, 'FormatException: token=<redacted>');
      expect(zone.kind, ErrorKind.zone);
      expect(zone.message, contains('zone <ip>'));
    } finally {
      FlutterError.onError = previousFlutter;
      FlutterError.presentError = previousPresent;
      // The test dispatcher starts without a handler.
      WidgetsBinding.instance.platformDispatcher.onError = null;
      diagnostics.dispose();
    }
  });
}
