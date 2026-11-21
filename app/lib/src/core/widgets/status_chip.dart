import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Meaning of a [StatusChip], from fine to severe.
enum StatusTone { good, neutral, info, warning, danger }

/// Label, icon and tone describing a state, ready for a [StatusChip].
typedef StateLook = ({String label, IconData icon, StatusTone tone});

/// Small outlined label with an icon, so colour is never the only signal
/// (plan §12.9, §14).
class StatusChip extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    super.key,
    this.tone = StatusTone.neutral,
  });

  final String label;
  final IconData icon;
  final StatusTone tone;

  static Color colorOf(GiTokens tokens, StatusTone tone) => switch (tone) {
    StatusTone.good => tokens.teal,
    StatusTone.neutral => tokens.textMuted,
    StatusTone.info => tokens.ember,
    StatusTone.warning => tokens.warning,
    StatusTone.danger => tokens.danger,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final color = colorOf(tokens, tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: tokens.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
