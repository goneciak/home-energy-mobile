import 'package:meta/meta.dart';

/// When the 30-day session ends, as Settings show it (plan §7.6): from
/// [warningPeriod] before the end, the number of days left.
@immutable
final class SessionExpiry {
  const new({required this.expiresAt, required this.daysLeft});

  /// [expiresAt] seen at [now]. [daysLeft] is `null` outside the warning
  /// period, otherwise the whole days left, rounded up (0 once expired).
  factory of(DateTime expiresAt, {required DateTime now}) {
    final left = expiresAt.difference(now);
    if (left > warningPeriod) {
      return SessionExpiry(expiresAt: expiresAt, daysLeft: null);
    }
    if (left <= Duration.zero) {
      return SessionExpiry(expiresAt: expiresAt, daysLeft: 0);
    }
    final days = (left.inMinutes / Duration.minutesPerDay).ceil();
    return SessionExpiry(expiresAt: expiresAt, daysLeft: days);
  }

  /// From this long before the end, Settings warn about the next login.
  static const warningPeriod = Duration(days: 3);

  final DateTime expiresAt;

  /// Days until the next login is needed, or `null` when not yet worth a
  /// warning.
  final int? daysLeft;

  bool get isWarning => daysLeft != null;

  @override
  bool operator ==(Object other) =>
      other is SessionExpiry &&
      other.expiresAt == expiresAt &&
      other.daysLeft == daysLeft;

  @override
  int get hashCode => Object.hash(expiresAt, daysLeft);
}
