import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/app_settings_opener.dart';
import 'package:material_ui/material_ui.dart';

/// "Otwórz ustawienia": opens this app's page in the system settings, where
/// local network access is allowed again after a denial (plan §9.4).
class OpenAppSettingsButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton.icon(
    key: const ValueKey('open-app-settings'),
    onPressed: () => unawaited(ref.read(appSettingsOpenerProvider).open()),
    icon: const Icon(Icons.settings_outlined),
    label: Text(context.l10n.actionOpenSettings),
  );
}

/// The way out an [error] offers besides the screen's own retry: the system
/// settings for [LocalNetworkDeniedFailure], otherwise nothing.
Widget? failureAction(Object? error) =>
    error is LocalNetworkDeniedFailure ? const OpenAppSettingsButton() : null;
