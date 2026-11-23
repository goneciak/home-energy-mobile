import 'package:meta/meta.dart';

/// Normalised address of a GI Home appliance: scheme, host, optional port
/// and an optional reverse-proxy prefix, without `/api/v1`.
@immutable
final class ApplianceAddress {
  const new _(this.origin);

  /// Accepts what users type on the connect screen: `192.168.1.10`,
  /// `gi-home.local`, `http://host:3000`, `fe80::1`, or a pasted URL ending
  /// in `/api/v1`. The scheme defaults to `http`; trailing slashes, query and
  /// fragment are dropped. Throws [FormatException] for anything else.
  factory parse(String input) {
    var text = input.trim();
    if (text.isEmpty) throw const FormatException('Empty address');
    if (!text.contains('://')) {
      // A bare IPv6 literal needs brackets before it can carry a scheme.
      final isBareIpv6 = ':'.allMatches(text).length > 1 && !text.contains('[');
      text = 'http://${isBareIpv6 ? '[$text]' : text}';
    }
    final Uri uri;
    try {
      uri = Uri.parse(text);
    } on FormatException {
      throw FormatException('Invalid address', input);
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      throw FormatException('Unsupported scheme', input);
    }
    if (uri.host.isEmpty) throw FormatException('Missing host', input);
    if (uri.userInfo.isNotEmpty) {
      throw FormatException(
        'Credentials are not allowed in the address',
        input,
      );
    }
    return ApplianceAddress._(
      Uri(
        scheme: scheme,
        host: uri.host.toLowerCase(),
        port: uri.hasPort ? uri.port : null,
        path: _stripApiPrefix(uri.path),
      ),
    );
  }

  /// `scheme://host[:port][/prefix]` with no trailing slash.
  final Uri origin;

  /// Base URL of the REST API: `<origin>/api/v1`.
  Uri get apiBaseUrl => origin.replace(path: '${origin.path}/api/v1');

  /// `host` or `host:port`, for display.
  String get authority =>
      origin.hasPort ? '${origin.host}:${origin.port}' : origin.host;

  /// Whether the address names a port explicitly.
  bool get hasPort => origin.hasPort;

  /// The same address on [port].
  ApplianceAddress withPort(int port) =>
      ApplianceAddress._(origin.replace(port: port));

  bool get isCleartext => origin.scheme == 'http';

  static String _stripApiPrefix(String path) {
    var result = path.replaceAll(RegExp(r'/+$'), '');
    for (final suffix in const ['/api/v1', '/api']) {
      if (result.toLowerCase().endsWith(suffix)) {
        result = result.substring(0, result.length - suffix.length);
        break;
      }
    }
    return result.replaceAll(RegExp(r'/+$'), '');
  }

  @override
  bool operator ==(Object other) =>
      other is ApplianceAddress && other.origin == origin;

  @override
  int get hashCode => origin.hashCode;

  @override
  String toString() => origin.toString();
}
