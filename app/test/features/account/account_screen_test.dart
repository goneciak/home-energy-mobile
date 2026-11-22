import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/account/presentation/account_screen.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/account_fixtures.dart';

void main() {
  late AccountScript script;

  setUp(() => script = AccountScript());

  Future<void> pumpScreen(WidgetTester tester, {UserProfile? profile}) async {
    await tester.pumpWidget(
      accountTestApp(
        AccountScreen.new,
        overrides: [
          currentUserProvider.overrideWithValue(testAccountUser),
          userProfileProvider.overrideWith(
            (ref) async => profile ?? testAccountProfile,
          ),
          ...fakeAccountControllers(script),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String key) => find.byKey(ValueKey(key));

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('the names come from the profile', (tester) async {
    await pumpScreen(tester);

    expect(
      tester
          .widget<TextFormField>(field('account-first-name'))
          .controller!
          .text,
      'Dev',
    );
    expect(
      tester.widget<TextFormField>(field('account-last-name')).controller!.text,
      'Owner',
    );
  });

  testWidgets('saving sends only the changed names; an empty last name '
      'clears it', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(field('account-first-name'), '  Anna ');
    await tester.enterText(field('account-last-name'), '');
    await tapVisible(tester, field('account-save'));

    expect(script.profileUpdates, [
      const ProfileUpdate(firstName: 'Anna', lastName: ''),
    ]);
    expect(find.text('Zapisano profil.'), findsOneWidget);
  });

  testWidgets('nothing changed sends an empty update', (tester) async {
    await pumpScreen(tester);

    await tapVisible(tester, field('account-save'));

    expect(script.profileUpdates.single.isEmpty, isTrue);
  });

  testWidgets('an empty first name is rejected on the phone', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(field('account-first-name'), '   ');
    await tapVisible(tester, field('account-save'));

    expect(find.text('Podaj imię.'), findsOneWidget);
    expect(script.profileUpdates, isEmpty);
  });

  testWidgets('a name over 100 characters is rejected', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(field('account-last-name'), 'x' * 101);
    await tapVisible(tester, field('account-save'));

    expect(find.text('Maksymalnie 100 znaków.'), findsOneWidget);
    expect(script.profileUpdates, isEmpty);
  });

  testWidgets('picking English writes en-US to the profile (plan §13.2)', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapVisible(tester, field('account-locale-en-US'));

    expect(script.profileUpdates, [const ProfileUpdate(locale: 'en-US')]);
    expect(find.text('Zmieniono język konta.'), findsOneWidget);
  });

  testWidgets('the profile language is selected', (tester) async {
    await pumpScreen(
      tester,
      profile: testAccountProfile.copyWith(locale: 'en-GB'),
    );

    final group = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );
    expect(group.groupValue, 'en-US');
  });

  testWidgets('a rejected update shows the error', (tester) async {
    script.failure = const ApiFailure.validation(details: {});
    await pumpScreen(tester);

    await tester.enterText(field('account-first-name'), 'Anna');
    await tapVisible(tester, field('account-save'));

    expect(find.byType(MessageBanner), findsOneWidget);
    expect(find.text('Zapisano profil.'), findsNothing);
  });

  for (final (key, route) in [
    ('account-change-password', AppRoutes.accountPassword),
    ('account-sessions', AppRoutes.accountSessions),
    ('account-recovery-code', AppRoutes.accountRecoveryCode),
  ]) {
    testWidgets('$key opens $route', (tester) async {
      await pumpScreen(tester);

      await tapVisible(tester, field(key));

      expect(find.text(route), findsOneWidget);
    });
  }
}
