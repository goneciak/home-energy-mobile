import 'package:gi_core_api/gi_core_api.dart';
import 'package:meta/meta.dart';

/// What the signed-in user may do with heating (plan §2, §12.8).
///
/// Derived from the endpoint catalog (`Endpoint.allows`), never from a
/// hard-coded role list, so the app follows the backend's `@Roles`. A 403
/// from GI Core is still handled: this only decides what is shown.
@immutable
final class HeatingPermission {
  const new({
    required this.canSwitch,
    required this.canSuspend,
    required this.canEditStrategy,
  });

  /// Permission of [role]; `null` (role not known yet) controls nothing.
  factory of(UserRole? role) {
    bool allows(Endpoint endpoint) => role != null && endpoint.allows(role);
    return HeatingPermission(
      canSwitch: allows(GiEndpoints.setSwitchState),
      canSuspend: allows(GiEndpoints.updateDevice),
      canEditStrategy: allows(GiEndpoints.updateControlStrategy),
    );
  }

  /// `PUT /devices/:id/entities/:entityId/state`.
  final bool canSwitch;

  /// `PATCH /devices/:id {"heatingSuspended": bool}`.
  final bool canSuspend;

  /// `PATCH /devices/:id/control-strategy`.
  final bool canEditStrategy;

  /// Whether any heating control is shown. Otherwise the controls are
  /// hidden and the view-only hint is displayed instead.
  bool get canControl => canSwitch || canSuspend || canEditStrategy;

  bool get isViewOnly => !canControl;
}
