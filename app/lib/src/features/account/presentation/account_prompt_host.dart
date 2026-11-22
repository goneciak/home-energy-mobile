import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Shows what [AccountPrompts] holds once the signed-in shell is up (plan
/// §20 M3.5): after a password reset with the recovery code, an offer to
/// generate a new code; otherwise, after a login, an offer to review the
/// other active sessions when there are any.
class AccountPromptHost extends ConsumerStatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AccountPromptHost> createState() => _AccountPromptHostState();
}

class _AccountPromptHostState extends ConsumerState<AccountPromptHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _show());
  }

  void _show() {
    if (!mounted) return;
    final pending = ref.read(accountPromptsProvider);
    if (pending.isEmpty) return;
    final prompts = ref.read(accountPromptsProvider.notifier).take();
    if (prompts.rotateRecoveryCode) {
      unawaited(_offerNewRecoveryCode());
    } else if (prompts.reviewSessions) {
      unawaited(_offerSessionReview());
    }
  }

  Future<void> _offerNewRecoveryCode() async {
    final l10n = context.l10n;
    final generate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recoveryRotatePromptTitle),
        content: Text(l10n.recoveryRotatePromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.recoveryRotatePromptLater),
          ),
          FilledButton(
            key: const ValueKey('recovery-rotate-accept'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.recoveryCodeGenerate),
          ),
        ],
      ),
    );
    if ((generate ?? false) && mounted) {
      unawaited(context.push(AppRoutes.accountRecoveryCode));
    }
  }

  Future<void> _offerSessionReview() async {
    final client = ref.read(giCoreClientProvider);
    if (client == null) return;
    final int others;
    try {
      others = (await client.authSessions()).where((s) => !s.current).length;
    } on Object {
      // Only an offer: the list stays reachable from the account screen.
      return;
    }
    if (others == 0 || !mounted) return;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const ValueKey('sessions-review-prompt'),
        content: Text(l10n.sessionsReviewPrompt(others)),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: l10n.sessionsReviewAction,
          onPressed: () {
            if (mounted) unawaited(context.push(AppRoutes.accountSessions));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(accountPromptsProvider, (_, next) {
      if (!next.isEmpty) _show();
    });
    return widget.child;
  }
}
