import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/features/home/domain/home_condition.dart';
import 'package:meta/meta.dart';

/// Weight of an entry of the "Uwaga" list, computed on the phone (plan §15):
/// critical, important, notice, and resolved (kept for 24 h locally).
enum AttentionSeverity { critical, important, notice, resolved }

/// What an [AttentionEntry] is about.
enum AttentionTopic {
  /// A device of `GET /devices`; see [AttentionEntry.kind].
  device,

  /// The signed-in user must change the password (`mustChangePassword`).
  mustChangePassword,
}

/// One line of the "Uwaga" list.
@immutable
final class AttentionEntry {
  const new({
    required this.key,
    required this.topic,
    required this.severity,
    this.device,
    this.kind,
    this.resolvedAt,
  });

  /// A device [kind] reported for [device].
  factory forDevice(DeviceListItem device, AttentionKind kind) =>
      AttentionEntry(
        key: '${device.id}/${kind.name}',
        topic: AttentionTopic.device,
        severity: severityOf(kind),
        device: device,
        kind: kind,
      );

  static const mustChangePassword = AttentionEntry(
    key: 'account/mustChangePassword',
    topic: AttentionTopic.mustChangePassword,
    severity: AttentionSeverity.important,
  );

  /// Stable identity across evaluations: device id and kind.
  final String key;
  final AttentionTopic topic;
  final AttentionSeverity severity;

  /// The device as last listed; `null` for account entries.
  final DeviceListItem? device;

  /// Why the device is listed; `null` for account entries.
  final AttentionKind? kind;

  /// When the entry stopped being reported; set only for resolved entries.
  final DateTime? resolvedAt;

  /// Severity of a device [kind] (plan §15): what stops heating or needs a
  /// visit is critical, a device out of reach or with faults is important,
  /// the rest is a notice.
  static AttentionSeverity severityOf(AttentionKind kind) => switch (kind) {
    AttentionKind.firmwareFault ||
    AttentionKind.connectivityError ||
    AttentionKind.heatingFaults => AttentionSeverity.critical,
    AttentionKind.faults ||
    AttentionKind.offline ||
    AttentionKind.heatingSuspended => AttentionSeverity.important,
    AttentionKind.stale ||
    AttentionKind.dryRun ||
    AttentionKind.needsConfiguration ||
    AttentionKind.heatingDetailsUnavailable ||
    AttentionKind.noData => AttentionSeverity.notice,
  };

  AttentionEntry resolved(DateTime at) => AttentionEntry(
    key: key,
    topic: topic,
    severity: AttentionSeverity.resolved,
    device: device,
    kind: kind,
    resolvedAt: at,
  );

  @override
  bool operator ==(Object other) =>
      other is AttentionEntry &&
      other.key == key &&
      other.severity == severity &&
      other.device == device &&
      other.resolvedAt == resolvedAt;

  @override
  int get hashCode => Object.hash(key, severity, device, resolvedAt);

  @override
  String toString() => 'AttentionEntry($key, ${severity.name})';
}

/// The "Uwaga" list: computed from `GET /devices` and the signed-in user
/// (plan §15). There is no acknowledging or snoozing; an entry leaves the
/// list when the condition clears and then shows as resolved for
/// [resolvedRetention].
///
/// Disabled devices are ignored, like on Home (plan §11.1).
@immutable
final class AttentionFeed {
  const new({
    required this.userId,
    required this.active,
    required this.resolved,
    this.devicesFetchedAt,
  });

  /// Nothing known yet.
  const new empty({this.userId})
    : active = const [],
      resolved = const [],
      devicesFetchedAt = null;

  /// The feed for [devices] and [mustChangePassword] at [now].
  ///
  /// Entries of [previous] (same [userId] only) that are no longer reported
  /// become resolved at [now]; resolved entries older than
  /// [resolvedRetention], or reported again, are dropped. Without a device
  /// list ([devices] `null`) the device entries of [previous] are kept as
  /// they were.
  factory derive({
    required String? userId,
    required Fetched<List<DeviceListItem>>? devices,
    required bool mustChangePassword,
    required DateTime now,
    AttentionFeed? previous,
  }) {
    final before = previous?.userId == userId ? previous : null;
    final List<AttentionEntry> active;
    if (devices == null) {
      active = [
        ...?before?.active.where((e) => e.topic == AttentionTopic.device),
        if (mustChangePassword) AttentionEntry.mustChangePassword,
      ];
    } else {
      active = [
        for (final device in devices.value)
          if (device.enabled)
            for (final kind in HomeCondition.attentionKindsOf(device))
              AttentionEntry.forDevice(device, kind),
        if (mustChangePassword) AttentionEntry.mustChangePassword,
      ];
    }
    active.sort(_byWeight);

    final activeKeys = {for (final entry in active) entry.key};
    final resolved = <AttentionEntry>[
      for (final entry in before?.active ?? const <AttentionEntry>[])
        if (!activeKeys.contains(entry.key)) entry.resolved(now),
      for (final entry in before?.resolved ?? const <AttentionEntry>[])
        if (!activeKeys.contains(entry.key) &&
            now.difference(entry.resolvedAt!) < resolvedRetention)
          entry,
    ];
    final seen = <String>{};
    resolved
      ..retainWhere((entry) => seen.add(entry.key))
      ..sort((a, b) => b.resolvedAt!.compareTo(a.resolvedAt!));

    return AttentionFeed(
      userId: userId,
      active: List.unmodifiable(active),
      resolved: List.unmodifiable(resolved),
      devicesFetchedAt: devices?.fetchedAt ?? before?.devicesFetchedAt,
    );
  }

  /// How long a resolved entry stays on the list (plan §15: 24 h, locally).
  static const resolvedRetention = Duration(hours: 24);

  final String? userId;

  /// Entries still reported, most severe first.
  final List<AttentionEntry> active;

  /// Entries that cleared within [resolvedRetention], newest first.
  final List<AttentionEntry> resolved;

  /// When the device list the feed comes from arrived.
  final DateTime? devicesFetchedAt;

  /// The number on the tab's badge: every entry still reported.
  int get badgeCount => active.length;

  bool get isEmpty => active.isEmpty && resolved.isEmpty;

  /// [active] entries of [severity].
  List<AttentionEntry> withSeverity(AttentionSeverity severity) => [
    for (final entry in active)
      if (entry.severity == severity) entry,
  ];

  static int _byWeight(AttentionEntry a, AttentionEntry b) {
    final bySeverity = a.severity.index.compareTo(b.severity.index);
    if (bySeverity != 0) return bySeverity;
    final byKind = (a.kind?.index ?? -1).compareTo(b.kind?.index ?? -1);
    if (byKind != 0) return byKind;
    return (a.device?.name.toLowerCase() ?? '').compareTo(
      b.device?.name.toLowerCase() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AttentionFeed &&
      other.userId == userId &&
      other.devicesFetchedAt == devicesFetchedAt &&
      _listEquals(other.active, active) &&
      _listEquals(other.resolved, resolved);

  @override
  int get hashCode => Object.hash(
    userId,
    devicesFetchedAt,
    Object.hashAll(active),
    Object.hashAll(resolved),
  );

  static bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
