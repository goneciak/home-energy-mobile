import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:gi_home/src/features/account/presentation/sessions_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/account_fixtures.dart';

void main() {
  late AccountScript script;

  setUp(() => script = AccountScript());

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<AuthSessionInfo>? sessions,
    Exception? loadError,
  }) async {
    await tester.pumpWidget(
      accountTestApp(
        SessionsScreen.new,
        overrides: [
          authSessionsProvider.overrideWith((ref) async {
            if (loadError != null) throw loadError;
            return sessions ?? testSessions;
          }),
          ...fakeAccountControllers(script),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder revokeButton(AuthSessionInfo session) =>
      find.byKey(ValueKey('session-revoke-${session.id}'));

  testWidgets('this phone is marked "Ten telefon"; the agents are named', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Ten telefon'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(ValueKey('session-${testSessions[0].id}')),
        matching: find.text('Ten telefon'),
      ),
      findsOneWidget,
    );
    expect(find.text('GI Home · Android'), findsOneWidget);
    expect(find.text('Chrome · Windows'), findsOneWidget);
    expect(find.text('Nieznane urządzenie'), findsOneWidget);
    expect(find.text('Adres IP: 192.168.1.31'), findsOneWidget);
  });

  testWidgets('another session is revoked after a confirmation', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapVisible(tester, revokeButton(testSessions[1]));
    expect(find.text('Wylogować to urządzenie?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sessions-confirm')));
    await tester.pumpAndSettle();

    expect(script.revoked, [testSessions[1]]);
    expect(find.text('Sesja została zakończona.'), findsOneWidget);
  });

  testWidgets('cancelling keeps the session', (tester) async {
    await pumpScreen(tester);

    await tapVisible(tester, revokeButton(testSessions[1]));
    await tester.tap(find.text('Anuluj'));
    await tester.pumpAndSettle();

    expect(script.revoked, isEmpty);
  });

  testWidgets('revoking this phone warns that it signs out here', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapVisible(tester, revokeButton(testSessions[0]));
    expect(find.text('Wylogować ten telefon?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sessions-confirm')));
    await tester.pumpAndSettle();

    expect(script.revoked.single.current, isTrue);
    expect(find.text('Sesja została zakończona.'), findsNothing);
  });

  testWidgets('"Wyloguj wszystkie urządzenia" asks first', (tester) async {
    await pumpScreen(tester);

    await tapVisible(tester, find.byKey(const ValueKey('sessions-logout-all')));
    expect(find.text('Wylogować wszystkie urządzenia?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sessions-confirm')));
    await tester.pumpAndSettle();

    expect(script.logoutAllCalls, 1);
  });

  testWidgets('a failed revoke shows the error and keeps the list', (
    tester,
  ) async {
    script.failure = const ApiFailure.notFound(code: 'AUTH_SESSION_NOT_FOUND');
    await pumpScreen(tester);

    await tapVisible(tester, revokeButton(testSessions[2]));
    await tester.tap(find.byKey(const ValueKey('sessions-confirm')));
    await tester.pumpAndSettle();

    expect(find.byType(MessageBanner), findsOneWidget);
    expect(find.text('Ten telefon'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    await pumpScreen(tester, loadError: const ApiFailure.unreachable());

    expect(find.text('Spróbuj ponownie'), findsOneWidget);
  });

  group('describeUserAgent', () {
    test('names the app, browsers and platforms', () {
      expect(describeUserAgent(null), isNull);
      expect(describeUserAgent('  '), isNull);
      expect(
        describeUserAgent('GIHome-Mobile/0.1.0 (android; Pixel 8)'),
        'GI Home · Android',
      );
      expect(
        describeUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) '
          'AppleWebKit/605.1.15 Version/18.0 Mobile/15E148 Safari/604.1',
        ),
        'Safari · iPhone',
      );
      expect(describeUserAgent('Dart/3.10 (dart:io)'), 'GI Home');
      expect(describeUserAgent('x' * 60), hasLength(48));
    });
  });
}
