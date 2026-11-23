import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/centered_form.dart';
import 'package:gi_home/src/core/widgets/localized_snack_bar.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/setup_check_controller.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// The appliance is not set up yet. The app never calls
/// `POST /setup/initialize` (the first caller becomes the owner); the user
/// finishes the setup in the web panel at `http://<host>/setup` (plan §9.5).
class SetupRequiredScreen extends ConsumerWidget {
  const new({super.key});

  static const devInitCommand = 'dart run tools/seed_core.dart --init';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(applianceProfileProvider);
    final check = ref.watch(setupCheckControllerProvider);
    if (profile == null) return const Scaffold();

    Future<void> openPanel() async {
      final opened = await launchUrl(
        profile.address.origin.replace(
          path: '${profile.address.origin.path}/setup',
        ),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          localizedSnackBar((l10n) => l10n.setupRequiredOpenFailed),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupRequiredTitle)),
      body: CenteredForm(
        children: [
          Icon(Icons.settings_suggest_outlined, size: 48, color: tokens.ember),
          SizedBox(height: tokens.gap),
          Text(
            l10n.setupRequiredBody(profile.address.authority),
            style: textTheme.bodyLarge,
          ),
          // The dev stack has no web panel; only developers seed it.
          if (ref.watch(appFlavorProvider) == AppFlavor.dev) ...[
            SizedBox(height: tokens.gap),
            MessageBanner(
              message: l10n.setupRequiredDevHint(devInitCommand),
              tone: MessageTone.info,
            ),
          ],
          if (check case AsyncData(value: false)) ...[
            SizedBox(height: tokens.gap),
            MessageBanner(
              message: l10n.setupRequiredStillNotInitialized,
              tone: MessageTone.warning,
            ),
          ],
          if (check case AsyncError(:final error)) ...[
            SizedBox(height: tokens.gap),
            MessageBanner(message: failureMessage(l10n, error)),
          ],
          SizedBox(height: tokens.gap * 1.5),
          FilledButton.icon(
            onPressed: openPanel,
            icon: const Icon(Icons.open_in_browser),
            label: Text(l10n.setupRequiredOpenPanel),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: check.isLoading
                ? null
                : ref.read(setupCheckControllerProvider.notifier).check,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.setupRequiredCheckAgain),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: ref.read(authSessionProvider.notifier).forgetAppliance,
            child: Text(l10n.actionChangeAppliance),
          ),
        ],
      ),
    );
  }
}
