import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/gi_badge.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:material_ui/material_ui.dart';

/// The permanent "DEMO" strip of demo mode (plan §19.5): says that the data
/// is made up and nothing is controlled, with "Zakończ demo" ([onExit]).
/// It takes the status bar inset itself.
class DemoBanner extends StatelessWidget {
  const new({required this.onExit, super.key});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Material(
      key: const ValueKey('demo-banner'),
      color: tokens.surfaceRaised,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(tokens.gap, 4, tokens.gap / 2, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GiBadge(
                  text: l10n.demoBadge,
                  semanticLabel: l10n.demoBadgeSemantics,
                  tone: StatusTone.warning,
                ),
              ),
              const SizedBox(width: 12),
              // The text and the button wrap below each other when the
              // line is too short (small phones, large text).
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        l10n.demoBannerMessage,
                        style: textTheme.bodySmall,
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('demo-exit'),
                      onPressed: onExit,
                      child: Text(l10n.demoExit),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
