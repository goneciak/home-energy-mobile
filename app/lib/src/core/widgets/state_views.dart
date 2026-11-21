import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/open_app_settings_button.dart';
import 'package:material_ui/material_ui.dart';

/// First load in progress: nothing to show yet.
class LoadingView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(context.l10n.commonLoading),
      ],
    ),
  );
}

/// Icon, title and explanation for a screen or section without content.
class EmptyState extends StatelessWidget {
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
    return Padding(
      padding: EdgeInsets.all(tokens.gap * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: tokens.textMuted),
          SizedBox(height: tokens.gap),
          Text(
            title,
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[SizedBox(height: tokens.gap), action],
        ],
      ),
    );
  }
}

/// A failed first load, with the reason and "Try again" (and the way to
/// the system settings when local network access was denied, plan §9.4).
class ErrorState extends StatelessWidget {
  const new({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: EmptyState(
        icon: Icons.cloud_off_outlined,
        title: failureMessage(l10n, error),
        body: failureRequestIdLine(l10n, error),
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.actionRetry),
            ),
            ?failureAction(error),
          ],
        ),
      ),
    );
  }
}
