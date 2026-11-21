import 'dart:convert';
import 'dart:io';

/// Recorded GI Core responses (plan §17.4):
/// `test/fixtures/core/<backendRef>/<endpointId>/<case>.json`, where
/// `backendRef` is `shortSha` of `contract/backend.lock` and `endpointId` is
/// the catalog id (`GiEndpoints`, the Swagger operationId). Responses of
/// endpoints outside the catalog use their operationId too; `_unrouted` holds
/// responses to routes that do not exist. Tests run from the package folder.
///
/// Recorded vs hand-written: a case whose name ends in `_handwritten` was
/// written by hand from the backend source (for responses the contract stack
/// cannot produce, e.g. GI Edge switch commands, or write endpoints not yet
/// recorded); every other case was recorded from a live GI Core. Replace a
/// hand-written case with a recorded one when the contract stack can
/// produce it.
const fixturesRoot = 'test/fixtures/core';

/// The backend ref the fixtures were recorded against.
final String backendRef = readBackendRef(File('../../contract/backend.lock'));

/// Folder of the fixtures recorded against [backendRef].
String get fixturesDir => '$fixturesRoot/$backendRef';

/// `shortSha` from a `contract/backend.lock` file.
String readBackendRef(File lock) {
  for (final line in lock.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('shortSha=')) {
      return trimmed.substring('shortSha='.length).trim();
    }
  }
  throw StateError('${lock.path} has no shortSha=');
}

/// Raw text of the fixture at `<endpointId>/<case>.<ext>`.
String fixtureText(String path) =>
    File('$fixturesDir/$path').readAsStringSync();

Object? fixtureJson(String path) => jsonDecode(fixtureText(path));

Map<String, dynamic> fixtureObject(String path) =>
    fixtureJson(path)! as Map<String, dynamic>;
