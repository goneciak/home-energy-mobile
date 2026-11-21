/// A pragmatic reader of GI UI's `messages.ts`
/// (`apps/gi-ui/src/shared/i18n/messages.ts`), plan §13.1.
///
/// Supported, which is what that file uses:
/// * `export const messages = { "<locale>": { "<key>": "<text>", ... }, ... }`
///   (the first object literal after `messages =`; `as const` and type
///   annotations around it are ignored);
/// * keys as `"..."`, `'...'` or bare identifiers; values as `"..."`,
///   `'...'` or template literals without `${...}`, optionally joined with
///   `+`;
/// * the escapes `\n \t \r \b \f \v \0 \' \" \\ \` \uXXXX \u{X...} \xXX`,
///   `//` and `/* */` comments, trailing commas, values on the next line.
///
/// Not supported (reported in [TsMessages.skipped] and left out): template
/// literals with interpolation, identifiers, function calls, spreads and any
/// other expression as a value, nested objects inside a locale.
library;

/// Messages per locale (`en-US` -> key -> text) plus what was skipped.
final class TsMessages {
  const new(this.locales, this.skipped);

  final Map<String, Map<String, String>> locales;

  /// `<locale>.<key>: <reason>` for every value that could not be read.
  final List<String> skipped;
}

/// Parses [source]; throws [FormatException] when there is no
/// `messages = {...}` object to read.
TsMessages parseTsMessages(String source) => _TsParser(source).parseMessages();

final class _TsParser {
  new(this.source);

  final String source;
  var _pos = 0;
  final List<String> _skipped = [];

  TsMessages parseMessages() {
    // `const messages = {` / `const messages: Messages = {`, else any
    // `messages = {` (the word alone also appears in comments and types).
    final start =
        RegExp(r'\b(?:const|let|var)\s+messages\b[^=;{]*=\s*')
            .firstMatch(source) ??
        RegExp(r'\bmessages\s*=\s*').firstMatch(source);
    if (start == null) {
      throw const FormatException('No `messages = {` object found');
    }
    _pos = start.end;
    _skipTrivia();
    _expect('{');
    final locales = <String, Map<String, String>>{};
    while (true) {
      _skipTrivia();
      if (_peek('}')) {
        _pos++;
        break;
      }
      final locale = _key();
      _skipTrivia();
      _expect(':');
      _skipTrivia();
      if (_peek('{')) {
        locales[locale] = _localeObject(locale);
      } else {
        _skipped.add('$locale: not an object literal');
        _skipValue();
      }
      _skipTrivia();
      if (_peek(',')) _pos++;
    }
    return TsMessages(locales, _skipped);
  }

  Map<String, String> _localeObject(String locale) {
    _expect('{');
    final messages = <String, String>{};
    while (true) {
      _skipTrivia();
      if (_peek('}')) {
        _pos++;
        return messages;
      }
      if (source.startsWith('...', _pos)) {
        _skipped.add('$locale: spread ignored');
        _skipValue();
      } else {
        final key = _key();
        _skipTrivia();
        _expect(':');
        _skipTrivia();
        final value = _stringExpression();
        if (value == null) {
          _skipped.add('$locale.$key: unsupported value');
          _skipValue();
        } else {
          messages[key] = value;
        }
      }
      _skipTrivia();
      if (_peek(',')) _pos++;
    }
  }

  String _key() {
    final quote = _char;
    if (quote == '"' || quote == "'" || quote == '`') {
      final value = _string();
      if (value == null) _fail('Unsupported key');
      return value;
    }
    final match = RegExp(r'[A-Za-z_$][\w$]*').matchAsPrefix(source, _pos);
    if (match == null) _fail('Expected a key');
    _pos = match.end;
    return match[0]!;
  }

