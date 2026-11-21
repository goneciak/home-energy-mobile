import 'dart:convert';
import 'dart:io';

/// `<base>/docs-json` for a GI Core base URL; a pasted `/api/v1` suffix or
/// trailing slash is dropped (Swagger is mounted outside the API prefix).
Uri docsJsonUri(String baseUrl) {
  var base = baseUrl.trim();
  while (base.endsWith('/')) {
    base = base.substring(0, base.length - 1);
  }
  if (base.endsWith('/api/v1')) {
    base = base.substring(0, base.length - '/api/v1'.length);
  }
  if (!base.contains('://')) base = 'http://$base';
  return Uri.parse('$base/docs-json');
}

/// GETs the OpenAPI document at [uri].
Future<Map<String, Object?>> fetchSpec(
  Uri uri, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final request = await client.getUrl(uri).timeout(timeout);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(timeout);
    final body = await response.transform(utf8.decoder).join().timeout(timeout);
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: uri);
    }
    return _object(jsonDecode(body), uri.toString());
  } finally {
    client.close(force: true);
  }
}

Map<String, Object?> readSpecFile(File file) =>
    _object(jsonDecode(file.readAsStringSync()), file.path);

Map<String, Object?> _object(Object? json, String source) {
  if (json is Map<String, Object?> && json['paths'] is Map) return json;
  throw FormatException('$source is not an OpenAPI document');
}
