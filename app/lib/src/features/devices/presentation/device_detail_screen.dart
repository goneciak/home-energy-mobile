import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/freshness_banner.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/permission_state.dart';
import 'package:gi_home/src/core/widgets/section_header.dart';
import 'package:gi_home/src/core/widgets/skeleton.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_list_notifier.dart';
import 'package:gi_home/src/features/devices/application/rooms_notifier.dart';
import 'package:gi_home/src/features/devices/domain/controller_status.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/switch_command_state.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/heating_control_panel.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/switch_command_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Szczegóły urządzenia" (plan §4.1): state, information,
/// operating modes, entities and diagnostics of one device, polled every
/// 5 s while visible (15 s after 2 min without a touch or scroll, plan §11).
/// Controller state and fault count come from the cached device list, each
/// labelled with its source and time. Switch entities get a non-optimistic
/// control for OWNER/ADMIN ([SwitchEntityControl], plan §12.2).
class DeviceDetailScreen extends ConsumerWidget {
  const new({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(deviceDetailProvider(deviceId));
    final list = ref.watch(deviceListProvider).data;
    final rooms = ref.watch(roomsProvider).data?.value;
    final now = ref.watch(clockProvider)();

    Future<void> refresh() => Future.wait([
      ref.read(deviceDetailProvider(deviceId).notifier).refresh(),
      ref.read(deviceListProvider.notifier).refresh(),
    ]);

    final notifier = ref.read(deviceDetailProvider(deviceId).notifier);
    final data = detail.data;
    final error = detail.error;
    final Widget body;
    if (data != null) {
      final listItem = list?.value.where((d) => d.id == deviceId).firstOrNull;
      final roomId = data.value.roomId;
      final freshness = notifier.freshnessOf(data.fetchedAt);
      body = RefreshIndicator(
        onRefresh: refresh,
        child: _DeviceDetailView(
          detail: data,
          error: error,
          freshness: freshness,
          isStale: freshness.isStale(data.fetchedAt, now),
          now: now,
          deviceType: listItem?.type ?? DeviceType.unknown,
          status: ControllerStatus.resolve(
            listItem: listItem == null
                ? null
                : Fetched(listItem, list!.fetchedAt),
            detail: data,
          ),
          roomName: roomId == null
              ? l10n.homeNoRoom
              : rooms?.where((r) => r.id == roomId).firstOrNull?.name,
        ),
      );
    } else if (error is NotFoundFailure) {
      body = Center(
        child: EmptyState(
          icon: Icons.search_off,
          title: l10n.deviceNotFound,
          action: OutlinedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(l10n.actionClose),
          ),
        ),
      );
    } else if (error is ForbiddenFailure) {
      // No "Try again" (plan §7.5); pulling down still asks once more.
      body = RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            PermissionState(
              error: error,
              action: OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l10n.actionClose),
              ),
            ),
          ],
        ),
      );
    } else if (error != null) {
      body = Center(
        child: SingleChildScrollView(
          child: ErrorState(error: error, onRetry: refresh),
        ),
      );
    } else {
      body = const _DeviceDetailSkeleton();
    }

    // Any touch or scroll keeps the 5 s cadence (plan §11).
    void active() => notifier.userActive();
    return Listener(
      onPointerDown: (_) => active(),
      onPointerMove: (_) => active(),
      onPointerSignal: (_) => active(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          active();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(data?.value.name ?? l10n.deviceDetailsTitle),
          ),
          body: body,
        ),
      ),
    );
  }
}

/// The first load: the header card, then rows of the sections.
class _DeviceDetailSkeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    return Skeleton(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(tokens.gap),
        children: [
          const SkeletonBlock.card(height: 140),
          SizedBox(height: tokens.gap * 1.5),
          for (var section = 0; section < 2; section++) ...[
            const SkeletonBlock(width: 120),
            SizedBox(height: tokens.gap),
            for (var row = 0; row < 3; row++) ...[
              const SkeletonBlock(height: 18),
              SizedBox(height: tokens.gap),
            ],
            SizedBox(height: tokens.gap / 2),
          ],
        ],
      ),
    );
  }
}

class _DeviceDetailView extends StatelessWidget {
  const new({
    required this.detail,
    required this.error,
    required this.freshness,
    required this.isStale,
    required this.now,
    required this.deviceType,
    required this.status,
    required this.roomName,
  });

  final Fetched<DeviceDetail> detail;
  final Object? error;
  final FreshnessPolicy freshness;
  final bool isStale;
  final DateTime now;

  /// Only the device list carries the type.
  final DeviceType deviceType;
  final ControllerStatus status;

