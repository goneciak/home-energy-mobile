import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Asks before "Zmień użytkownika" logs [email] out and removes its data
/// from this phone (plan §7.8).
Future<bool> confirmSwitchUser(
  BuildContext context, {
  required String email,
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.settingsSwitchUserConfirmTitle),
      content: Text(l10n.settingsSwitchUserConfirmBody(email)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const ValueKey('switch-user-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.settingsSwitchUser),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
