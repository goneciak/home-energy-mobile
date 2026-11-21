/// Identity of the app sent in `User-Agent`. It is the only device label the
/// user sees in `/auth/sessions` (plan §6.5).
final class ClientInfo {
  const new({required this.appVersion, required this.platform});

  /// Semantic app version, e.g. `0.1.0`.
  final String appVersion;

  /// Human-readable platform, e.g. `iPhone; iOS 18.1` or
  /// `Linux; Android 15; Pixel 8`.
  final String platform;

  /// `GIHome-Mobile/<version> (<platform>)`, restricted to printable ASCII.
  String get userAgent =>
      'GIHome-Mobile/${_sanitize(appVersion)} (${_sanitize(platform)})';

  static String _sanitize(String value) => value
      .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
      .replaceAll(RegExp('[()]'), '');
}
