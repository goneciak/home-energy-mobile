import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/settings/domain/session_expiry.dart';

void main() {
  final end = DateTime.utc(2026, 12, 20, 12);

  SessionExpiry at(Duration beforeEnd) =>
      SessionExpiry.of(end, now: end.subtract(beforeEnd));

  test('no warning more than three days before the end', () {
    final expiry = at(const Duration(days: 3, minutes: 1));
    expect(expiry.daysLeft, isNull);
    expect(expiry.isWarning, isFalse);
    expect(expiry.expiresAt, end);
  });

  test('whole days left, rounded up, inside the last three days', () {
    expect(at(const Duration(days: 3)).daysLeft, 3);
    expect(at(const Duration(days: 2, hours: 1)).daysLeft, 3);
    expect(at(const Duration(days: 1)).daysLeft, 1);
    expect(at(const Duration(minutes: 1)).daysLeft, 1);
    expect(at(const Duration(minutes: 1)).isWarning, isTrue);
  });

  test('zero days once the session has ended', () {
    expect(at(Duration.zero).daysLeft, 0);
    expect(
      SessionExpiry.of(end, now: end.add(const Duration(days: 1))),
      SessionExpiry(expiresAt: end, daysLeft: 0),
    );
  });

  test('value equality', () {
    final a = SessionExpiry(expiresAt: end, daysLeft: 2);
    expect(a, SessionExpiry(expiresAt: end, daysLeft: 2));
    expect(a.hashCode, SessionExpiry(expiresAt: end, daysLeft: 2).hashCode);
    expect(a, isNot(SessionExpiry(expiresAt: end, daysLeft: 1)));
  });
}
