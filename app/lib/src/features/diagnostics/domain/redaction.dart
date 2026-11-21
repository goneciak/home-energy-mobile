/// Removes secrets and identifying addresses from diagnostic text before it
/// is stored or shared (plan §8.4). Pure Dart, no Flutter.
///
/// Redacted: JWTs and `Bearer` tokens, the refresh cookie (by name and by
/// its value format), values of sensitive keys (`accessToken`, `password`,
/// `cookie`, ...; a quoted value whole), e-mail addresses, recovery codes,
/// hosts of URLs, host lookups, `address =` and `host:`, `.local` names, and
/// IPv4/IPv6 addresses. Server request ids (`m-…`/UUIDs), paths
/// and status codes are kept because they are what support needs.
abstract final class Redactor {
  static const jwt = '<jwt>';
  static const secret = '<redacted>';
  static const email = '<email>';
  static const host = '<host>';
  static const ip = '<ip>';
  static const recoveryCode = '<recovery-code>';

  static final _jwt = RegExp(
    r'\beyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*',
  );

  static final _bearer = RegExp(
    r'\b(bearer)\s+[A-Za-z0-9._~+/=-]+',
    caseSensitive: false,
  );

  static final _refreshCookie = RegExp(
    r'''(gi_refresh_token\s*=\s*)[^;\s,"'&]*''',
    caseSensitive: false,
  );

  /// `<uuid>.<43 base64url>`: the refresh token value without its name.
  static final _refreshValue = RegExp(
    r'\b[0-9a-f-]{36}\.[A-Za-z0-9_-]{43}(?![A-Za-z0-9_-])',
    caseSensitive: false,
  );

  /// A sensitive key and its separator, then the value's opening quote
  /// (also JSON-escaped, `\"`) when there is one. The value itself is found
  /// by [_redactSensitiveValues].
  static final _sensitiveKey = RegExp(
    r'''\b(access_?token|refresh_?token|id_?token|token|password|'''
    '''new_?password|current_?password|recovery_?code|authorization|'''
    r'''set-cookie|cookie|secret|api_?key)\\?["']?\s*[:=]\s*(\\?["'])?''',
    caseSensitive: false,
  );

  /// An unquoted value ends at whitespace or a delimiter.
  static final _unquotedValue = RegExp(r'''[^"'\s,;&}\]\\]+''');

  static final _email = RegExp(
    r'[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}',
  );

  /// Eight groups of four hex digits joined by the same separator, or the
  /// 32 digits of its normalised form. A `-` or word character before it
  /// (request ids are `m-<32 hex>`) or a UUID's 8-4-4-4-12 layout is kept.
  static final _recoveryGrouped = RegExp(
    r'(?<![\w-])[0-9A-F]{4}([-\s])[0-9A-F]{4}(?:\1[0-9A-F]{4}){6}(?![\w-])',
    caseSensitive: false,
  );

  static final _recoveryPlain = RegExp(
    r'(?<![\w-])[0-9A-F]{32}(?![\w-])',
    caseSensitive: false,
  );

  /// `scheme://[userinfo@]host` — the host (and any credentials) go, the
  /// port and path stay; the query string may carry secrets and goes too.
  static final _urlAuthority = RegExp(
    r'\b([a-z][a-z0-9+.-]*://)(?:[^\s/@]*@)?(\[[^\]\s]*\]|[^\s/:?#]+)',
    caseSensitive: false,
  );

  static final _urlQuery = RegExp(r'''(<host>[^\s?#"']*)\?[^\s#"']*''');

  static final _hostLookup = RegExp(
    r'''(host lookup:\s*')[^']*''',
    caseSensitive: false,
  );

  /// `address = <name>` (a SocketException) and `host: <name>` (the text of
  /// a failure). Applied after the IP rules, so `<ip>` is kept.
  static final _namedHost = RegExp(
    r'''\b(address|host(?:name)?)(\s*[:=]\s*)(?!<)[^\s,;:/)\]}"'\\]+''',
    caseSensitive: false,
  );

  static final _localName = RegExp(
    r'\b[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.local\b',
    caseSensitive: false,
  );

