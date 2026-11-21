import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';

/// Sends framework errors (`FlutterError.onError`) and errors that escape
/// every zone (`PlatformDispatcher.onError`) to [diagnostics]. In debug
/// builds they are still printed as before (plan §8.4).
void installErrorHandlers(DiagnosticsService diagnostics) {
  FlutterError.onError = flutterErrorHandler(diagnostics);
  WidgetsBinding.instance.platformDispatcher.onError = platformErrorHandler(
    diagnostics,
  );
}

/// `FlutterError.onError`: build, layout, paint and gesture errors.
FlutterExceptionHandler flutterErrorHandler(DiagnosticsService diagnostics) =>
    (details) {
      diagnostics.recordError(
        ErrorKind.flutter,
        details.exceptionAsString(),
        details.stack,
        details.context?.toDescription(),
      );
      if (kDebugMode) FlutterError.presentError(details);
    };

/// `PlatformDispatcher.onError`: errors outside every guarded zone. Returns
/// `true` (handled), so the engine does not log them a second time.
bool Function(Object error, StackTrace stack) platformErrorHandler(
  DiagnosticsService diagnostics,
) => (error, stack) {
  diagnostics.recordError(ErrorKind.platform, error, stack);
  if (kDebugMode) debugPrint('Uncaught platform error: $error\n$stack');
  return true;
};

/// The `runZonedGuarded` handler of `main`.
void Function(Object error, StackTrace stack) zoneErrorHandler(
  DiagnosticsService diagnostics,
) => (error, stack) {
  diagnostics.recordError(ErrorKind.zone, error, stack);
  if (kDebugMode) debugPrint('Uncaught error: $error\n$stack');
};
