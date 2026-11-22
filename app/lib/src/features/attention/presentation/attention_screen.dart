import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/freshness_banner.dart';
import 'package:gi_home/src/core/widgets/section_header.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/attention/application/attention_feed_notifier.dart';
import 'package:gi_home/src/features/attention/domain/attention_feed.dart';
import 'package:gi_home/src/features/devices/application/device_list_notifier.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/home/domain/home_condition.dart';
import 'package:gi_home/src/features/home/presentation/widgets/attention_list.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Uwaga": everything that needs a look, grouped by weight, plus what
/// cleared in the last 24 h (plan §15). Each entry opens its device (or the
/// password change). While it is visible the device list is polled, like on
/// Home; pull to refresh asks at once.
class AttentionScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    // Watching keeps the list polled while this tab is visible.
    final devices = ref.watch(deviceListProvider);
    final feed = ref.watch(attentionFeedProvider);
    final now = ref.watch(clockProvider)();
    final data = devices.data;

    final Widget body;
    if (data == null && devices.isFirstLoad) {
      body = const LoadingView();
    } else if (data == null && devices.error != null) {
      body = ErrorState(
        error: devices.error!,
        onRetry: ref.read(deviceListProvider.notifier).refresh,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: ref.read(deviceListProvider.notifier).refresh,
        child: AttentionFeedView(
          feed: feed,
          now: now,
          header: data == null
              ? null
              : FreshnessBanner(
                  fetchedAt: data.fetchedAt,
                  error: devices.error,
                  isStale: FreshnessPolicy.deviceList.isStale(
                    data.fetchedAt,
                    now,
                  ),
                  now: now,
                ),
          onOpen: (entry) => switch (entry.topic) {
            AttentionTopic.device => context.go(
              AppRoutes.device(entry.device!.id),
            ),
            AttentionTopic.mustChangePassword => context.go(
              AppRoutes.changePassword,
            ),
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attentionTitle)),
      body: Padding(
        padding: EdgeInsets.only(top: tokens.gap / 2),
        child: body,
      ),
    );
  }
}

/// The sections of an [AttentionFeed]; empty sections are left out.
class AttentionFeedView extends StatelessWidget {
  const new({
    required this.feed,
    required this.now,
    required this.onOpen,
    this.header,
    super.key,
  });

  final AttentionFeed feed;
  final DateTime now;
  final ValueChanged<AttentionEntry> onOpen;

  /// Shown above the sections, e.g. a freshness banner.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final edge = EdgeInsets.symmetric(horizontal: tokens.gap);
    final header = this.header;

    Widget section(String title, List<AttentionEntry> entries) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title),
        Padding(
          padding: edge,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final entry in entries)
                  _EntryTile(
                    entry: entry,
                    now: now,
                    onTap: () => onOpen(entry),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    final critical = feed.withSeverity(AttentionSeverity.critical);
    final important = feed.withSeverity(AttentionSeverity.important);
    final notice = feed.withSeverity(AttentionSeverity.notice);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: tokens.gap * 2),
      children: [
        if (header != null) Padding(padding: edge, child: header),
        if (feed.active.isEmpty)
          EmptyState(
            icon: Icons.check_circle_outline,
            title: l10n.attentionEmptyTitle,
            body: l10n.attentionEmptyBody,
          ),
        if (critical.isNotEmpty)
          section(l10n.attentionSectionCritical, critical),
        if (important.isNotEmpty)
          section(l10n.attentionSectionImportant, important),
        if (notice.isNotEmpty) section(l10n.attentionSectionNotice, notice),
        if (feed.resolved.isNotEmpty)
          section(l10n.attentionSectionResolved, feed.resolved),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const new({required this.entry, required this.now, required this.onTap});

  final AttentionEntry entry;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final resolvedAt = entry.resolvedAt;
    final tone = switch (entry.severity) {
      AttentionSeverity.critical => StatusTone.danger,
      AttentionSeverity.important => StatusTone.warning,
      AttentionSeverity.notice => StatusTone.info,
      AttentionSeverity.resolved => StatusTone.good,
    };
    final (title, what) = switch (entry.topic) {
      AttentionTopic.device => (
        entry.device!.name,
        attentionText(l10n, AttentionItem(entry.device!, entry.kind!)),
      ),
      AttentionTopic.mustChangePassword => (
        l10n.attentionAccountTitle,
        l10n.attentionMustChangePassword,
      ),
    };
    return ListTile(
      key: ValueKey('attention-entry-${entry.key}-${entry.severity.name}'),
      leading: Icon(
        resolvedAt != null ? Icons.check_circle_outline : _iconOf(entry),
        color: StatusChip.colorOf(tokens, tone),
      ),
      title: Text(title),
      subtitle: Text(
        resolvedAt == null
            ? what
            : l10n.attentionResolvedAt(
                what,
                formatClockTime(l10n, resolvedAt, now),
              ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  static IconData _iconOf(AttentionEntry entry) => switch (entry.kind) {
    null => Icons.password,
    AttentionKind.firmwareFault => Icons.report_outlined,
    AttentionKind.connectivityError => Icons.error_outline,
    AttentionKind.heatingFaults ||
    AttentionKind.faults => Icons.warning_amber_rounded,
    AttentionKind.offline => Icons.wifi_off,
    AttentionKind.stale => Icons.wifi_2_bar,
    AttentionKind.heatingSuspended => Icons.pause_circle_outline,
    AttentionKind.dryRun => Icons.science_outlined,
    AttentionKind.needsConfiguration => Icons.tune,
    AttentionKind.heatingDetailsUnavailable => Icons.sync_problem,
    AttentionKind.noData => Icons.help_outline,
  };
}
