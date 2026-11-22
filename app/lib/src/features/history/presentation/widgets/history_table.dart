import 'dart:math' as math;

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/features/history/presentation/history_labels.dart';
import 'package:material_ui/material_ui.dart';

/// The alternative to the chart (plan §5.2, "Pokaż jako tabelę"): every
/// recorded change, newest first, a page at a time. Each row is one
/// screen reader node ("22 lis 06:40: 45,5 °C").
class HistoryTable extends StatefulWidget {
  const new({
    required this.samples,
    this.deviceClass,
    this.pageSize = 50,
    super.key,
  });

  /// Ascending, as received.
  final List<HistorySample> samples;
  final String? deviceClass;
  final int pageSize;

  @override
  State<HistoryTable> createState() => _HistoryTableState();
}

class _HistoryTableState extends State<HistoryTable> {
  int _page = 0;

  @override
  void didUpdateWidget(HistoryTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.samples, widget.samples)) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final samples = widget.samples;
    final pages = math.max(1, (samples.length / widget.pageSize).ceil());
    final page = math.min(_page, pages - 1);
    // Newest first: page 0 holds the end of the ascending list.
    final end = samples.length - page * widget.pageSize;
    final start = math.max(0, end - widget.pageSize);
    final rows = samples.sublist(start, end).reversed.toList();
    final header = textTheme.labelLarge?.copyWith(color: tokens.textMuted);

    return Column(
      key: const ValueKey('history-table'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.gap, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(l10n.historyTableTime, style: header)),
                Text(l10n.historyTableValue, style: header),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        for (final sample in rows)
          _Row(
            time: formatDateTime(l10n, sample.at),
            value: formatHistoryValue(
              l10n,
              sample,
              deviceClass: widget.deviceClass,
            ),
          ),
        if (pages > 1)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.gap / 2),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  key: const ValueKey('history-table-newer'),
                  onPressed: page > 0
                      ? () => setState(() => _page = page - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  label: Text(l10n.historyTableNewer),
                ),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.historyTablePage(page + 1, pages),
                    style: textTheme.bodyMedium,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('history-table-older'),
                  onPressed: page < pages - 1
                      ? () => setState(() => _page = page + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  label: Text(l10n.historyTableOlder),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const new({required this.time, required this.value});

  final String time;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: context.l10n.historyTableRowSemantics(time, value),
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.gap, vertical: 10),
          child: Row(
            children: [
              Expanded(child: Text(time, style: textTheme.bodyMedium)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: GiFonts.monospace(textTheme.bodyMedium)
                      .copyWith(color: tokens.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
