import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/centered_form.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/open_app_settings_button.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/presentation/change_appliance_dialog.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Shown while the stored session is restored on start, and when restoring
/// failed without ending the session (the cookie is kept for a retry).
class SessionRestoreScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final auth = ref.watch(authSessionProvider);
    final error = auth.isLoading ? null : auth.error;
    final vaultUnavailable = error is VaultUnavailableFailure;

    // The stored session may still be valid; removing it here cannot log
    // out on the appliance, so it is confirmed first.
    Future<void> changeAppliance() async {
      final confirmed = await confirmChangeAppliance(
        context,
        applianceLabel: ref.read(applianceProfileProvider)?.label ?? '',
        canLogOut: false,
      );
      if (confirmed && context.mounted) {
        await ref.read(authSessionProvider.notifier).forgetAppliance();
      }
    }

    return Scaffold(
      body: CenteredForm(
        children: error == null
            ? [
                const Center(child: CircularProgressIndicator()),
                SizedBox(height: tokens.gap),
                Text(l10n.restoreConnecting, textAlign: TextAlign.center),
              ]
            : [
                Icon(
                  vaultUnavailable ? Icons.lock_outline : Icons.wifi_off,
                  size: 48,
                  color: tokens.textMuted,
                ),
                SizedBox(height: tokens.gap),
                Text(
                  vaultUnavailable
                      ? l10n.restoreVaultUnavailableTitle
                      : l10n.restoreFailedTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.gap),
                MessageBanner(
                  message: failureMessage(l10n, error),
                  detail: vaultUnavailable
                      ? l10n.restoreVaultUnavailableHint
                      : failureRequestIdLine(l10n, error),
                  monospaceDetail: !vaultUnavailable,
                  action: failureAction(error),
                ),
                SizedBox(height: tokens.gap * 1.5),
                FilledButton.icon(
                  onPressed: ref
                      .read(authSessionProvider.notifier)
                      .retryRestore,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.actionRetry),
                ),
                // The appliance may answer elsewhere, or another one may
                // stand in its place (plan §9.2).
                if (!vaultUnavailable) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        unawaited(context.push(AppRoutes.findAppliance)),
                    icon: const Icon(Icons.travel_explore),
                    label: Text(l10n.actionFindAppliance),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: changeAppliance,
                  child: Text(l10n.actionChangeAppliance),
                ),
              ],
      ),
    );
  }
}
