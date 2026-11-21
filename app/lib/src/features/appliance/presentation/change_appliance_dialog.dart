import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Asks before "Zmień urządzenie" removes the appliance and its stored
/// session from this phone. [canLogOut] is `false` when the session cannot
/// be ended on the appliance first (not signed in yet, appliance
/// unreachable); the text then says the session stays active there.
Future<bool> confirmChangeAppliance(
  BuildContext context, {
  required String applianceLabel,
  required bool canLogOut,
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.settingsChangeApplianceConfirmTitle),
      content: Text(
        canLogOut
            ? l10n.settingsChangeApplianceConfirmBody(applianceLabel)
            : l10n.settingsChangeApplianceConfirmBodyNoLogout(applianceLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.settingsChangeAppliance),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
