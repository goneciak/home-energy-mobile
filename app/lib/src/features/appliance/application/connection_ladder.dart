import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/appliance/data/multicast_dns_host_resolver.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_candidate.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_ladder.g.dart';

/// "Znajdź GI Home" (plan §9.2): looks for GI Home appliances without the
/// user typing an address.
///
/// 1. The profile's remembered hosts: `GET /health/live` must answer within
///    [rememberedTimeout] (1.5 s).
/// 2. [localNames] (`gi-home.local`, then `gi-home-2.local` …
///    `gi-home-5.local`, the names Avahi gives a first and further
///    appliances, §9.1) through the [HostResolver], probed as
///    `http://<name>` (port 80).
///
/// A candidate is confirmed when `/health/live` answers 200 and
/// `/setup/status` parses ([ApplianceProbe]). Both steps run at once:
/// resolving a name sends nothing to an appliance, and every probe holds
/// one slot of a limiter of [ConcurrencyLimiter.perApplianceRequests], so
/// even when every address leads to the same appliance it never sees more
/// requests in flight than plan §11 allows. Each probe sends its two
/// requests one after the other.
///
/// The `multicast_dns` fallback (spike S3) plugs in as another
/// [HostResolver]; the subnet sweep (v1.1) would be a third step here.
final class ConnectionLadder {
  new({
    required this._probe,
    required this._resolver,
    this.localNames = defaultLocalNames,
    this.rememberedTimeout = const Duration(milliseconds: 1500),
    this.candidateTimeout = const Duration(seconds: 6),
  });

  /// Avahi's names for the first five appliances on a network.
  static const defaultLocalNames = [
    'gi-home.local',
    'gi-home-2.local',
    'gi-home-3.local',
    'gi-home-4.local',
    'gi-home-5.local',
  ];

  final ApplianceProbe _probe;
  final HostResolver _resolver;
  final List<String> localNames;

  /// How long a remembered host may take to answer `/health/live`.
  final Duration rememberedTimeout;

  /// Upper bound for one whole probe, so the search always finishes.
  final Duration candidateTimeout;

  /// Runs the ladder once. Emits the confirmed candidates as they are found
  /// (a growing list ordered by rank; an appliance that answers on two
  /// addresses is listed once, under the first one) and finally a `done`
  /// state. Cancelling the subscription stops emitting; probes already sent
  /// run out on their own.
  Stream<ApplianceSearch> search({List<String> rememberedHosts = const []}) {
    var cancelled = false;
    late final StreamController<ApplianceSearch> controller;
    controller = StreamController<ApplianceSearch>(
      onListen: () => unawaited(
        _run(
          rememberedHosts,
          rememberedHealthTimeout: rememberedTimeout,
          emit: (search) {
            if (!cancelled) controller.add(search);
          },
        ).whenComplete(controller.close),
      ),
      onCancel: () => cancelled = true,
    );
    return controller.stream;
  }

  /// The plan §9.3 rebinding: the saved appliance did not answer on its
  /// address, so look for it under the `.local` names. Returns a candidate
  /// with the same fingerprint on another address ([rebindTarget]), or
  /// `null`.
  ///
  /// The saved address is probed again in the same search (and under the
  /// same limiter), with as much time as the `.local` names get: a restore
  /// that only timed out (a slow appliance, a transient error) must not
  /// move the profile while the appliance still answers there. The answer
  /// therefore waits until that probe has settled, and then comes as soon
  /// as it is known.
  ///
  /// The `.local` names are probed over `http` only, so an `https` profile
  /// is never rebound silently (no cleartext downgrade, TransportPolicy).
  Future<ApplianceCandidate?> findMoved(ApplianceProfile profile) {
    if (!profile.isInitialized || !profile.address.isCleartext) {
      return Future.value();
    }
    final moved = Completer<ApplianceCandidate?>();
    var savedSettled = false;
    var stays = false;
    ApplianceCandidate? target;
    void settle({bool done = false}) {
      if (moved.isCompleted) return;
      if (savedSettled && stays) {
        moved.complete();
      } else if (done || (savedSettled && target != null)) {
        moved.complete(target);
      }
    }

    unawaited(
      _run(
        [profile.baseUrl],
        rememberedHealthTimeout: null,
        onRememberedSettled: () {
          savedSettled = true;
          settle();
        },
        emit: (progress) {
          stays = progress.candidates.any(
            (c) =>
                c.host == profile.baseUrl &&
                profile.isSameAppliance(c.probe.setup),
          );
          target = rebindTarget(profile, progress.candidates);
          settle(done: progress.done);
        },
      ),
    );
    return moved.future;
  }

