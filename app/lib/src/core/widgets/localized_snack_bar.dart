import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// A [SnackBar] whose text is worded when it is built, in the language the
/// app has then, not the one of the code that queued it. For a message
/// shown after an `await` or a sign-out, where the language can switch
/// meanwhile (plan §13.2); a plain `Text(l10n.…)` captured earlier would
/// keep the old one.
SnackBar localizedSnackBar(
  String Function(AppLocalizations l10n) message, {
  Key? key,
}) => SnackBar(
  key: key,
  content: Builder(builder: (context) => Text(message(context.l10n))),
);
