import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// "przed chwilą", "5 min temu", "3 godz. temu", then date and time.
String formatRelativeTime(AppLocalizations l10n, DateTime time, DateTime now) {
  final age = now.difference(time);
  if (age < const Duration(minutes: 1)) return l10n.timeJustNow;
  if (age < const Duration(hours: 1)) return l10n.timeMinutesAgo(age.inMinutes);
  if (age < const Duration(hours: 24)) return l10n.timeHoursAgo(age.inHours);
  return formatDateTime(l10n, time);
}

/// "07:41" for today, "17 lis 07:41" for other days (local time).
String formatClockTime(AppLocalizations l10n, DateTime time, DateTime now) {
  final local = time.toLocal();
  final today = now.toLocal();
  final sameDay =
      local.year == today.year &&
      local.month == today.month &&
      local.day == today.day;
  return sameDay
      ? DateFormat.Hm(l10n.localeName).format(local)
      : formatDateTime(l10n, local);
}

/// Day, month and time in the app language, e.g. "17 lis 07:41".
String formatDateTime(AppLocalizations l10n, DateTime time) =>
    DateFormat.MMMd(l10n.localeName).add_Hm().format(time.toLocal());
