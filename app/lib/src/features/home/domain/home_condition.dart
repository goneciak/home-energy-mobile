import 'package:gi_core_api/gi_core_api.dart';

import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:meta/meta.dart';

/// Overall condition of the home, from the mildest to the most severe.
enum ConditionLevel {
  good,

  /// Nothing known to be wrong, but the app cannot vouch for it: the
  /// appliance is unreachable, the data is outdated or devices report no
  /// data. Always wins over a false "good" (plan §11.1).
  limitedData,

  needsAttention,
  actionRequired;

  bool isWorseThan(ConditionLevel other) => index > other.index;
}

/// Why a device shows up in the attention list, ordered from most severe.
enum AttentionKind {
  /// Controller in FAULT or SAFE_MODE.
  firmwareFault(ConditionLevel.actionRequired),

  /// Connectivity ERROR.
  connectivityError(ConditionLevel.actionRequired),

  /// Active faults on a heating device.
  heatingFaults(ConditionLevel.actionRequired),

  /// Active faults on any other device.
  faults(ConditionLevel.needsAttention),

  /// No contact for 15 min; local control keeps working.
  offline(ConditionLevel.needsAttention),

  /// No contact for 5 min.
  stale(ConditionLevel.needsAttention),

  /// Heating suspended on a heating device.
  heatingSuspended(ConditionLevel.needsAttention),

  /// Relays do not switch physically.
  dryRun(ConditionLevel.needsAttention),

  /// The details of a heating card report `needs_configuration`.
  needsConfiguration(ConditionLevel.needsAttention),

  /// The details of a heating card could not be fetched.
  heatingDetailsUnavailable(ConditionLevel.limitedData),

  /// Never seen, provisioning or updating: nothing to judge by.
  noData(ConditionLevel.limitedData);

  new(this.level);

  final ConditionLevel level;
}

/// One reason a device needs a look.
@immutable
final class AttentionItem {
  const new(this.device, this.kind);

  final DeviceListItem device;
  final AttentionKind kind;

  @override
  bool operator ==(Object other) =>
      other is AttentionItem && other.device == device && other.kind == kind;

  @override
  int get hashCode => Object.hash(device, kind);

  @override
  String toString() => 'AttentionItem(${device.name}, ${kind.name})';
}

/// Why the condition cannot be stated with confidence.
enum LimitedDataReason {
  /// The latest refresh failed; the list shown is the last good one.
  refreshFailed,

  /// The list is older than [HomeCondition.outdatedAfter].
  outdated,

  /// The details of at least one heating card could not be fetched.
  heatingDetailsFailed,

  /// The appliance has no enabled devices.
  noDevices,
}

/// Condition of the home computed from the device list and the results of
/// the heating cards' detail requests (plan §11.1).
///
/// Disabled devices are ignored. Every enabled device contributes zero or
/// more [AttentionItem]s; the level is the most severe of the items and the
/// [limitedReasons].
final class HomeCondition {
  const new({
    required this.level,
    required this.items,
    required this.limitedReasons,
  });

  factory evaluate(
    Fetched<List<DeviceListItem>> devices, {
    required DateTime now,
    required bool refreshFailed,
    Map<String, PolledData<DeviceDetail>> heatingCards = const {},
  }) {
    final enabled = [
      for (final device in devices.value)
        if (device.enabled) device,
    ];
    final items = [
      for (final device in enabled)
        for (final kind in [
          ...attentionKindsOf(device),
          if (device.isHeating) ..._cardKinds(heatingCards[device.id]),
        ])
          AttentionItem(device, kind),
    ]..sort(_bySeverity);

    final limitedReasons = [
      if (refreshFailed) LimitedDataReason.refreshFailed,
      if (now.difference(devices.fetchedAt) > outdatedAfter)
        LimitedDataReason.outdated,
      if (items.any((i) => i.kind == AttentionKind.heatingDetailsUnavailable))
        LimitedDataReason.heatingDetailsFailed,
      if (enabled.isEmpty) LimitedDataReason.noDevices,
    ];

    var level = limitedReasons.isEmpty
        ? ConditionLevel.good
        : ConditionLevel.limitedData;
    for (final item in items) {
      if (item.kind.level.isWorseThan(level)) level = item.kind.level;
    }
    return HomeCondition(
      level: level,
      items: List.unmodifiable(items),
      limitedReasons: List.unmodifiable(limitedReasons),
    );
  }

  /// A list older than this is not trusted to say "good" (plan §11.1).
  static const outdatedAfter = Duration(minutes: 2);

  /// At most this many suggestions are shown (plan §11.1).
  static const maxSuggestions = 3;

  final ConditionLevel level;

  /// Every attention item, most severe first.
  final List<AttentionItem> items;

  final List<LimitedDataReason> limitedReasons;

  /// The most severe items, at most [maxSuggestions].
  List<AttentionItem> get suggestions => items.take(maxSuggestions).toList();

  /// Items not shown as [suggestions].
  int get hiddenItemCount =>
      items.length > maxSuggestions ? items.length - maxSuggestions : 0;

  /// What the list alone says about [device] (plan §11.1, §15).
  static Iterable<AttentionKind> attentionKindsOf(DeviceListItem device) sync* {
    if (device.currentState?.isCritical ?? false) {
      yield AttentionKind.firmwareFault;
    }
    switch (device.connectivityState) {
      case ConnectivityState.error:
        yield AttentionKind.connectivityError;
      case ConnectivityState.offline:
        yield AttentionKind.offline;
      case ConnectivityState.stale:
        yield AttentionKind.stale;
      case ConnectivityState.provisioning || ConnectivityState.unknown:
        yield AttentionKind.noData;
      case ConnectivityState.online:
        break;
    }
    if (device.activeFaultCount > 0) {
      yield device.isHeating
          ? AttentionKind.heatingFaults
          : AttentionKind.faults;
    }
    if (device.isHeating && device.heatingSuspended) {
      yield AttentionKind.heatingSuspended;
    }
    if (device.dryRun) yield AttentionKind.dryRun;
  }

  /// What the latest detail request of a heating card adds: a failure
  /// limits the data, and a product status of `needs_configuration` (only
  /// the details carry it) needs attention.
  static Iterable<AttentionKind> _cardKinds(
    PolledData<DeviceDetail>? card,
  ) sync* {
    if (card == null) return;
    if (card.error != null) yield AttentionKind.heatingDetailsUnavailable;
    if (card.data?.value.status == ProductStatus.needsConfiguration) {
      yield AttentionKind.needsConfiguration;
    }
  }

  static int _bySeverity(AttentionItem a, AttentionItem b) {
    final byKind = a.kind.index.compareTo(b.kind.index);
    return byKind != 0
        ? byKind
        : a.device.name.toLowerCase().compareTo(b.device.name.toLowerCase());
  }
}
