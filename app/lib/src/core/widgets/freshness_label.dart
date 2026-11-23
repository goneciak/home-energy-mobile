import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// How old one value is: "2 min temu", or "Czekamy na pierwszy odczyt" when
/// it never arrived (plan §13.3, §14). Unlike the screen-wide
/// `FreshnessBanner` it sits next to a single reading.
///
/// An [isStale] value gets a warning icon, and screen readers hear
/// "Zaktualizowano 2 min temu, dane mogą być nieaktualne", so neither the
/// colour nor the icon alone says it.
class FreshnessLabel extends StatelessWidget {
  const new({
    required this.updatedAt,
    required this.now,
    super.key,
    this.isStale = false,
  });

  /// When the value was received or last reported; `null` when never.
  final DateTime? updatedAt;
  final DateTime now;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final updatedAt = this.updatedAt;
    final stale = isStale || updatedAt == null;
    final text = updatedAt == null
        ? l10n.freshnessWaitingForReading
        : formatRelativeTime(l10n, updatedAt, now);
    final label = switch (updatedAt) {
      null => l10n.freshnessWaitingForReading,
      _ when isStale => l10n.freshnessUpdatedStale(text),
      _ => l10n.freshnessUpdated(text),
    };
    return Semantics(
      label: label,
      container: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stale ? Icons.history_toggle_off : Icons.schedule,
            size: 14,
            color: stale ? tokens.warning : tokens.textMuted,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: tokens.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
