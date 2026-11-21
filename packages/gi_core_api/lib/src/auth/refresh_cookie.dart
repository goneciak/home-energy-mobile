import 'dart:io' show HttpDate, HttpException;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_cookie.freezed.dart';
part 'refresh_cookie.g.dart';

/// The refresh token as persisted by the app (plan §7.1). It is never sent
/// anywhere but `POST /auth/refresh`, and [toString] never prints [value].
@freezed
abstract class RefreshCookie with _$RefreshCookie {
  const factory({
    required String name,
    required String value,
    required String path,
    required DateTime obtainedAt,

    /// Wall-clock end of the 30-day session; `null` for a session cookie.
    DateTime? absoluteExpiry,

    /// Incremented on every rotation; helps diagnose write-ahead issues.
    @Default(0) int generation,
  }) = _RefreshCookie;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$RefreshCookieFromJson(json);

  /// Value of the `Cookie` request header.
  String get cookieHeader => '$name=$value';

  bool isExpiredAt(DateTime now) =>
      absoluteExpiry != null && !now.isBefore(absoluteExpiry!);

  @override
  String toString() =>
      'RefreshCookie(name: $name, value: <redacted>, path: $path, '
      'obtainedAt: $obtainedAt, absoluteExpiry: $absoluteExpiry, '
      'generation: $generation)';
}

/// Result of looking for the refresh cookie among `Set-Cookie` headers.
sealed class RefreshCookieSelection {
  const new();
}

final class RefreshCookieFound extends RefreshCookieSelection {
  const new(this.cookie);
  final RefreshCookie cookie;
}

/// The server cleared the cookie (empty value, `Max-Age<=0` or an `Expires`
/// in the past), as it does on logout.
final class RefreshCookieCleared extends RefreshCookieSelection {
  const new();
}

/// A refresh cookie is present but its value has the wrong format.
final class RefreshCookieMalformed extends RefreshCookieSelection {
  const new();
}

final class RefreshCookieMissing extends RefreshCookieSelection {
  const new();
}

/// One parsed `Set-Cookie` value.
final class SetCookie {
  const new({
    required this.name,
    required this.value,
    this.path,
    this.domain,
    this.maxAge,
    this.expires,
    this.httpOnly = false,
    this.secure = false,
    this.sameSite,
  });

  final String name;
  final String value;
  final String? path;
  final String? domain;
  final int? maxAge;
  final DateTime? expires;
  final bool httpOnly;
  final bool secure;
  final String? sameSite;

  /// Absolute expiry: `Max-Age` wins over `Expires` (RFC 6265 §5.3).
  DateTime? expiryFrom(DateTime now) {
    final maxAge = this.maxAge;
    if (maxAge != null) return now.add(Duration(seconds: maxAge));
    return expires;
  }

  bool isClearedAt(DateTime now) {
    if (value.isEmpty) return true;
    final expiry = expiryFrom(now);
    return expiry != null && !expiry.isAfter(now);
  }

  @override
  String toString() => 'SetCookie($name=<redacted>; Path=$path)';
}

/// Parses `Set-Cookie` headers and selects the GI Core refresh cookie. The
/// cookie is handled by hand instead of a cookie jar (plan §7.2).
abstract final class RefreshCookieCodec {
  static const defaultName = 'gi_refresh_token';
  static const _refreshPathSuffix = '/auth/refresh';

  /// `<uuid>.<43 base64url chars>` (`auth.service.ts`).
  static final valuePattern = RegExp(r'^[0-9a-f-]{36}\.[A-Za-z0-9_-]{43}$');

  // Splits values folded into one header line by a proxy. A comma inside
  // `Expires=Thu, 17 Dec ...` is not followed by `name=` and is kept.
  static final _foldedSeparator = RegExp(r',\s*(?=[^;,=\s]+=)');

  /// Parses every cookie in [headerValues]; unparsable entries are skipped.
  static List<SetCookie> parseAll(Iterable<String> headerValues) => [
    for (final header in headerValues)
      for (final part in header.split(_foldedSeparator)) ?parse(part),
  ];

  /// Parses one `Set-Cookie` value, or returns `null` when it has no name.
  static SetCookie? parse(String header) {
    final parts = header.split(';');
    final pair = parts.first;
    final eq = pair.indexOf('=');
    if (eq <= 0) return null;
    final name = pair.substring(0, eq).trim();
    if (name.isEmpty) return null;
    var value = pair.substring(eq + 1).trim();
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }

    String? path;
    String? domain;
    int? maxAge;
    DateTime? expires;
    var httpOnly = false;
    var secure = false;
    String? sameSite;
    for (final attribute in parts.skip(1)) {
      final separator = attribute.indexOf('=');
      final key =
          (separator < 0 ? attribute : attribute.substring(0, separator))
              .trim()
              .toLowerCase();
      final attributeValue = separator < 0
          ? ''
          : attribute.substring(separator + 1).trim();
      switch (key) {
        case 'path':
          path = attributeValue;
        case 'domain':
          domain = attributeValue;
        case 'max-age':
          maxAge = int.tryParse(attributeValue);
        case 'expires':
          expires = _parseHttpDate(attributeValue);
        case 'httponly':
          httpOnly = true;
        case 'secure':
          secure = true;
        case 'samesite':
          sameSite = attributeValue;
      }
    }
    return SetCookie(
      name: name,
      value: value,
      path: path,
      domain: domain,
      maxAge: maxAge,
      expires: expires,
      httpOnly: httpOnly,
      secure: secure,
      sameSite: sameSite,
    );
  }

  /// Picks the refresh cookie from [setCookieHeaders]: the last cookie whose
  /// path ends with `/auth/refresh`, falling back to the name
  /// `gi_refresh_token`. [generation] is stored on the new cookie.
  static RefreshCookieSelection select(
    Iterable<String> setCookieHeaders, {
    required DateTime now,
    int generation = 0,
  }) {
    final cookies = parseAll(setCookieHeaders);
    final candidate =
        cookies.lastWhereOrNull(
          (c) => c.path?.endsWith(_refreshPathSuffix) ?? false,
        ) ??
        cookies.lastWhereOrNull((c) => c.name == defaultName);
    if (candidate == null) return const RefreshCookieMissing();
    if (candidate.isClearedAt(now)) return const RefreshCookieCleared();
    if (!valuePattern.hasMatch(candidate.value)) {
      return const RefreshCookieMalformed();
    }
    return RefreshCookieFound(
      RefreshCookie(
        name: candidate.name,
        value: candidate.value,
        path: candidate.path ?? '/api/v1$_refreshPathSuffix',
        obtainedAt: now,
        absoluteExpiry: candidate.expiryFrom(now),
        generation: generation,
      ),
    );
  }

  static DateTime? _parseHttpDate(String value) {
    try {
      return HttpDate.parse(value);
    } on HttpException {
      return null;
    } on FormatException {
      return null;
    }
  }
}

extension<T> on List<T> {
  T? lastWhereOrNull(bool Function(T element) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}
