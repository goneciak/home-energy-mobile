import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/diagnostics/data/diagnostics_store.dart';
import 'package:gi_home/src/features/diagnostics/domain/diagnostic_counters.dart';
import 'package:gi_home/src/features/diagnostics/domain/diagnostic_report.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';
import 'package:gi_home/src/features/diagnostics/domain/stale_app_policy.dart';

/// Collects redacted errors and local counters and persists them at most
/// [writeDelay] after the first unsaved change (plan §8.4), and right away
/// when the app goes to the background (see `GiHomeApp`). Created in `main`
/// before `runApp`, so errors caught while the app starts are kept too; the
/// file store is attached once the Application Support directory is known.
///
/// The GI Core request log ([recordHttp]) is kept apart from the errors, in
/// a smaller buffer held only in memory: polling would otherwise push the
/// errors out and rewrite the file every few seconds.
///
/// Nothing here throws: diagnostics must never break the app.
final class DiagnosticsService {
  new({
    this._store,
    DateTime Function()? now,
    this.writeDelay = const Duration(seconds: 2),
    int capacity = ErrorRingBuffer.defaultCapacity,
    int httpCapacity = defaultHttpCapacity,
  }) : _now = now ?? DateTime.now,
       _errors = ErrorRingBuffer(capacity: capacity),
       _http = ErrorRingBuffer(capacity: httpCapacity) {
    _counters = DiagnosticCounters(since: _now().toUtc());
  }

  /// Request log lines kept for the report (two per request).
  static const defaultHttpCapacity = 100;

  /// How long changes are collected before one write; later changes never
  /// postpone it.
  final Duration writeDelay;

  final DateTime Function() _now;
  final ErrorRingBuffer _errors;
  final ErrorRingBuffer _http;
  late DiagnosticCounters _counters;
  DiagnosticsStore? _store;
  Timer? _writeTimer;
  bool _dirty = false;
  final _sessionUnexpectedShape = <String, int>{};
  final _updateSuggested = ValueNotifier<bool>(false);
  Future<void> _queue = Future.value();

  List<ErrorLogEntry> get errors => _errors.entries;

  /// The newest GI Core request log lines, redacted, oldest first.
  List<ErrorLogEntry> get httpLog => _http.entries;

  DiagnosticCounters get counters => _counters;

  /// `UnexpectedShape` failures by endpoint id since the app started. Unlike
  /// [counters] they are neither stored nor cleared on logout: they describe
  /// this app version against this GI Core, not the user.
  Map<String, int> get sessionUnexpectedShape =>
      Map.unmodifiable(_sessionUnexpectedShape);

  /// Turns `true` (for the rest of the app session) once the
  /// [StaleAppPolicy] suggests updating the app.
  ValueListenable<bool> get updateSuggested => _updateSuggested;

  /// Loads what [store] holds, merges it with anything recorded so far and
  /// persists to it from now on.
  Future<void> attach(DiagnosticsStore store) => _enqueue(() async {
    _store = store;
    final stored = await store.load();
    final storedErrors = stored.errors;
    if (storedErrors is List<Object?>) {
      _errors.prependAll(storedErrors.map(ErrorLogEntry.fromJson).nonNulls);
    }
    if (stored.counters != null) {
      final restored = DiagnosticCounters.fromJson(
        stored.counters,
        fallbackSince: _counters.since,
      )..addAll(_counters);
      _counters = restored;
    }
    // Anything caught before the store was known is written now.
    if (_dirty) _scheduleWrite();
  });

  /// Records an uncaught error. [error] and [stack] are redacted and the
  /// stack trimmed before anything is kept.
  void recordError(
    ErrorKind kind,
    Object error, [
    StackTrace? stack,
    String? context,
  ]) {
    try {
      final text = '$error';
      _errors.add(
        ErrorLogEntry.redacted(
          time: _now(),
          kind: kind,
          message: context == null ? text : '$text ($context)',
          stack: stack == null || stack == StackTrace.empty ? null : '$stack',
        ),
      );
      _scheduleWrite();
    } on Object {
      // A failing toString() must not become a new uncaught error.
    }
  }

