import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/history/application/history_providers.dart';
import 'package:gi_home/src/features/history/data/history_source.dart';
import 'package:gi_home/src/features/history/domain/history_series.dart';
import 'package:gi_home/src/features/history/domain/history_window.dart';
import 'package:gi_home/src/features/history/presentation/history_labels.dart';
import 'package:gi_home/src/features/history/presentation/widgets/history_chart.dart';
import 'package:gi_home/src/features/history/presentation/widgets/history_table.dart';
import 'package:material_ui/material_ui.dart';

/// History of one entity (plan §4.2, path 6 "Co działo się w nocy?"): a
/// step chart of the recorded changes over 1 h, 6 h, 24 h or 7 days, its
/// summary, and "Pokaż jako tabelę" with every change for screen readers.
/// Read-only for every role.
class HistoryScreen extends ConsumerStatefulWidget {
  const new({
    required this.deviceId,
    required this.entityId,
    this.initialWindow = HistoryWindow.day,
    super.key,
  });

  final String deviceId;
  final String entityId;
  final HistoryWindow initialWindow;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late HistoryWindow _window = widget.initialWindow;
  bool _showTable = false;

  EntityHistoryProvider get _historyProvider =>
      entityHistoryProvider(widget.deviceId, widget.entityId, _window);

  Future<void> _refresh() async {
    ref.invalidate(_historyProvider);
    try {
      await ref.read(_historyProvider.future);
    } on Object {
      // Shown by the screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final entity = ref.watch(
      historyEntityProvider(widget.deviceId, widget.entityId),
    );
    final history = ref.watch(_historyProvider);
    final edge = EdgeInsets.symmetric(horizontal: tokens.gap);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: tokens.gap, bottom: tokens.gap * 2),
          children: [
            if (entity != null)
              Padding(
                padding: edge,
                child: Text(
                  entity.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            Padding(
              padding: edge.add(EdgeInsets.only(top: tokens.gap / 2)),
              child: Semantics(
                label: l10n.historyWindowLabel,
                container: true,
                child: SegmentedButton<HistoryWindow>(
                  key: const ValueKey('history-window'),
                  showSelectedIcon: false,
                  segments: [
                    for (final window in HistoryWindow.values)
                      ButtonSegment(
                        value: window,
                        // Four segments share a 320 px phone even at 2× text.
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            historyWindowLabel(l10n, window),
                            key: ValueKey('history-window-${window.name}'),
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                  ],
                  selected: {_window},
                  onSelectionChanged: (selection) =>
                      setState(() => _window = selection.single),
                ),
              ),
            ),
            SizedBox(height: tokens.gap),
            switch (history) {
              AsyncData(:final value) => _HistoryContent(
                data: value,
                deviceId: widget.deviceId,
                entityId: widget.entityId,
                window: _window,
                entity: entity,
                showTable: _showTable,
                onToggleTable: () => setState(() => _showTable = !_showTable),
              ),
              AsyncError(:final error) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(_historyProvider),
              ),
              _ => const SizedBox(
                height: HistoryChart.height + 80,
                child: LoadingView(),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const new({
    required this.data,
    required this.deviceId,
    required this.entityId,
    required this.window,
    required this.entity,
    required this.showTable,
    required this.onToggleTable,
  });

  final HistoryData data;
  final String deviceId;
  final String entityId;
  final HistoryWindow window;
  final DeviceEntity? entity;
  final bool showTable;
  final VoidCallback onToggleTable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final edge = EdgeInsets.symmetric(horizontal: tokens.gap);
    final samples = data.samples;
    if (samples.isEmpty) {
      return EmptyState(
        icon: Icons.timeline,
        title: l10n.historyEmptyTitle,
        body: l10n.historyEmptyBody,
      );
    }
    final deviceClass = entity?.deviceClass;
    final summary = HistorySummary.of(samples);
    final last = summary.last!;
    final chartable = samples.any((s) => s.numericValue != null);
    final isSwitch =
        entity?.domain == EntityDomain.switch_ ||
        last.kind == HistorySampleKind.switch_;
    final table = !chartable || showTable;
    String value(HistorySample sample) =>
        formatHistoryValue(l10n, sample, deviceClass: deviceClass);
    String number(double y) =>
        formatHistoryNumber(l10n, y, last, deviceClass: deviceClass);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!data.complete)
          Padding(
            padding: edge.add(const EdgeInsets.only(bottom: 8)),
            child: MessageBanner(
              key: const ValueKey('history-truncated'),
              tone: MessageTone.warning,
              message: l10n.historyTruncated,
            ),
          ),
        Padding(
          padding: edge,
          child: Wrap(
            spacing: tokens.gap,
            runSpacing: 8,
            children: [
              if (summary.min case final min?)
                _SummaryValue(l10n.historySummaryMin, number(min)),
              if (summary.max case final max?)
                _SummaryValue(l10n.historySummaryMax, number(max)),
              _SummaryValue(
                l10n.historySummaryLast,
                '${value(last)} · ${formatDateTime(l10n, last.at)}',
              ),
              _SummaryValue(
                l10n.historySummaryChanges,
                summary.count.toString(),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.gap),
        if (!chartable)
          Padding(
            padding: edge.add(const EdgeInsets.only(bottom: 8)),
            child: MessageBanner(
              tone: MessageTone.info,
              message: l10n.historyTextOnly,
            ),
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.gap / 2),
              child: TextButton.icon(
                key: const ValueKey('history-toggle-table'),
                onPressed: onToggleTable,
                icon: Icon(table ? Icons.show_chart : Icons.table_rows),
                label: Text(
                  table ? l10n.historyShowChart : l10n.historyShowTable,
                ),
              ),
            ),
          ),
        if (table)
          HistoryTable(samples: samples, deviceClass: deviceClass)
        else
          Padding(
            padding: EdgeInsets.fromLTRB(tokens.gap / 2, 8, tokens.gap, 0),
            child: LayoutBuilder(
              builder: (context, constraints) => _ChartLoader(
                deviceId: deviceId,
                entityId: entityId,
                window: window,
                data: data,
                // About one change point per logical pixel: at most two
                // points per pixel once expanded into steps.
                threshold: constraints.maxWidth.round().clamp(64, 4096),
                isSwitch: isSwitch,
                formatValue: (y) => formatNumber(l10n, y),
                semanticsLabel: historySemanticsLabel(
                  l10n,
                  name: entity?.displayName ?? l10n.historyTitle,
                  window: window,
                  summary: summary,
                  deviceClass: deviceClass,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChartLoader extends ConsumerWidget {
  const new({
    required this.deviceId,
    required this.entityId,
    required this.window,
    required this.data,
    required this.threshold,
    required this.isSwitch,
    required this.formatValue,
    required this.semanticsLabel,
  });

  final String deviceId;
  final String entityId;
  final HistoryWindow window;
  final HistoryData data;
  final int threshold;
  final bool isSwitch;
  final String Function(double value) formatValue;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(
      historyChartProvider(deviceId, entityId, window, threshold),
    );
    return switch (series) {
      AsyncData(:final value) => HistoryChart(
        key: const ValueKey('history-chart'),
        points: value.points,
        from: data.from,
        to: data.to,
        window: window,
        isSwitch: isSwitch,
        formatValue: formatValue,
        semanticsLabel: semanticsLabel,
      ),
      AsyncError(:final error) => ErrorState(
        error: error,
        onRetry: () => ref.invalidate(
          historyChartProvider(deviceId, entityId, window, threshold),
        ),
      ),
      _ => SizedBox(
        height: HistoryChart.height,
        child: Center(
          child: CircularProgressIndicator(
            semanticsLabel: context.l10n.historyChartLoading,
          ),
        ),
      ),
    };
  }
}

class _SummaryValue extends StatelessWidget {
  const new(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(color: tokens.textMuted),
          ),
          Text(
            value,
            style: GiFonts.monospace(textTheme.titleSmall)
                .copyWith(color: tokens.text),
          ),
        ],
      ),
    );
  }
}