  /// [rememberedHealthTimeout] bounds `/health/live` of the remembered
  /// hosts (`null`: only [candidateTimeout]); [onRememberedSettled] runs
  /// once every remembered host has answered or failed.
  Future<void> _run(
    List<String> rememberedHosts, {
    required Duration? rememberedHealthTimeout,
    required void Function(ApplianceSearch search) emit,
    void Function()? onRememberedSettled,
  }) async {
    final limiter = ConcurrencyLimiter(ConcurrencyLimiter.perApplianceRequests);
    final probed = <String>{};
    final found = <ApplianceCandidate>[];
    final failures = <ApiFailure>[];

    void add(ApplianceCandidate candidate) {
      final same = found.indexWhere(
        (c) =>
            c.host == candidate.host ||
            (candidate.fingerprint != null &&
                c.fingerprint == candidate.fingerprint),
      );
      if (same >= 0) {
        if (found[same].rank <= candidate.rank) return;
        found.removeAt(same);
      }
      found
        ..add(candidate)
        ..sort((a, b) => a.rank.compareTo(b.rank));
      emit(ApplianceSearch(candidates: List.unmodifiable(found)));
    }

    Future<void> tryAddress(
      ApplianceAddress address,
      CandidateSource source,
      int rank, {
      Duration? healthTimeout,
    }) async {
      if (!probed.add(address.origin.toString())) return;
      try {
        final result = await limiter.run(
          () => _probe
              .probeAddress(address, healthTimeout: healthTimeout)
              .timeout(candidateTimeout),
        );
        add(ApplianceCandidate(probe: result, source: source, rank: rank));
      } on ApiFailure catch (failure) {
        failures.add(failure);
      } on TimeoutException {
        failures.add(const ApiFailure.timeout(reason: 'probe deadline'));
      }
    }

    Future<void> tryName(String name, int rank) async {
      final String? host;
      try {
        host = await _resolver.resolve(name);
      } on Object {
        return;
      }
      if (host == null) return;
      final ApplianceAddress address;
      try {
        address = ApplianceAddress.parse(host);
      } on FormatException {
        return;
      }
      await tryAddress(address, CandidateSource.localName, rank);
    }

    final remembered = <ApplianceAddress>[];
    for (final host in rememberedHosts) {
      try {
        remembered.add(ApplianceAddress.parse(host));
      } on FormatException {
        // A stored host that no longer parses is skipped.
      }
    }

    await Future.wait([
      Future.wait([
        for (final (i, address) in remembered.indexed)
          tryAddress(
            address,
            CandidateSource.remembered,
            i,
            healthTimeout: rememberedHealthTimeout,
          ),
      ]).whenComplete(() => onRememberedSettled?.call()),
      for (final (j, name) in localNames.indexed)
        tryName(name, remembered.length + j),
    ]);

    // Nothing answered, and the system said why: explain it (plan §9.4).
    final denied = found.isEmpty
        ? failures.whereType<LocalNetworkDeniedFailure>().firstOrNull
        : null;
    emit(
      ApplianceSearch(
        candidates: List.unmodifiable(found),
        done: true,
        failure: denied,
      ),
    );
  }
}

/// The candidate the saved [profile] should silently move to (plan §9.3),
/// or `null`: a `.local` candidate with the profile's fingerprint on
/// another address, unless the appliance also answers on its saved
/// address. Only `.local` names count, so two remembered IPs can never make
/// the profile jump back and forth; a remembered host is picked by the
/// user on the connect screen instead.
///
/// The candidate must use the profile's scheme: an `https` profile is never
/// moved to `http` without the user seeing the cleartext notice
/// (TransportPolicy: https is never silently downgraded).
ApplianceCandidate? rebindTarget(
  ApplianceProfile profile,
  List<ApplianceCandidate> candidates,
) {
  final same = [
    for (final c in candidates)
      if (profile.isSameAppliance(c.probe.setup)) c,
  ];
  if (same.any((c) => c.host == profile.baseUrl)) return null;
  final scheme = profile.address.origin.scheme;
  for (final c in same) {
    if (c.source == CandidateSource.localName &&
        c.probe.address.origin.scheme == scheme) {
      return c;
    }
  }
  return null;
}

/// Resolves the `.local` names of step 2. The dev flavor's mock Core
/// answers on any host, so there only `gi-home.local` "resolves", which
/// shows the found appliance without a network.
@Riverpod(keepAlive: true)
HostResolver hostResolver(Ref ref) {
  final mock =
      ref.watch(appFlavorProvider) == AppFlavor.dev &&
      ref.watch(featureFlagsProvider.select((f) => f.mockCore));
  if (mock) return const StaticHostResolver({'gi-home.local'});
  // The multicast DNS fallback asks only after the system gave up, and only
  // on Android: iOS resolves `.local` names itself (spike S3).
  final mdns =
      defaultTargetPlatform == TargetPlatform.android &&
      ref.watch(featureFlagsProvider.select((f) => f.mdnsFallback));
  return mdns
      ? const FirstHostResolver([
          SystemHostResolver(),
          MulticastDnsHostResolver(),
        ])
      : const SystemHostResolver();
}

/// Kept alive: the session restore uses it to rebind (plan §9.3).
@Riverpod(keepAlive: true)
ConnectionLadder connectionLadder(Ref ref) => ConnectionLadder(
  probe: ref.watch(applianceProbeProvider),
  resolver: ref.watch(hostResolverProvider),
);