  /// `null` when the room is not known (yet).
  final String? roomName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final device = detail.value;
    final edge = EdgeInsets.symmetric(horizontal: tokens.gap);
    final banners = <Widget>[
      FreshnessBanner(
        fetchedAt: detail.fetchedAt,
        error: error,
        isStale: isStale,
        now: now,
      ),
      if (!device.enabled)
        MessageBanner(
          tone: MessageTone.info,
          message: l10n.deviceDisabledBanner,
        ),
      if (status.needsAttention)
        MessageBanner(message: l10n.deviceNeedsAttention),
      if (device.isHeating && device.heatingSuspended)
        MessageBanner(
          tone: MessageTone.warning,
          message: l10n.heatingSuspendedBanner,
        ),
      if (device.dryRun)
        MessageBanner(tone: MessageTone.warning, message: l10n.dryRunBanner),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: tokens.gap / 2, bottom: tokens.gap * 2),
      children: [
        for (final banner in banners)
          Padding(
            padding: edge.add(const EdgeInsets.only(bottom: 8)),
            child: banner,
          ),
        Padding(
          padding: edge,
          child: _Header(device: device, type: deviceType, now: now),
        ),
        if (device.isHeating)
          HeatingControlPanel(
            key: const ValueKey('heating-control-panel'),
            detail: detail,
            freshness: freshness,
            now: now,
          ),
        SectionHeader(l10n.deviceStatusSection),
        _ControllerStatusRows(status: status, now: now),
        SectionHeader(l10n.deviceInfoSection),
        _InfoRow(l10n.deviceManufacturer, device.manufacturer),
        _InfoRow(l10n.deviceModel, device.model),
        _InfoRow(l10n.deviceFirmware, device.firmwareVersion, monospace: true),
        _InfoRow(l10n.deviceRoom, roomName),
        SectionHeader(l10n.deviceFlagsSection),
        if (device.isHeating) _InfoRow(l10n.homeHeatingDevice, l10n.commonYes),
        _FlagRow(
          l10n.deviceFlagHeatingSuspended,
          active: device.heatingSuspended,
        ),
        _FlagRow(l10n.deviceFlagDryRun, active: device.dryRun),
        _FlagRow(l10n.deviceFlagPvBoost, active: device.pvBoostActive),
        SectionHeader(l10n.deviceEntitiesSection),
        if (device.entities.isEmpty)
          _MutedNote(l10n.deviceEntitiesEmpty)
        else
          for (final entity in device.entities) ...[
            _EntityTile(device: device, entity: entity, now: now),
            if (entity.domain == EntityDomain.switch_)
              SwitchEntityControl(
                key: ValueKey('switch-control-${entity.id}'),
                detail: detail,
                entity: entity,
                freshness: freshness,
                now: now,
              ),
          ],
        SectionHeader(l10n.deviceDiagnosticsSection),
        ..._diagnosticsRows(l10n, device.diagnostics),
      ],
    );
  }

  static List<Widget> _diagnosticsRows(
    AppLocalizations l10n,
    DeviceDiagnostics? diagnostics,
  ) {
    String? yesNo({required bool? value}) =>
        value == null ? null : (value ? l10n.commonYes : l10n.commonNo);
    final rows = [
      if (diagnostics != null) ...[
        (l10n.deviceDiagActiveFaults, diagnostics.activeFaultCount?.toString()),
        (
          l10n.deviceDiagSafetyInterlock,
          yesNo(value: diagnostics.safetyInterlockActive),
        ),
        (
          l10n.deviceDiagWifiRssi,
          switch (diagnostics.wifiRssi) {
            final rssi? => l10n.signalDbm(rssi),
            null => null,
          },
        ),
        (
          l10n.deviceDiagUptime,
          switch (diagnostics.uptime) {
            final uptime? => formatDuration(l10n, uptime),
            null => null,
          },
        ),
        (l10n.deviceDiagBootCount, diagnostics.bootCount?.toString()),
        (
          l10n.deviceDiagRebootLoop,
          yesNo(value: diagnostics.rebootLoopDetected),
        ),
      ],
    ].where((row) => row.$2 != null).toList();
    if (rows.isEmpty) return [_MutedNote(l10n.deviceDiagnosticsEmpty)];
    return [for (final (label, value) in rows) _InfoRow(label, value)];
  }
}

class _Header extends StatelessWidget {
  const new({required this.device, required this.type, required this.now});

