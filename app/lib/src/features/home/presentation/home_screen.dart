import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/freshness_banner.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/permission_state.dart';
import 'package:gi_home/src/core/widgets/section_header.dart';
import 'package:gi_home/src/core/widgets/skeleton.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_list_notifier.dart';
import 'package:gi_home/src/features/devices/application/heating_suspension_controller.dart';
import 'package:gi_home/src/features/devices/application/rooms_notifier.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/presentation/device_tile.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/heating_control_panel.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/home/application/heating_card_notifier.dart';
import 'package:gi_home/src/features/home/application/home_dashboard.dart';
import 'package:gi_home/src/features/home/domain/device_groups.dart';
import 'package:gi_home/src/features/home/presentation/widgets/attention_list.dart';
import 'package:gi_home/src/features/home/presentation/widgets/condition_card.dart';
import 'package:gi_home/src/features/home/presentation/widgets/heating_card.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Dom": is everything OK at home? The condition of the home, what needs a
/// look, and every device grouped by room, heating devices as heating cards
/// (plan §4.1, §11.1). Read-only.
class HomeScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dashboard = ref.watch(homeDashboardProvider);
    if (dashboard.condition != null) {
      // One-shot: the first frame with the condition ends the cold start.
      ref.read(coldStartMeterProvider).homeConditionShown();
    }

    Future<void> refresh() => Future.wait([
      ref.read(deviceListProvider.notifier).refresh(),
      ref.read(roomsProvider.notifier).refresh(),
      // Only cards on screen exist; the others are fetched once in view.
      for (final device
          in dashboard.devices.data?.value ?? const <DeviceListItem>[])
        if (hasHeatingCard(device) &&
            ref.read(heatingCardProvider(device.id).exists))
          ref.read(heatingCardProvider(device.id).notifier).refresh(),
    ]);

    final devices = dashboard.devices;
    final Widget body;
    if (devices.data == null) {
      body = switch (devices.error) {
        null => const _HomeSkeleton(),
        // No "Try again" (plan §7.5); pulling down still asks once more.
        final ForbiddenFailure error => RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [PermissionState(error: error)],
          ),
        ),
        final error => Center(
          child: SingleChildScrollView(
            child: ErrorState(error: error, onRetry: refresh),
          ),
        ),
      };
    } else {
      body = RefreshIndicator(
        onRefresh: refresh,
        child: _Dashboard(dashboard: dashboard),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: body,
    );
  }
}

/// The first load: the condition card, a heating card and device rows.
class _HomeSkeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final gap = SizedBox(height: tokens.gap);
    return Skeleton(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(tokens.gap),
        children: [
          const SkeletonBlock.card(height: 112),
          gap,
          const SkeletonBlock(width: 140),
          gap,
          const SkeletonBlock.card(height: 150),
          gap,
          for (var i = 0; i < 3; i++) ...[
            const SkeletonBlock.card(height: 64),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const new({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final data = dashboard.devices.data!;
    final condition = dashboard.condition!;
    final now = dashboard.now;
    void openDevice(String id) => context.go(AppRoutes.device(id));

    final gap = SizedBox(height: tokens.gap);
    final edge = EdgeInsets.symmetric(horizontal: tokens.gap);
    final roomsFailed =
        dashboard.rooms.data == null && dashboard.rooms.error != null;

    // The list inflates its rows lazily (only those in or near the
    // viewport), so a heating card out of view is never built and its
    // details are not polled (plan §4.1, §11).
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: tokens.gap / 2, bottom: tokens.gap * 2),
      children: [
        Padding(
          padding: edge,
          child: FreshnessBanner(
            fetchedAt: data.fetchedAt,
            error: dashboard.devices.error,
            isStale: dashboard.isStale,
            now: now,
          ),
        ),
        gap,
        Padding(
          padding: edge,
          child: ConditionCard(
            condition: condition,
            fetchedAt: data.fetchedAt,
            now: now,
          ),
        ),
        if (condition.suggestions.isNotEmpty) ...[
          SectionHeader(l10n.homeAttentionSection),
          Padding(
            padding: edge,
            child: AttentionList(
              condition: condition,
              onOpenDevice: openDevice,
            ),
          ),
        ],
        if (data.value.isEmpty)
          EmptyState(
            icon: Icons.devices_other,
            title: l10n.homeEmptyTitle,
            body: l10n.homeEmptyBody,
          ),
        if (roomsFailed && data.value.isNotEmpty) ...[
          gap,
          Padding(
            padding: edge,
            child: MessageBanner(
              tone: MessageTone.info,
              message: l10n.roomsUnavailableBanner,
            ),
          ),
        ],
        for (final group in dashboard.groups) ...[
          SectionHeader(_groupTitle(l10n, group)),
          for (final device in group.devices)
            Padding(
              padding: edge.add(const EdgeInsets.only(bottom: 8)),
              child: hasHeatingCard(device)
                  ? _HeatingCardSlot(
                      key: ValueKey('device-${device.id}'),
                      device: device,
                      listFetchedAt: data.fetchedAt,
                      roomName: dashboard.roomName(device.roomId),
                      now: now,
                      onTap: () => openDevice(device.id),
                    )
                  : DeviceTile(
                      key: ValueKey('device-${device.id}'),
                      device: device,
                      now: now,
                      onTap: () => openDevice(device.id),
                    ),
            ),
        ],
        gap,
        ListTile(
          key: const ValueKey('home-weather'),
          leading: const Icon(Icons.wb_cloudy_outlined),
          title: Text(l10n.weatherEntryTitle),
          subtitle: Text(l10n.weatherEntrySubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(AppRoutes.weather),
        ),
      ],
    );
  }

  static String _groupTitle(AppLocalizations l10n, DeviceGroup group) =>
      switch (group.kind) {
        DeviceGroupKind.room => group.room!.name,
        DeviceGroupKind.unassigned => l10n.homeNoRoom,
        DeviceGroupKind.all => l10n.homeDevicesSection,
      };
}

/// A heating card that polls its details only while it is built, i.e. while
/// it is on screen (plan §4.1, §11).
class _HeatingCardSlot extends ConsumerWidget {
  const new({
    required this.device,
    required this.listFetchedAt,
    required this.roomName,
    required this.now,
    required this.onTap,
    super.key,
  });

  final DeviceListItem device;
  final DateTime listFetchedAt;
  final String? roomName;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(heatingCardProvider(device.id));
    final provider = heatingSuspensionControllerProvider(device.id);
    // Watched so a resume started here outlives the sheet (plan §12.1).
    final command = ref.watch(provider);
    final fetched = detail.data;

    Future<void> resume(Fetched<DeviceDetail> fetched) async {
      if (await showResumeSheet(context, detail: fetched, now: now)) {
        await ref
            .read(provider.notifier)
            .submit(suspend: false, freshness: FreshnessPolicy.heatingCard);
      }
    }

    return HeatingCard(
      device: device,
      listFetchedAt: listFetchedAt,
      detail: detail,
      roomName: roomName,
      now: now,
      onTap: onTap,
      freshness: ref.watch(heatingCardPolicyProvider),
      permission: HeatingPermission.of(
        ref.watch(currentUserProvider.select((user) => user?.role)),
      ),
      onResume: fetched == null || command.isBusy
          ? null
          : () => resume(fetched),
      commandStatus: SuspensionOutcome.visible(command)
          ? SuspensionOutcome(
              state: command,
              now: now,
              onRefresh: () => ref.read(provider.notifier).refresh(),
            )
          : null,
    );
  }
}