  /// Candidate IPv6 address (optionally bracketed, with a zone id or a
  /// dotted IPv4 tail), confirmed with [Uri.parseIPv6Address].
  static final _ipv6 = RegExp(
    r'(?<![\w:.])\[?((?:[0-9A-F]{0,4}:){2,7}'
    r'(?:\d{1,3}(?:\.\d{1,3}){3}|[0-9A-F]{0,4}))(%[\w.]+)?\]?(?![\w:])',
    caseSensitive: false,
  );

  static final _ipv4 = RegExp(
    r'(?<![\w.])(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)'
    r'(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}(?![\w.]*\w)',
  );

  /// [input] with every secret and address replaced by a placeholder.
  static String redact(String input) {
    if (input.isEmpty) return input;
    var out =
        _redactSensitiveValues(
              input
                  .replaceAll(_jwt, jwt)
                  .replaceAllMapped(_bearer, (m) => '${m[1]} $secret')
                  .replaceAllMapped(_refreshCookie, (m) => '${m[1]}$secret')
                  .replaceAll(_refreshValue, secret),
            )
            // URLs first: credentials in `user:pw@host` are not an e-mail.
            .replaceAllMapped(_urlAuthority, (m) => '${m[1]}$host')
            .replaceAllMapped(_urlQuery, (m) => '${m[1]}?$secret')
            .replaceAll(_email, email)
            .replaceAll(_recoveryGrouped, recoveryCode)
            .replaceAll(_recoveryPlain, recoveryCode)
            .replaceAllMapped(_hostLookup, (m) => '${m[1]}$host')
            .replaceAll(_localName, host);
    out = out.replaceAllMapped(_ipv6, (m) {
      try {
        Uri.parseIPv6Address(m[1]!);
        return ip;
      } on FormatException {
        return m[0]!;
      }
    });
    return out
        .replaceAll(_ipv4, ip)
        .replaceAllMapped(_namedHost, (m) => '${m[1]}${m[2]}$host');
  }

  /// Replaces the value of every sensitive key. A quoted value goes up to
  /// its closing quote, so a passphrase with spaces is removed whole; an
  /// unclosed one up to the end of the line. A value that already is a
  /// placeholder (`<jwt>`) is kept.
  static String _redactSensitiveValues(String input) {
    final out = StringBuffer();
    var position = 0;
    while (position < input.length) {
      final match = _sensitiveKey.allMatches(input, position).firstOrNull;
      if (match == null) break;
      out.write(input.substring(position, match.end));
      position = match.end;
      if (input.startsWith('<', position)) continue;
      final quote = match[2];
      if (quote == null) {
        final value = _unquotedValue.matchAsPrefix(input, position);
        if (value != null) {
          out.write(secret);
          position = value.end;
        }
        continue;
      }
      final (:valueEnd, :quoteEnd) = _closingQuote(input, position, quote);
      out
        ..write(secret)
        ..write(input.substring(valueEnd, quoteEnd));
      position = quoteEnd;
    }
    out.write(input.substring(position));
    return out.toString();
  }

  /// Where the value opened by [quote] at [start] ends, and where its
  /// closing quote ends. In a plain quoted value a backslash escapes the
  /// next character; a JSON-escaped quote (`\"`) is closed by the next `\"`.
  static ({int valueEnd, int quoteEnd}) _closingQuote(
    String input,
    int start,
    String quote,
  ) {
    if (quote.length > 1) {
      final end = input.indexOf(quote, start);
      if (end >= 0) return (valueEnd: end, quoteEnd: end + quote.length);
    } else {
      for (var i = start; i < input.length; i++) {
        final char = input[i];
        if (char == '\n') break;
        if (char == r'\') {
          i++;
        } else if (char == quote) {
          return (valueEnd: i, quoteEnd: i + 1);
        }
      }
    }
    final line = input.indexOf('\n', start);
    final end = line < 0 ? input.length : line;
    return (valueEnd: end, quoteEnd: end);
  }

  /// Copy of a JSON-like value with every string (map keys included)
  /// passed through [redact].
  static Object? redactJson(Object? value) => switch (value) {
    final String text => redact(text),
    final Map<Object?, Object?> map => {
      for (final MapEntry(:key, value: item) in map.entries)
        redact('$key'): redactJson(item),
    },
    final Iterable<Object?> items => [
      for (final item in items) redactJson(item),
    ],
    _ => value,
  };
}
