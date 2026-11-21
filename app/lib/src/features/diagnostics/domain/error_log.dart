import 'dart:collection';

import 'package:gi_home/src/features/diagnostics/domain/redaction.dart';
import 'package:meta/meta.dart';

/// Where an error was caught (plan §8.4).
enum ErrorKind {
  /// `FlutterError.onError`: framework errors (build, layout, gestures).
  flutter,

  /// `PlatformDispatcher.onError`: uncaught errors outside the root zone.
  platform,

  /// The `runZonedGuarded` handler of `main`.
  zone,

  /// A response whose JSON did not match the model (`UnexpectedShape`).
  unexpectedShape,

  /// One redacted line of the GI Core request log (`RedactingLogInterceptor`,
  /// plan §6.5 point 7). Not an error: kept in its own, smaller buffer.
  http;

  static ErrorKind? byName(Object? name) {
    for (final kind in values) {
      if (kind.name == name) return kind;
    }
    return null;
  }
}

/// One redacted entry of the error ring buffer.
@immutable
final class ErrorLogEntry {
  /// Use [ErrorLogEntry.redacted] for anything that may contain secrets.
  const new({
    required this.time,
    required this.kind,
    required this.message,
    this.stack,
    this.count = 1,
  });

  /// Redacts and trims [message] and [stack] (at most [maxStackLines]).
  factory redacted({
    required DateTime time,
    required ErrorKind kind,
    required String message,
    String? stack,
  }) => ErrorLogEntry(
    time: time.toUtc(),
    kind: kind,
    message: _truncate(Redactor.redact(message), maxMessageLength),
    stack: stack == null ? null : trimStack(stack),
  );

  static ErrorLogEntry? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final time = DateTime.tryParse('${json['time']}');
    final kind = ErrorKind.byName(json['kind']);
    final message = json['message'];
    if (time == null || kind == null || message is! String) return null;
    final stack = json['stack'];
    final count = json['count'];
    // Re-redacted on load: a file written by an older version must not leak
    // through a newer, stricter report.
    return ErrorLogEntry(
      time: time.toUtc(),
      kind: kind,
      message: Redactor.redact(message),
      stack: stack is String ? Redactor.redact(stack) : null,
      count: count is int && count > 0 ? count : 1,
    );
  }

  static const maxMessageLength = 2000;
  static const maxStackLines = 30;
  static const maxStackLength = 4000;

  final DateTime time;
  final ErrorKind kind;
  final String message;
  final String? stack;

  /// How many identical errors arrived in a row (a broken build method
  /// reports the same error every frame).
  final int count;

  bool isSameErrorAs(ErrorLogEntry other) =>
      other.kind == kind && other.message == message && other.stack == stack;

  ErrorLogEntry repeatedAt(DateTime at) => ErrorLogEntry(
    time: at.toUtc(),
    kind: kind,
    message: message,
    stack: stack,
    count: count + 1,
  );

  Map<String, Object?> toJson() => {
    'time': time.toIso8601String(),
    'kind': kind.name,
    'message': message,
    if (stack != null) 'stack': stack,
    if (count > 1) 'count': count,
  };

  /// The first [maxStackLines] non-empty frames of [stack], redacted.
  static String trimStack(String stack) {
    final lines = stack
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.isNotEmpty)
        .toList();
    final kept = lines.take(maxStackLines).join('\n');
    final dropped = lines.length - maxStackLines;
    final trimmed = dropped > 0 ? '$kept\n… $dropped more' : kept;
    return _truncate(Redactor.redact(trimmed), maxStackLength);
  }

  static String _truncate(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max)}…';

  @override
  bool operator ==(Object other) =>
      other is ErrorLogEntry &&
      isSameErrorAs(other) &&
      other.time == time &&
      other.count == count;

  @override
  int get hashCode => Object.hash(time, kind, message, stack, count);
}

/// The last [capacity] errors, oldest first. Repeats of the newest entry
/// are folded into its [ErrorLogEntry.count].
final class ErrorRingBuffer {
  new({this.capacity = defaultCapacity})
    : assert(capacity > 0, 'capacity must be positive');

  static const defaultCapacity = 200;

  final int capacity;
  final _entries = ListQueue<ErrorLogEntry>();

  List<ErrorLogEntry> get entries => List.unmodifiable(_entries);

  int get length => _entries.length;

  bool get isEmpty => _entries.isEmpty;

  void add(ErrorLogEntry entry) {
    if (_entries.isNotEmpty && _entries.last.isSameErrorAs(entry)) {
      _entries.addLast(_entries.removeLast().repeatedAt(entry.time));
      return;
    }
    _entries.addLast(entry);
    while (_entries.length > capacity) {
      _entries.removeFirst();
    }
  }

  /// Puts [older] (e.g. loaded from disk) before the current entries,
  /// keeping the newest [capacity].
  void prependAll(Iterable<ErrorLogEntry> older) {
    final merged = [...older, ..._entries];
    _entries
      ..clear()
      ..addAll(
        merged.skip(merged.length > capacity ? merged.length - capacity : 0),
      );
  }

  void clear() => _entries.clear();

  List<Map<String, Object?>> toJson() => [
    for (final entry in _entries) entry.toJson(),
  ];
}