  /// Records one line of the GI Core request log (an `HttpLogSink`). The
  /// line is redacted again here: tokens, cookies, passwords, e-mails and
  /// addresses never reach the buffer.
  void recordHttp(String line) {
    try {
      _http.add(
        ErrorLogEntry.redacted(
          time: _now(),
          kind: ErrorKind.http,
          message: line,
        ),
      );
    } on Object {
      // Logging must never fail a request.
    }
  }

  /// Counts a failure reported by the GI Core client.
  void recordFailure(ApiFailure failure) {
    if (failure is LocalNetworkDeniedFailure) {
      recordLocalNetworkDenied();
      return;
    }
    if (!_counters.recordFailure(failure)) return;
    if (failure case UnexpectedShapeFailure(:final endpointId)) {
      _sessionUnexpectedShape.update(
        endpointId,
        (n) => n + 1,
        ifAbsent: () => 1,
      );
      if (StaleAppPolicy.suggestsUpdate(_sessionUnexpectedShape)) {
        _updateSuggested.value = true;
      }
    }
    if (failure case UnexpectedShapeFailure(
      :final endpointId,
      :final fieldPath,
      :final message,
      :final requestId,
    )) {
      _errors.add(
        ErrorLogEntry.redacted(
          time: _now(),
          kind: ErrorKind.unexpectedShape,
          message: [
            endpointId,
            ?fieldPath,
            ?message,
            if (requestId != null) 'requestId=$requestId',
          ].join(' · '),
        ),
      );
    }
    _scheduleWrite();
  }

  /// Counts a session that ended without the user logging out.
  void recordSessionLost(SessionLostReason reason) {
    _counters.recordSessionLost(reason);
    _scheduleWrite();
  }

  /// Counts a failed secure-storage read (plan §7.1).
  void recordVaultUnavailable() {
    _counters.vaultUnavailable++;
    _scheduleWrite();
  }

  /// Counts a denied local-network permission (plan §9.4).
  void recordLocalNetworkDenied() {
    _counters.localNetworkDenied++;
    _scheduleWrite();
  }

  /// Time from `main` to the first frame of the first real screen.
  void recordColdStart(Duration elapsed) {
    _counters.recordColdStart(elapsed);
    _scheduleWrite();
  }

  /// The redacted report for [environment].
  Map<String, Object?> buildReport(ReportEnvironment environment) =>
      DiagnosticReport.build(
        generatedAt: _now(),
        environment: environment,
        counters: _counters,
        errors: _errors.entries,
        httpLog: _http.entries,
      );

  /// Writes pending changes now.
  Future<void> flush() {
    _writeTimer?.cancel();
    _writeTimer = null;
    final errors = _errors.toJson();
    final counters = _counters.toJson();
    return _enqueue(() async {
      final store = _store;
      if (store == null) return;
      await store.save(errors: errors, counters: counters);
      _dirty = false;
    });
  }

  /// Forgets every error and counter, in memory and on disk (logout, change
  /// of user or appliance: plan §7.3, §8.3).
  Future<void> clear() {
    _writeTimer?.cancel();
    _writeTimer = null;
    _dirty = false;
    _errors.clear();
    _http.clear();
    _counters = DiagnosticCounters(since: _now().toUtc());
    return _enqueue(() async {
      await _store?.clear();
    });
  }

  void dispose() {
    _writeTimer?.cancel();
    _writeTimer = null;
  }

  void _scheduleWrite() {
    _dirty = true;
    // Without a store there is nothing to write yet; attach() catches up.
    if (_store == null) return;
    // Throttled, not debounced: an error repeated every frame must not keep
    // postponing the write, so the pending timer is never pushed back.
    if (_writeTimer?.isActive ?? false) return;
    _writeTimer = Timer(writeDelay, () => unawaited(flush()));
  }

  /// Serialises store operations so a write never lands after a clear.
  Future<void> _enqueue(Future<void> Function() operation) =>
      _queue = _queue.then((_) async {
        try {
          await operation();
        } on Object {
          // Losing diagnostics is acceptable; failing the app is not.
        }
      });
}
