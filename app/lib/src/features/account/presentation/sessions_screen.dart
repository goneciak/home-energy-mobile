import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/localized_snack_bar.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:material_ui/material_ui.dart';

/// "Aktywne sesje" (plan §4.2, §20 M3.5): the user's live sessions with
/// this phone marked "Ten telefon". Any of them can be signed out after a
/// confirmation; signing out this phone, or every device, ends the session
/// here too and the router returns to login.
class SessionsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final sessions = ref.watch(authSessionsProvider);
    final action = ref.watch(sessionActionsControllerProvider);
    final busy = action.isLoading;
    final error = busy ? null : action.error;

    Future<void> revoke(AuthSessionInfo session) async {
      final confirmed = await _confirm(
        context,
        title: session.current
            ? l10n.sessionsRevokeCurrentTitle
            : l10n.sessionsRevokeTitle,
        body: session.current
            ? l10n.sessionsRevokeCurrentBody
            : l10n.sessionsRevokeBody,
        confirm: l10n.sessionsRevokeConfirm,
      );
      if (!confirmed || !context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final done = await ref
          .read(sessionActionsControllerProvider.notifier)
          .revoke(session);
      if (done && !session.current) {
        messenger.showSnackBar(
          localizedSnackBar((l10n) => l10n.sessionsRevoked),
        );
      }
    }

    Future<void> logoutAll() async {
      final confirmed = await _confirm(
        context,
        title: l10n.sessionsLogoutAllTitle,
        body: l10n.sessionsLogoutAllBody,
        confirm: l10n.sessionsLogoutAll,
      );
      if (!confirmed || !context.mounted) return;
      await ref.read(sessionActionsControllerProvider.notifier).logoutAll();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionsTitle)),
      body: switch (sessions) {
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(authSessionsProvider.future),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: tokens.gap / 2),
            children: [
              if (error != null)
                Padding(
                  padding: EdgeInsets.all(tokens.gap),
                  child: MessageBanner(
                    message: failureMessage(l10n, error),
                    detail: failureRequestIdLine(l10n, error),
                    monospaceDetail: true,
                  ),
                ),
              if (value.isEmpty)
                Padding(
                  padding: EdgeInsets.all(tokens.gap),
                  child: Text(l10n.sessionsEmpty),
                ),
              for (final session in value)
                _SessionTile(
                  session: session,
                  enabled: !busy,
                  onRevoke: () => unawaited(revoke(session)),
                ),
              Padding(
                padding: EdgeInsets.all(tokens.gap),
                child: OutlinedButton.icon(
                  key: const ValueKey('sessions-logout-all'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.danger,
                  ),
                  onPressed: busy ? null : () => unawaited(logoutAll()),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.sessionsLogoutAll),
                ),
              ),
            ],
          ),
        ),
        AsyncError(:final error) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(authSessionsProvider),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  const new({
    required this.session,
    required this.enabled,
    required this.onRevoke,
  });

  final AuthSessionInfo session;
  final bool enabled;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final lastUsed = session.lastUsedAt;
    final ip = session.ipAddress;
    return ListTile(
      key: ValueKey('session-${session.id}'),
      leading: Icon(
        session.current ? Icons.smartphone : Icons.devices_other_outlined,
      ),
      title: Text(
        describeUserAgent(session.userAgent) ?? l10n.sessionsUnknownDevice,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session.current) ...[
            SizedBox(height: tokens.gap / 4),
            StatusChip(
              label: l10n.sessionsThisPhone,
              icon: Icons.check_circle_outline,
              tone: StatusTone.good,
            ),
            SizedBox(height: tokens.gap / 4),
          ],
          Text(l10n.sessionsSignedIn(session.createdAt.toLocal())),
          if (lastUsed != null) Text(l10n.sessionsLastUsed(lastUsed.toLocal())),
          if (ip != null && ip.isNotEmpty) Text(l10n.sessionsIpAddress(ip)),
        ],
      ),
      isThreeLine: true,
      trailing: IconButton(
        key: ValueKey('session-revoke-${session.id}'),
        tooltip: l10n.sessionsRevokeTooltip,
        icon: const Icon(Icons.logout),
        onPressed: enabled ? onRevoke : null,
      ),
    );
  }
}

/// A short name for a session's `User-Agent`: the app's own client, a
/// browser or the raw value cut to a readable length; `null` when empty.
String? describeUserAgent(String? userAgent) {
  final agent = userAgent?.trim();
  if (agent == null || agent.isEmpty) return null;
  const known = [
    ('GIHome-Mobile', 'GI Home'),
    ('Dart/', 'GI Home'),
    ('Edg/', 'Edge'),
    ('Firefox/', 'Firefox'),
    ('Chrome/', 'Chrome'),
    ('Safari/', 'Safari'),
  ];
  const platforms = [
    ('Android', 'Android'),
    ('iPhone', 'iPhone'),
    ('iPad', 'iPad'),
    ('Windows', 'Windows'),
    ('Mac OS', 'macOS'),
    ('Linux', 'Linux'),
  ];
  final lower = agent.toLowerCase();
  final app = known.where((k) => agent.contains(k.$1)).firstOrNull?.$2;
  final platform = platforms
      .where((p) => lower.contains(p.$1.toLowerCase()))
      .firstOrNull
      ?.$2;
  if (app != null) return platform == null ? app : '$app · $platform';
  return agent.length > 48 ? '${agent.substring(0, 47)}…' : agent;
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirm,
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const ValueKey('sessions-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
