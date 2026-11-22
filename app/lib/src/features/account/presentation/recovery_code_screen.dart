import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/secure_display.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/secure_content.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Kod odzyskiwania" (plan §4.2, §20 M3.5): after a confirmation a new
/// code is generated and shown once, protected from screenshots and
/// recordings ([SecureContent]); it can be copied as a sensitive,
/// self-clearing clip. Leaving needs the "Zapisałem" acknowledgement. The
/// code is never stored or logged.
class RecoveryCodeScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends ConsumerState<RecoveryCodeScreen> {
  var _acknowledged = false;

  Future<void> _generate() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recoveryCodeConfirmTitle),
        content: Text(l10n.recoveryCodeConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey('recovery-code-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.recoveryCodeConfirm),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;
    setState(() => _acknowledged = false);
    await ref.read(recoveryCodeControllerProvider.notifier).regenerate();
  }

  Future<void> _copy(String code) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.recoveryCodeCopied;
    await SecureDisplay.copySensitive(code);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _done() {
    ref.read(recoveryCodeControllerProvider.notifier).dismiss();
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(recoveryCodeControllerProvider);
    final busy = state.isLoading;
    final error = busy ? null : state.error;
    final code = state.value?.recoveryCode;
    final mustAcknowledge = code != null && !_acknowledged;

    return PopScope(
      canPop: !mustAcknowledge,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.recoveryCodeLeaveBlocked)));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.recoveryCodeTitle)),
        body: ListView(
          padding: EdgeInsets.all(tokens.gap),
          children: [
            if (code == null) ...[
              Text(l10n.recoveryCodeIntro, style: textTheme.bodyLarge),
              SizedBox(height: tokens.gap * 1.5),
              if (error != null) ...[
                MessageBanner(
                  message: failureMessage(l10n, error),
                  detail: failureRequestIdLine(l10n, error),
                  monospaceDetail: true,
                ),
                SizedBox(height: tokens.gap),
              ],
              FilledButton.icon(
                key: const ValueKey('recovery-code-generate'),
                onPressed: busy ? null : () => unawaited(_generate()),
                icon: busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.key_outlined),
                label: Text(l10n.recoveryCodeGenerate),
              ),
            ] else ...[
              MessageBanner(
                message: l10n.recoveryCodeShownOnce,
                tone: MessageTone.warning,
              ),
              SizedBox(height: tokens.gap),
              SecureContent(
                hidden: _CodeCard(
                  child: Text(
                    l10n.recoveryCodeHidden,
                    textAlign: TextAlign.center,
                  ),
                ),
                child: _CodeCard(
                  child: Text(
                    code,
                    key: const ValueKey('recovery-code-value'),
                    textAlign: TextAlign.center,
                    style: GiFonts.monospace(
                      textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: tokens.gap),
              OutlinedButton.icon(
                key: const ValueKey('recovery-code-copy'),
                onPressed: () => unawaited(_copy(code)),
                icon: const Icon(Icons.copy),
                label: Text(l10n.recoveryCodeCopy),
              ),
              SizedBox(height: tokens.gap),
              CheckboxListTile(
                key: const ValueKey('recovery-code-acknowledge'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _acknowledged,
                onChanged: (value) =>
                    setState(() => _acknowledged = value ?? false),
                title: Text(l10n.recoveryCodeAcknowledge),
              ),
              SizedBox(height: tokens.gap),
              FilledButton(
                key: const ValueKey('recovery-code-done'),
                onPressed: _acknowledged ? _done : null,
                child: Text(l10n.recoveryCodeDone),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.gap,
          vertical: tokens.gap * 1.5,
        ),
        child: child,
      ),
    );
  }
}
