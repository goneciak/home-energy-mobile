import 'dart:io' show Directory;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Called with a failure of the platform call (local diagnostics).
typedef BackupExclusionErrorSink = void Function(
  Object error,
  StackTrace stack,
);

/// Keeps app files out of device backups (plan §5.2, §8.3).
///
/// * iOS: the `gi_home/backup` channel sets
///   `URLResourceValues.isExcludedFromBackup` (`NSURLIsExcludedFromBackupKey`)
///   on the directory, which covers everything inside it
///   (`ios/Runner/AppDelegate.swift`).
/// * Android: nothing to do here; `android:allowBackup="false"` and
///   `dataExtractionRules` already keep the app's data out of backups.
abstract final class BackupExclusion {
  static const channel = MethodChannel('gi_home/backup');

  /// Method of [channel]; its argument is `{path: <absolute path>}`.
  static const excludeMethod = 'excludeFromBackup';

  /// Excludes [directory] from backups where the platform needs it. Never
  /// throws: a failure goes to [onError] and the files stay where they are.
  /// [platform] defaults to the current one.
  static Future<void> exclude(
    Directory directory, {
    BackupExclusionErrorSink? onError,
    TargetPlatform? platform,
  }) async {
    if ((platform ?? defaultTargetPlatform) != TargetPlatform.iOS) return;
    try {
      await channel.invokeMethod<void>(excludeMethod, {
        'path': directory.absolute.path,
      });
    } on Object catch (error, stack) {
      try {
        onError?.call(error, stack);
      } on Object {
        // Diagnostics never fail the start-up.
      }
    }
  }
}
