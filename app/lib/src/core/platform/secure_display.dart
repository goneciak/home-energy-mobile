import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Protection of a secret on screen and on the clipboard (plan §M3.5: the
/// recovery code is shown once and must not leak).
///
/// The `gi_home/secure` channel is served by `MainActivity.kt` on Android
/// and `AppDelegate.swift` on iOS:
/// * `setSecure` `{secure: bool}`: Android sets or clears
///   `WindowManager.LayoutParams.FLAG_SECURE` (no screenshots, no
///   recording, a blank recents thumbnail). iOS cannot block screenshots;
///   it starts or stops reporting screen recording and mirroring back as
///   `captureChanged` `{captured: bool}` so the secret is hidden meanwhile.
/// * `copySensitive` `{text, clearAfterMs}`: Android marks the clip
///   sensitive (`ClipDescription.EXTRA_IS_SENSITIVE`, so the system does not
///   preview it) and clears it after the delay if it is still there; iOS
///   puts it on the local-only pasteboard (no Handoff) with an expiration
///   date.
///
/// Nothing here throws, and nothing logs the text.
abstract final class SecureDisplay {
  static const channel = MethodChannel('gi_home/secure');

  static const setSecureMethod = 'setSecure';
  static const copySensitiveMethod = 'copySensitive';

  /// Called by iOS while the screen is (or stops being) recorded.
  static const captureChangedMethod = 'captureChanged';

  /// How long a copied secret stays on the clipboard.
  static const clipboardLifetime = Duration(minutes: 1);

  /// Turns screen protection on or off.
  static Future<void> setSecure({required bool secure}) async {
    try {
      await channel.invokeMethod<void>(setSecureMethod, {'secure': secure});
    } on Object {
      // No native side (tests, desktop): the secret is still shown.
    }
  }

  /// Copies [text] as a sensitive clip that is cleared after [clearAfter].
  /// Without the native side it falls back to the plain clipboard and
  /// clears it from Dart, only while it still holds [text].
  static Future<void> copySensitive(
    String text, {
    Duration clearAfter = clipboardLifetime,
  }) async {
    try {
      final copied = await channel.invokeMethod<bool>(copySensitiveMethod, {
        'text': text,
        'clearAfterMs': clearAfter.inMilliseconds,
      });
      if (copied ?? false) return;
    } on Object {
      // Fall back below.
    }
    await Clipboard.setData(ClipboardData(text: text));
    _pendingClear?.cancel();
    _pendingClear = Timer(clearAfter, () => unawaited(_clearIf(text)));
  }

  static Timer? _pendingClear;

  static Future<void> _clearIf(String text) async {
    try {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == text) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } on Object {
      // The clipboard is out of reach; nothing more to do.
    }
  }

  /// Cancels the Dart fallback's pending clear (tests).
  @visibleForTesting
  static void cancelPendingClear() {
    _pendingClear?.cancel();
    _pendingClear = null;
  }
}
