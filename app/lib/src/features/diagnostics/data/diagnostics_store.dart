import 'dart:convert';
import 'dart:io';

/// Persistence of the error log and counters (plan §8.3: logs live in the
/// Application Support directory, excluded from backups).
abstract interface class DiagnosticsStore {
  /// The stored error log and counters; `null` parts are missing or
  /// unreadable.
  Future<({Object? errors, Object? counters})> load();

  Future<void> save({required Object? errors, required Object? counters});

  /// Removes everything (logout, change of user or appliance).
  Future<void> clear();
}

/// Two small JSON files in `<Application Support>/diagnostics/`.
final class FileDiagnosticsStore implements DiagnosticsStore {
  new(Directory applicationSupport)
    : directory = Directory(
        '${applicationSupport.path}${Platform.pathSeparator}diagnostics',
      );

  final Directory directory;

  File get errorsFile => _file('errors.json');
  File get countersFile => _file('counters.json');

  File _file(String name) =>
      File('${directory.path}${Platform.pathSeparator}$name');

  @override
  Future<({Object? errors, Object? counters})> load() async =>
      (errors: await _read(errorsFile), counters: await _read(countersFile));

  @override
  Future<void> save({
    required Object? errors,
    required Object? counters,
  }) async {
    await directory.create(recursive: true);
    await _write(errorsFile, errors);
    await _write(countersFile, counters);
  }

  @override
  Future<void> clear() async {
    if (directory.existsSync()) await directory.delete(recursive: true);
  }

  static Future<Object?> _read(File file) async {
    try {
      if (!file.existsSync()) return null;
      return jsonDecode(await file.readAsString());
    } on Object {
      // A truncated or corrupt file only loses old diagnostics.
      return null;
    }
  }

  /// Writes through a temporary file and a rename, so a crash mid-write
  /// leaves the previous version intact.
  static Future<void> _write(File file, Object? json) async {
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(json), flush: true);
    await temp.rename(file.path);
  }
}

/// Keeps the data in memory only (tests, and platforms without files).
final class MemoryDiagnosticsStore implements DiagnosticsStore {
  Object? errors;
  Object? counters;
  int saves = 0;

  @override
  Future<({Object? errors, Object? counters})> load() async =>
      (errors: errors, counters: counters);

  @override
  Future<void> save({
    required Object? errors,
    required Object? counters,
  }) async {
    saves++;
    this.errors = errors;
    this.counters = counters;
  }

  @override
  Future<void> clear() async {
    errors = null;
    counters = null;
  }
}
