import 'package:gi_core_api/gi_core_api.dart';

import 'package:gi_home/src/core/data/fetched.dart';
import 'package:meta/meta.dart';

/// Where a merged value shown on device details comes from.
enum ValueSource {
  /// The cached element of `GET /devices`.
  deviceList,

  /// Parsed defensively from `diagnostics` of `GET /devices/:id`.
  diagnostics,
}

/// A value with its source and the time it was received, so the UI can
/// show both (plan §4.1).
@immutable
final class SourcedValue<T> {
  const new(this.value, this.source, this.receivedAt);

  final T value;
  final ValueSource source;
  final DateTime receivedAt;

  @override
  bool operator ==(Object other) =>
      other is SourcedValue<T> &&
      other.value == value &&
      other.source == source &&
      other.receivedAt == receivedAt;

  @override
  int get hashCode => Object.hash(value, source, receivedAt);
}

/// Controller state and active fault count of one device.
///
/// `GET /devices/:id` does not carry `currentState`/`activeFaultCount`
/// (plan §3.6); they come from the cached list item and from the device's
/// diagnostics. Each shown value is the more recently received of the two,
/// labelled with its source, and [needsAttention] takes the worst of both,
/// so a fault in either source is never hidden by the other (plan §12.7).
final class ControllerStatus {
  const new({
    this.currentState,
    this.activeFaultCount,
    this.needsAttention = false,
  });

  factory resolve({
    Fetched<DeviceListItem>? listItem,
    Fetched<DeviceDetail>? detail,
  }) {
    final listed = listItem?.value;
    final diagnostics = detail?.value.diagnostics;

    SourcedValue<T>? pick<T>(T? fromList, T? fromDiagnostics) {
      final list = fromList == null || listItem == null
          ? null
          : SourcedValue(fromList, ValueSource.deviceList, listItem.fetchedAt);
      final diag = fromDiagnostics == null || detail == null
          ? null
          : SourcedValue(
              fromDiagnostics,
              ValueSource.diagnostics,
              detail.fetchedAt,
            );
      if (list == null || diag == null) return list ?? diag;
      return diag.receivedAt.isAfter(list.receivedAt) ? diag : list;
    }

    bool alarming(FirmwareState? state, int? faults) =>
        (state?.isCritical ?? false) || (faults ?? 0) > 0;

    return ControllerStatus(
      currentState: pick(listed?.currentState, diagnostics?.currentState),
      activeFaultCount: pick(
        listed?.activeFaultCount,
        diagnostics?.activeFaultCount,
      ),
      needsAttention:
          alarming(listed?.currentState, listed?.activeFaultCount) ||
          alarming(diagnostics?.currentState, diagnostics?.activeFaultCount) ||
          (diagnostics?.safetyInterlockActive ?? false) ||
          (diagnostics?.rebootLoopDetected ?? false),
    );
  }

  final SourcedValue<FirmwareState>? currentState;
  final SourcedValue<int>? activeFaultCount;

  /// Fault or safe mode, any active fault, an active safety interlock or a
  /// reboot loop, reported by either source.
  final bool needsAttention;
}