  final DeviceDetail device;
  final DeviceType type;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final connectivity = connectivityLook(l10n, device.connectivityState);
    final product = productStatusLook(l10n, device.status);
    final description = device.description;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
        side: device.isHeating
            ? BorderSide(color: tokens.ember.withValues(alpha: 0.7))
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  deviceIcon(type: type, isHeating: device.isHeating),
                  color: device.isHeating ? tokens.ember : tokens.textMuted,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(device.name, style: textTheme.titleLarge)),
              ],
            ),
            if (description != null && description.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description, style: textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Semantics(
                  label: l10n.deviceConnectivity,
                  child: StatusChip(
                    label: connectivity.label,
                    icon: connectivity.icon,
                    tone: connectivity.tone,
                  ),
                ),
                Semantics(
                  label: l10n.deviceProductStatus,
                  child: StatusChip(
                    label: product.label,
                    icon: product.icon,
                    tone: product.tone,
                  ),
                ),
              ],
            ),
            if (device.connectivityState == ConnectivityState.offline) ...[
              const SizedBox(height: 8),
              Text(l10n.connectivityLostLocalControl),
            ],
            const SizedBox(height: 8),
            Text(
              lastSeenLabel(l10n, device.lastSeenAt, now),
              style: textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControllerStatusRows extends StatelessWidget {
  const new({required this.status, required this.now});

  final ControllerStatus status;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = status.currentState;
    final faults = status.activeFaultCount;
    final stateLook = state == null
        ? null
        : firmwareStateLook(l10n, state.value);
    return Column(
      children: [
        ListTile(
          key: const ValueKey('controller-state'),
          leading: Icon(stateLook?.icon ?? Icons.memory),
          title: Text(l10n.deviceControllerState),
          subtitle: state == null ? null : Text(_sourceLabel(l10n, state)),
          trailing: Text(
            stateLook?.label ?? l10n.commonNoDataValue,
            semanticsLabel: stateLook == null ? l10n.commonNoData : null,
          ),
        ),
        ListTile(
          key: const ValueKey('active-faults'),
          leading: const Icon(Icons.warning_amber_rounded),
          title: Text(l10n.deviceFaults),
          subtitle: faults == null ? null : Text(_sourceLabel(l10n, faults)),
          trailing: Text(
            faults == null
                ? l10n.commonNoDataValue
                : l10n.faultsCount(faults.value),
            semanticsLabel: faults == null ? l10n.commonNoData : null,
          ),
        ),
      ],
    );
  }

  String _sourceLabel(AppLocalizations l10n, SourcedValue<Object> value) {
    final time = formatClockTime(l10n, value.receivedAt, now);
    return switch (value.source) {
      ValueSource.deviceList => l10n.deviceValueFromList(time),
      ValueSource.diagnostics => l10n.deviceValueFromDiagnostics(time),
    };
  }
}

class _EntityTile extends StatelessWidget {
  const new({required this.device, required this.entity, required this.now});

  final DeviceDetail device;
  final DeviceEntity entity;
  final DateTime now;

  /// A GI Edge switch shows only what the device reported, never the value
  /// GI Core writes on enqueue (plan §12.2); `null` for everything else.
  String? _switchValue(AppLocalizations l10n) {
    if (entity.domain != EntityDomain.switch_ ||
        device.communicationMode != CommunicationMode.giEdgeV1) {
      return null;
    }
    return switch (reportedSwitchState(device, entity)) {
      true => l10n.entityValueOn,
      false => l10n.entityValueOff,
      null when entity.value is EntityValueBoolean =>
        l10n.entitySwitchAwaitingReport,
      null => l10n.commonNoDataValue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final role = switch (entity.id) {
      final id when id == device.heatingRelayEntityId =>
        l10n.entityRoleHeatingRelay,
      final id when id == device.pumpRelayEntityId => l10n.entityRolePumpRelay,
      final id when id == device.controlTemperatureEntityId =>
        l10n.entityRoleControlTemperature,
      _ => null,
    };
    final usable = entity.enabled && entity.availability;
    final value = !entity.enabled
        ? l10n.entityDisabled
        : !entity.availability
        ? l10n.entityUnavailable
        : _switchValue(l10n) ??
              formatEntityValue(
                l10n,
                entity.value,
                unit: entity.unit,
                deviceClass: entity.deviceClass,
              );
    final subtitle = [
      ?role,
      entityDomainLabel(l10n, entity.domain),
      lastSeenLabel(l10n, entity.lastSeenAt, now),
    ].join(' · ');
    return ListTile(
      key: ValueKey('entity-${entity.id}'),
      title: Text(entity.displayName),
      subtitle: Text(subtitle),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          value,
          // "—" alone reads as nothing to a screen reader (plan §13.3).
          semanticsLabel: value == l10n.commonNoDataValue
              ? l10n.commonNoData
              : null,
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: switch (Theme.of(context).textTheme.titleMedium) {
            // A reading is set like the web panel's metrics: mono, tabular.
            final style when usable => GiFonts.monospace(
              style,
            ).copyWith(color: tokens.text),
            final style => style?.copyWith(color: tokens.textMuted),
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const new(this.label, this.value, {this.monospace = false});

  final String label;
  final String? value;

  /// Sets a technical value (e.g. a firmware version) in the mono font.
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = this.value;
    final missing = value == null || value.trim().isEmpty;
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(
        missing ? l10n.commonNoDataValue : value,
        semanticsLabel: missing ? l10n.commonNoData : null,
        style: switch (Theme.of(context).textTheme.bodyLarge) {
          final style when monospace && !missing => GiFonts.monospace(style),
          final style => style,
        },
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  const new(this.label, {required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _InfoRow(label, active ? l10n.commonYes : l10n.commonNo);
  }
}

class _MutedNote extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: GiTokens.of(context).textMuted),
    ),
  );
}
