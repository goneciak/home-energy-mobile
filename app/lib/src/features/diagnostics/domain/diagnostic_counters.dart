import 'package:gi_core_api/gi_core_api.dart';

/// Local diagnostic counters (plan §8.4 point 2). Nothing leaves the phone
/// unless the user shares a diagnostic report.
final class DiagnosticCounters {
  new({required this.since});

  /// Restores counters written by [toJson]; unknown or malformed values are
  /// dropped instead of failing.
  factory fromJson(Object? json, {required DateTime fallbackSince}) {
    if (json is! Map<String, Object?>) {
      return DiagnosticCounters(since: fallbackSince);
    }
    final counters = DiagnosticCounters(
      since: DateTime.tryParse('${json['since']}')?.toUtc() ?? fallbackSince,
    );
    final lost = json['sessionLost'];
    if (lost is Map<String, Object?>) {
      for (final reason in SessionLostReason.values) {
        final value = lost[reason.name];
        if (value is int && value > 0) counters._sessionLost[reason] = value;
      }
    }
    final shapes = json['unexpectedShape'];
    if (shapes is Map<String, Object?>) {
      for (final MapEntry(:key, :value) in shapes.entries) {
        if (value is int && value > 0) counters._unexpectedShape[key] = value;
      }
    }
    final coldStarts = json['coldStartMs'];
    if (coldStarts is List<Object?>) {
      counters._coldStartMs.addAll(
        coldStarts.whereType<int>().where((ms) => ms >= 0),
      );
      counters._trimColdStarts();
    }
    int count(String key) => switch (json[key]) {
      final int value when value > 0 => value,
      _ => 0,
    };
    counters
      ..vaultUnavailable = count('vaultUnavailable')
      ..tlsUntrusted = count('tlsUntrusted')
      ..localNetworkDenied = count('localNetworkDenied')
      ..coldStarts = count('coldStarts');
    return counters;
  }

  /// Cold-start samples kept for the report (newest last).
  static const maxColdStartSamples = 20;

  /// When counting started (first run, or the last logout).
  final DateTime since;

  final _sessionLost = <SessionLostReason, int>{};
  final _unexpectedShape = <String, int>{};
  final _coldStartMs = <int>[];

  /// Failed secure-storage reads, counted by the token vault on every read
  /// (plan §7.1) rather than from [VaultUnavailableFailure], which several
  /// callers waiting on one read would each report.
  int vaultUnavailable = 0;
  int tlsUntrusted = 0;

  /// Denied local-network permissions (plan §9.4), counted by
  /// `DiagnosticsService.recordLocalNetworkDenied` for every
  /// [LocalNetworkDeniedFailure] it is told about.
  int localNetworkDenied = 0;

  /// Every measured cold start, also those no longer in [coldStartMs].
  int coldStarts = 0;

  /// Forced logouts by reason (plan §7.4).
  Map<SessionLostReason, int> get sessionLost => Map.unmodifiable(_sessionLost);

  /// `UnexpectedShape` failures by catalog endpoint id.
  Map<String, int> get unexpectedShape => Map.unmodifiable(_unexpectedShape);

  /// The last [maxColdStartSamples] cold starts in milliseconds.
  List<int> get coldStartMs => List.unmodifiable(_coldStartMs);

  void recordSessionLost(SessionLostReason reason) =>
      _sessionLost.update(reason, (n) => n + 1, ifAbsent: () => 1);

  void recordColdStart(Duration elapsed) {
    coldStarts++;
    _coldStartMs.add(elapsed.inMilliseconds);
    _trimColdStarts();
  }

  /// Counts [failure] when it is one of the kinds counted per failure;
  /// returns whether anything changed. (Local-network denials have their own
  /// hook, see [localNetworkDenied].)
  bool recordFailure(ApiFailure failure) {
    switch (failure) {
      case UnexpectedShapeFailure(:final endpointId):
        _unexpectedShape.update(endpointId, (n) => n + 1, ifAbsent: () => 1);
      case TlsUntrustedFailure():
        tlsUntrusted++;
      default:
        return false;
    }
    return true;
  }

  /// Adds [other]'s counts to these (counters recorded before the stored
  /// ones were loaded). [since] stays.
  void addAll(DiagnosticCounters other) {
    for (final MapEntry(:key, :value) in other._sessionLost.entries) {
      _sessionLost.update(key, (n) => n + value, ifAbsent: () => value);
    }
    for (final MapEntry(:key, :value) in other._unexpectedShape.entries) {
      _unexpectedShape.update(key, (n) => n + value, ifAbsent: () => value);
    }
    vaultUnavailable += other.vaultUnavailable;
    tlsUntrusted += other.tlsUntrusted;
    localNetworkDenied += other.localNetworkDenied;
    coldStarts += other.coldStarts;
    _coldStartMs.addAll(other._coldStartMs);
    _trimColdStarts();
  }

  void _trimColdStarts() {
    final excess = _coldStartMs.length - maxColdStartSamples;
    if (excess > 0) _coldStartMs.removeRange(0, excess);
  }

  Map<String, Object?> toJson() => {
    'since': since.toIso8601String(),
    'sessionLost': {
      for (final MapEntry(:key, :value) in _sessionLost.entries)
        key.name: value,
    },
    'unexpectedShape': {..._unexpectedShape},
    'vaultUnavailable': vaultUnavailable,
    'tlsUntrusted': tlsUntrusted,
    'localNetworkDenied': localNetworkDenied,
    'coldStarts': coldStarts,
    'coldStartMs': [..._coldStartMs],
  };
}
