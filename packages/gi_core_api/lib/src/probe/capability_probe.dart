import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/catalog/endpoints.dart';
import 'package:gi_core_api/src/failures/api_failure.dart';
import 'package:gi_core_api/src/gi_core_client.dart';
import 'package:gi_core_api/src/models/enums.dart';
import 'package:meta/meta.dart';

/// An optional GI Core feature found by a capability probe (plan §16 pt 2).
enum CoreCapability {
  /// Heating schedules (`GET /devices/:id/schedules`).
  schedules,

  /// The PV heating plan (`GET /devices/:id/pv-heating-plan`).
  pvPlan,

  /// Entity history (`GET /devices/:d/entities/:e/history?limit=1`).
  history,

  /// The session list (`GET /auth/sessions`).
  sessions;

  /// The cheap GET that probes this capability. Weather and the PV forecast
  /// are never probed by status: their 503/400 mean "no data", not "no
  /// route".
  Endpoint get endpoint => switch (this) {
    schedules => GiEndpoints.schedulesList,
    pvPlan => GiEndpoints.pvHeatingPlan,
    history => GiEndpoints.entityHistory,
    sessions => GiEndpoints.authSessionsList,
  };
}

/// What a probe found out about one [CoreCapability].
enum CapabilityStatus {
  /// The route answered (a 2xx, a domain 404 or a validation error).
  present,

  /// `HTTP_404`: this GI Core version has no such route.
  absent,

  /// Not probed (the role may not call it) or the probe failed for another
  /// reason (offline, 5xx, …). The feature stays visible.
  unknown,
}

/// Classifies how a probe request ended: `null` [error] is a success.
///
/// `HTTP_404` ([RouteAbsentFailure]) is the only proof that a route is
/// missing. A domain 404 (`DEVICE_NOT_FOUND`, `DEVICE_ENTITY_NOT_FOUND`,
/// `HEATING_SCHEDULE_NOT_FOUND`, `RESOURCE_NOT_FOUND`, …) or a 400
/// (`VALIDATION_FAILED`, or the `HTTP_400` of a path pipe) came from
/// the route's own handler, so the feature is there.
CapabilityStatus classifyProbeOutcome(Object? error) => switch (error) {
  null => CapabilityStatus.present,
  RouteAbsentFailure() => CapabilityStatus.absent,
  NotFoundFailure() ||
  ValidationFailure() ||
  DomainFailure(statusCode: 400) => CapabilityStatus.present,
  _ => CapabilityStatus.unknown,
};

/// The probe results of one GI Core instance; immutable.
@immutable
final class CoreCapabilities {
  /// [statuses] for the capabilities it names; the others are unknown.
  new([Map<CoreCapability, CapabilityStatus> statuses = const {}])
    : _statuses = Map.unmodifiable({
        for (final c in CoreCapability.values)
          c: statuses[c] ?? CapabilityStatus.unknown,
      });

  /// Nothing probed yet: every feature stays visible.
  static final CoreCapabilities unprobed = CoreCapabilities();

  final Map<CoreCapability, CapabilityStatus> _statuses;

  CapabilityStatus operator [](CoreCapability capability) =>
      _statuses[capability]!;

  /// Whether the UI shows [capability]: hidden only when the route was
  /// proven absent, so a failed probe never hides a working feature.
  bool isAvailable(CoreCapability capability) =>
      this[capability] != CapabilityStatus.absent;

  /// Whether some probe ended without a verdict (worth asking again later).
  bool get hasUnknown => _statuses.values.contains(CapabilityStatus.unknown);

  @override
  bool operator ==(Object other) =>
      other is CoreCapabilities &&
      CoreCapability.values.every((c) => other[c] == this[c]);

  @override
  int get hashCode => Object.hashAll(_statuses.values);

  @override
  String toString() {
    final parts = [
      for (final c in CoreCapability.values) '${c.name}: ${this[c].name}',
    ];
    return 'CoreCapabilities(${parts.join(', ')})';
  }
}

/// Runs the cheap probe request of one capability; completes normally when
/// the route answered 2xx and throws the [ApiFailure] otherwise.
typedef CapabilityCheck = Future<void> Function();

/// Sondowanie funkcji (plan §16 pt 2): one cheap authenticated GET per
/// optional feature, only for roles the catalog allows (no 403s).
///
/// The device and entity ids are placeholders that exist nowhere, so a
/// present route answers with a domain 404 (or a validation error) without
/// reading any data, and a missing route answers `HTTP_404`.
final class CapabilityProbe {
  /// Probes through [client].
  factory(GiCoreClient client) => CapabilityProbe.withChecks({
    CoreCapability.schedules: () => client.schedules(placeholderDeviceId),
    CoreCapability.pvPlan: () => client.pvHeatingPlan(placeholderDeviceId),
    CoreCapability.history: () => client.entityHistory(
      placeholderDeviceId,
      placeholderEntityId,
      limit: 1,
    ),
    CoreCapability.sessions: client.authSessions,
  });

  /// Probes with custom checks (tests); a capability without a check
  /// stays unknown.
  new withChecks(this._checks);

  /// A valid v4 UUID that no device has.
  static const placeholderDeviceId = '00000000-0000-4000-8000-000000000000';

  /// An entity id that no entity has.
  static const placeholderEntityId = 'gi-home-capability-probe';

  final Map<CoreCapability, CapabilityCheck> _checks;

  /// Probes every capability [role] may call, all at once.
  Future<CoreCapabilities> probe(UserRole role) async {
    final entries = await Future.wait([
      for (final capability in CoreCapability.values)
        _probeOne(capability, role).then((status) => (capability, status)),
    ]);
    return CoreCapabilities({
      for (final (capability, status) in entries) capability: status,
    });
  }

  Future<CapabilityStatus> _probeOne(
    CoreCapability capability,
    UserRole role,
  ) async {
    final check = _checks[capability];
    if (check == null || !capability.endpoint.allows(role)) {
      return CapabilityStatus.unknown;
    }
    try {
      await check();
      return classifyProbeOutcome(null);
    } on Object catch (error) {
      return classifyProbeOutcome(error);
    }
  }
}