  /// One or more string literals joined with `+`, or null (position
  /// unchanged) for anything else.
  String? _stringExpression() {
    final start = _pos;
    final parts = <String>[];
    while (true) {
      final part = _string();
      if (part == null) {
        _pos = start;
        return null;
      }
      parts.add(part);
      final afterPart = _pos;
      _skipTrivia();
      if (!_peek('+')) {
        _pos = afterPart;
        // A string followed by something other than `,` / `}` (a method
        // call, `as`, ...) is an expression we do not evaluate.
        _skipTrivia();
        final next = _pos < source.length ? source[_pos] : '';
        _pos = afterPart;
        if (next != ',' && next != '}') {
          _pos = start;
          return null;
        }
        return parts.join();
      }
      _pos++;
      _skipTrivia();
    }
  }

  /// A string literal at the position, or null (position unchanged).
  String? _string() {
    final quote = _char;
    if (quote != '"' && quote != "'" && quote != '`') return null;
    final start = _pos;
    _pos++;
    final out = StringBuffer();
    while (_pos < source.length) {
      final c = source[_pos];
      if (c == quote) {
        _pos++;
        return out.toString();
      }
      if (c == r'\') {
        _pos++;
        out.write(_escape());
        continue;
      }
      if (quote == '`' && source.startsWith(r'${', _pos)) {
        _pos = start;
        return null;
      }
      if (quote != '`' && c == '\n') _fail('Unterminated string');
      out.write(c);
      _pos++;
    }
    _fail('Unterminated string');
  }

  String _escape() {
    final c = _char;
    _pos++;
    switch (c) {
      case 'n':
        return '\n';
      case 't':
        return '\t';
      case 'r':
        return '\r';
      case 'b':
        return '\b';
      case 'f':
        return '\f';
      case 'v':
        return '\v';
      case '0':
        return '\x00';
      case '\n':
        return ''; // Line continuation.
      case 'x':
        final hex = source.substring(_pos, _pos + 2);
        _pos += 2;
        return String.fromCharCode(int.parse(hex, radix: 16));
      case 'u':
        if (_peek('{')) {
          final end = source.indexOf('}', _pos);
          final hex = source.substring(_pos + 1, end);
          _pos = end + 1;
          return String.fromCharCode(int.parse(hex, radix: 16));
        }
        final hex = source.substring(_pos, _pos + 4);
        _pos += 4;
        return String.fromCharCode(int.parse(hex, radix: 16));
      default:
        return c;
    }
  }

  /// Skips an unsupported value up to the `,` or `}` that ends it.
  void _skipValue() {
    var depth = 0;
    while (_pos < source.length) {
      _skipTrivia();
      if (_pos >= source.length) break;
      final c = source[_pos];
      if (c == '"' || c == "'" || c == '`') {
        _skipRawString();
        continue;
      }
      if ('([{'.contains(c)) depth++;
      if (')]}'.contains(c)) {
        if (depth == 0) return;
        depth--;
      }
      if (c == ',' && depth == 0) return;
      _pos++;
    }
  }

  void _skipRawString() {
    final quote = source[_pos++];
    while (_pos < source.length && source[_pos] != quote) {
      if (source[_pos] == r'\') _pos++;
      _pos++;
    }
    _pos++;
  }

  void _skipTrivia() {
    while (_pos < source.length) {
      final c = source[_pos];
      if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
        _pos++;
      } else if (source.startsWith('//', _pos)) {
        final end = source.indexOf('\n', _pos);
        _pos = end < 0 ? source.length : end + 1;
      } else if (source.startsWith('/*', _pos)) {
        final end = source.indexOf('*/', _pos + 2);
        _pos = end < 0 ? source.length : end + 2;
      } else {
        return;
      }
    }
  }

  String get _char => _pos < source.length ? source[_pos] : '';

  bool _peek(String text) => source.startsWith(text, _pos);

  void _expect(String text) {
    if (!_peek(text)) _fail('Expected `$text`');
    _pos += text.length;
  }

  Never _fail(String message) {
    final line = '\n'.allMatches(source.substring(0, _pos)).length + 1;
    throw FormatException('$message at line $line', source, _pos);
  }
}
