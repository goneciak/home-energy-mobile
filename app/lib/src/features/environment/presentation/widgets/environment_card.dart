import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// A titled card of the weather screen and the device details.
class EnvironmentCard extends StatelessWidget {
  const new({required this.title, required this.child, super.key, this.icon});

  final String title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final icon = this.icon;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: tokens.ember),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: tokens.ember),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.gap * 0.75),
            child,
          ],
        ),
      ),
    );
  }
}

/// "Nothing to show" inside an [EnvironmentCard]: an icon, a title and why
/// (plan §4.2, G3: no internet in the appliance is not "GI Home
/// unreachable").
class EnvironmentNotice extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    super.key,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final body = this.body;
    final action = this.action;
    return Semantics(
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tokens.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.bodyLarge),
                if (body != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
                ?action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A failed read (GI Home unreachable, timeout, server error) inside a
/// card, with "Spróbuj ponownie".
class EnvironmentFailure extends StatelessWidget {
  const new({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: EnvironmentNotice(
        icon: Icons.cloud_off_outlined,
        title: failureMessage(l10n, error),
        body: failureRequestIdLine(l10n, error),
        action: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: OutlinedButton(
            onPressed: onRetry,
            child: Text(l10n.actionRetry),
          ),
        ),
      ),
    );
  }
}

/// A first load in progress inside a card.
class EnvironmentLoading extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(context.l10n.commonLoading)),
      ],
    ),
  );
}
