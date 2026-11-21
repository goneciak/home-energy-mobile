import 'package:flutter/foundation.dart';
import 'package:gi_core_api/gi_core_api.dart';

/// Where the connection ladder found a candidate (plan §9.2).
enum CandidateSource {
  /// One of the profile's remembered hosts (step 1).
  remembered,

  /// A `gi-home[-n].local` name that resolved (step 2).
  localName,
}

/// A confirmed GI Home: `/health/live` answered 200 and `/setup/status`
/// parsed (plan §9.2). The user still has to pick and confirm it.
@immutable
final class ApplianceCandidate {
  const new({required this.probe, required this.source, required this.rank});

  /// What the appliance answered; it feeds the confirmation card.
  final ProbeResult probe;

  final CandidateSource source;

  /// Position in the ladder: remembered hosts in profile order, then the
  /// `.local` names in order. Lower is listed first and wins when the same
  /// appliance answers on two addresses.
  final int rank;

  /// The appliance's own name, if it has one yet.
  String? get deviceName => probe.setup.deviceName;

  /// Normalised origin, e.g. `http://gi-home.local`.
  String get host => probe.address.origin.toString();

  bool get initialized => probe.setup.initialized;

  /// The fingerprint (plan §9.3); `null` while the appliance is not set up.
  DateTime? get fingerprint =>
      probe.setup.initialized ? probe.setup.initializedAt : null;

  @override
  bool operator ==(Object other) =>
      other is ApplianceCandidate &&
      other.host == host &&
      other.source == source &&
      other.rank == rank &&
      other.deviceName == deviceName &&
      other.fingerprint == fingerprint;

  @override
  int get hashCode => Object.hash(host, source, rank, deviceName, fingerprint);

  @override
  String toString() =>
      'ApplianceCandidate($host, ${source.name}, $deviceName, $fingerprint)';
}

/// Progress of one run of the connection ladder: the candidates confirmed
/// so far (growing, ordered by [ApplianceCandidate.rank]) and whether every
/// step has finished.
@immutable
final class ApplianceSearch {
  const new({this.candidates = const [], this.done = false, this.failure});

  /// The ladder has not finished any step yet.
  static const started = ApplianceSearch();

  final List<ApplianceCandidate> candidates;

  final bool done;

  /// Why the search could not look at all (local network access denied,
  /// plan §9.4), or the failure every probe ended with when nothing was
  /// found and it explains why (also local network access). `null`
  /// otherwise: "nothing found" is not a failure.
  final ApiFailure? failure;

  ApplianceSearch copyWith({
    List<ApplianceCandidate>? candidates,
    bool? done,
    ApiFailure? failure,
  }) => ApplianceSearch(
    candidates: candidates ?? this.candidates,
    done: done ?? this.done,
    failure: failure ?? this.failure,
  );

  @override
  bool operator ==(Object other) =>
      other is ApplianceSearch &&
      listEquals(other.candidates, candidates) &&
      other.done == done &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(Object.hashAll(candidates), done, failure);

  @override
  String toString() =>
      'ApplianceSearch(${candidates.length} found, done: $done'
      '${failure == null ? '' : ', $failure'})';
}
