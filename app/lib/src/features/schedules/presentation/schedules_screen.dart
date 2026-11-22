import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/open_app_settings_button.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/schedules/application/schedule_providers.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_window.dart';
import 'package:gi_home/src/features/schedules/presentation/schedule_labels.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Harmonogramy" of one heating device (plan §20 M3): every schedule in
/// the order GI Core applies them, with the one active now (inferred on the
/// phone), readable by every role. OWNER and ADMIN add and edit; the others
/// see "Zmiany ogrzewania może wprowadzić właściciel.".
class SchedulesScreen extends ConsumerWidget {
  const new({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final schedules = ref.watch(schedulesProvider(deviceId));
    final canEdit = ref.watch(canEditSchedulesProvider);
    final clock = ref.watch(scheduleClockProvider);
    final now = ref.watch(clockProvider)();
    Future<void> refresh() =>
        ref.read(schedulesProvider(deviceId).notifier).refresh();

    final Widget body;
    if (schedules.hasValue) {
      body = RefreshIndicator(
        onRefresh: refresh,
        child: ScheduleList(
          schedules: schedules.requireValue,
          clock: clock,
          now: now,
          canEdit: canEdit,
          refreshError: schedules.error,
          onRefresh: refresh,
          onOpen: (schedule) =>
              context.go(AppRoutes.editSchedule(deviceId, schedule.id)),
        ),
      );
    } else if (schedules.error case final error?) {
      body = ErrorState(error: error, onRetry: refresh);
    } else {
      body = const LoadingView();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.schedulesTitle)),
      // A bar below the list, not a floating button: at large text sizes
      // a floating button would cover the banners and cards beneath it.
      bottomNavigationBar: canEdit && schedules.hasValue
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.all(GiTokens.of(context).gap),
                child: FilledButton.icon(
                  key: const ValueKey('schedule-add'),
                  onPressed: () => context.go(AppRoutes.newSchedule(deviceId)),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.schedulesAdd),
                ),
              ),
            )
          : null,
      body: body,
    );
  }
}

/// The schedule list itself, without loading: the clock label, the order
/// rule, the view-only hint and one card per schedule.
class ScheduleList extends StatelessWidget {
  const new({
    required this.schedules,
    required this.clock,
    required this.now,
    required this.canEdit,
    required this.onOpen,
    this.refreshError,
    this.onRefresh,
    super.key,
  });

  /// Why the latest reload failed while this (older) list stays on screen;
  /// `null` when the list is current.
  final Object? refreshError;

  /// Reloads the list; offered as a button on the stale-list banner, so the
  /// refresh does not depend on the pull gesture.
  final Future<void> Function()? onRefresh;

  /// Oldest first, as GI Core returns them.
  final List<HeatingSchedule> schedules;
  final ScheduleClock clock;
  final DateTime now;
  final bool canEdit;
  final ValueChanged<HeatingSchedule> onOpen;

  Widget? _refreshAction(BuildContext context, Object error) {
    final onRefresh = this.onRefresh;
    final extra = failureAction(error);
    if (onRefresh == null) return extra;
    return Wrap(
      children: [
        TextButton.icon(
          key: const ValueKey('schedules-refresh'),
          onPressed: () => unawaited(onRefresh()),
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.actionRetry),
        ),
        ?extra,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final active = ActiveSchedule.of(schedules, now.toUtc());
    final edge = EdgeInsets.symmetric(horizontal: tokens.gap);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: tokens.gap / 2),
      children: [
        if (refreshError case final error?)
          Padding(
            padding: edge.add(const EdgeInsets.only(bottom: 8)),
            child: MessageBanner(
              key: const ValueKey('schedules-refresh-failed'),
              tone: MessageTone.warning,
              message: error is UnreachableFailure || error is TimeoutFailure
                  ? l10n.schedulesOfflineBanner
                  : l10n.schedulesRefreshFailedBanner,
              detail: error is UnreachableFailure || error is TimeoutFailure
                  ? null
                  : failureMessage(l10n, error),
              action: _refreshAction(context, error),
            ),
          ),
        if (!canEdit)
          Padding(
            padding: edge.add(const EdgeInsets.only(bottom: 8)),
            child: MessageBanner(
              key: const ValueKey('schedules-view-only'),
              tone: MessageTone.info,
              message: l10n.heatingViewOnlyHint,
            ),
          ),
        Padding(
          padding: edge.add(const EdgeInsets.only(bottom: 8)),
          child: MessageBanner(
            key: const ValueKey('schedules-clock'),
            tone: MessageTone.info,
            message: clockLabel(l10n, clock, now: now),
          ),
        ),
        if (clock.convertsEdits && clock.offsetChangesSoon(now))
          Padding(
            padding: edge.add(const EdgeInsets.only(bottom: 8)),
            child: MessageBanner(
              tone: MessageTone.warning,
              message: l10n.scheduleDstAhead,
            ),
          ),
        if (schedules.isEmpty)
          EmptyState(
            icon: Icons.event_repeat_outlined,
            title: l10n.schedulesEmptyTitle,
            body: l10n.schedulesEmptyBody,
          )
        else ...[
          for (final schedule in schedules)
            ScheduleTile(
              key: ValueKey('schedule-${schedule.id}'),
              schedule: schedule,
              clock: clock,
              now: now,
              isActive: schedule.id == active?.id,
              onTap: canEdit ? () => onOpen(schedule) : null,
            ),
          Padding(
            padding: edge.add(const EdgeInsets.only(top: 8)),
            child: Text(
              l10n.scheduleOrderHint,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: tokens.textMuted),
            ),
          ),
        ],
      ],
    );
  }
}

/// One schedule: name, days and window in the editing clock, target and
/// hysteresis, and whether it is active now or disabled.
class ScheduleTile extends StatelessWidget {
  const new({
    required this.schedule,
    required this.clock,
    required this.now,
    required this.isActive,
    super.key,
    this.onTap,
  });

  final HeatingSchedule schedule;
  final ScheduleClock clock;
  final DateTime now;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final core = ScheduleTimes.ofSchedule(schedule);
    final shown = core == null ? null : clock.toEditing(core, now: now);
    final when = shown == null
        ? l10n.scheduleTimeRange(schedule.startTime, schedule.endTime)
        : '${daysLabel(l10n, shown.days)} · ${windowLabel(l10n, shown)}';
    return ListTile(
      onTap: onTap,
      isThreeLine: true,
      title: Text(schedule.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(when),
          Text(
            l10n.scheduleTargetLine(
              formatTemperature(l10n, schedule.targetTemperatureCelsius),
              formatTemperature(l10n, schedule.hysteresisCelsius),
            ),
          ),
          if (isActive || !schedule.enabled)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: isActive
                  ? StatusChip(
                      label: l10n.scheduleActiveNow,
                      icon: Icons.schedule,
                      tone: StatusTone.good,
                    )
                  : StatusChip(
                      label: l10n.scheduleDisabledChip,
                      icon: Icons.pause_circle_outline,
                    ),
            ),
        ],
      ),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }
}
