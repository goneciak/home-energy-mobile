import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:material_ui/material_ui.dart';

/// Small filled badge with a count ("3", "99+") or a short status ("Nowe"),
/// e.g. on a section header or a navigation icon (plan §14).
///
/// The visible text is too terse on its own, so a badge always carries a
/// [semanticLabel] ("3 usterki") that screen readers read instead. Its
/// [tone] is never the only signal: the text or the label says it too.
///
/// Named `GiBadge` because Material already has a `Badge`.
class GiBadge extends StatelessWidget {
  /// A badge showing [text].
  const new({
    required this.text,
    required this.semanticLabel,
    super.key,
    this.tone = StatusTone.danger,
  });

  /// A count, capped at "[max]+" so the badge stays small.
  factory count(
    int count, {
    required String semanticLabel,
    Key? key,
    StatusTone tone = StatusTone.danger,
    int max = 99,
  }) {
    assert(count >= 0, 'count must not be negative');
    return GiBadge(
      text: count > max ? '$max+' : '$count',
      semanticLabel: semanticLabel,
      tone: tone,
      key: key,
    );
  }

  final String text;
  final String semanticLabel;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final style = Theme.of(context).textTheme.labelSmall;
    return Semantics(
      label: semanticLabel,
      container: true,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: StatusChip.colorOf(tokens, tone),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              // Every tone is a light colour: dark text keeps AA contrast.
              style: GiFonts.monospace(
                style,
              ).copyWith(color: tokens.background, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
