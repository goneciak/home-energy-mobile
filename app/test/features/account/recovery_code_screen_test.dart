import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/secure_display.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/account/presentation/recovery_code_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/account_fixtures.dart';

void main() {
  late AccountScript script;
  late List<MethodCall> calls;

  setUp(() {
    script = AccountScript();
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SecureDisplay.channel, (call) async {
          calls.add(call);
          return call.method == SecureDisplay.copySensitiveMethod ? true : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SecureDisplay.channel, null);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    RecoveryCodeResult? shownCode,
  }) async {
    await tester.pumpWidget(
      accountTestApp(
        RecoveryCodeScreen.new,
        overrides: fakeAccountControllers(script, shownCode: shownCode),
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

  const shown = RecoveryCodeResult(recoveryCode: placeholderRecoveryCode);
  final code = find.byKey(const ValueKey('recovery-code-value'));
  final done = find.byKey(const ValueKey('recovery-code-done'));

  List<Object?> secureFlags() => [
    for (final call in calls)
      if (call.method == SecureDisplay.setSecureMethod)
        (call.arguments as Map)['secure'],
  ];

  testWidgets('a new code is generated only after a confirmation', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-generate')),
    );
    expect(find.text('Wygenerować nowy kod?'), findsOneWidget);
    await tester.tap(find.text('Anuluj'));
    await tester.pumpAndSettle();
    expect(script.regenerateCalls, 0);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-generate')),
    );
    await tester.tap(find.byKey(const ValueKey('recovery-code-confirm')));
    await tester.pumpAndSettle();

    expect(script.regenerateCalls, 1);
    expect(find.text(placeholderRecoveryCode), findsOneWidget);
  });

  testWidgets('no code means no screen protection', (tester) async {
    await pumpScreen(tester);

    expect(secureFlags(), isEmpty);
  });

  testWidgets('the shown code turns screen protection on, and off when it '
      'goes (FLAG_SECURE channel)', (tester) async {
    await pumpScreen(tester, shownCode: shown);

    expect(code, findsOneWidget);
    expect(secureFlags(), [true]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-acknowledge')),
    );
    await tapVisible(tester, done);

    expect(code, findsNothing);
    expect(secureFlags(), [true, false]);
  });

  testWidgets('copying uses the sensitive, self-clearing clipboard', (
    tester,
  ) async {
    await pumpScreen(tester, shownCode: shown);

    await tapVisible(tester, find.byKey(const ValueKey('recovery-code-copy')));

    final copy = calls.singleWhere(
      (c) => c.method == SecureDisplay.copySensitiveMethod,
    );
    expect(copy.arguments, {
      'text': placeholderRecoveryCode,
      'clearAfterMs': SecureDisplay.clipboardLifetime.inMilliseconds,
    });
    expect(
      find.text('Skopiowano. Schowek zostanie wyczyszczony za minutę.'),
      findsOneWidget,
    );
  });

  testWidgets('"Gotowe" needs the "Zapisałem" acknowledgement', (tester) async {
    await pumpScreen(tester, shownCode: shown);

    expect(tester.widget<FilledButton>(done).onPressed, isNull);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-acknowledge')),
    );
    expect(tester.widget<FilledButton>(done).onPressed, isNotNull);
  });

  testWidgets('leaving before the acknowledgement is blocked', (tester) async {
    await pumpScreen(tester, shownCode: shown);

    final popScope = tester.widget<PopScope<Object?>>(
      find.byWidgetPredicate((widget) => widget is PopScope),
    );
    expect(popScope.canPop, isFalse);
    popScope.onPopInvokedWithResult?.call(false, null);
    await tester.pumpAndSettle();

    expect(
      find.text('Najpierw potwierdź, że kod został zapisany.'),
      findsOneWidget,
    );
  });

  testWidgets('screen recording hides the code (iOS captureChanged)', (
    tester,
  ) async {
    await pumpScreen(tester, shownCode: shown);

    Future<void> captured(bool value) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            SecureDisplay.channel.name,
            SecureDisplay.channel.codec.encodeMethodCall(
              MethodCall(SecureDisplay.captureChangedMethod, {
                'captured': value,
              }),
            ),
            (_) {},
          );
      await tester.pumpAndSettle();
    }

    await captured(true);
    expect(code, findsNothing);
    expect(
      find.text(
        'Kod jest ukryty, gdy ekran jest nagrywany lub aplikacja działa w '
        'tle.',
      ),
      findsOneWidget,
    );

    await captured(false);
    expect(code, findsOneWidget);
  });

  testWidgets('the code is hidden while the app is in the background', (
    tester,
  ) async {
    await pumpScreen(tester, shownCode: shown);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(code, findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(code, findsOneWidget);
  });

  testWidgets('a failed regeneration shows the error', (tester) async {
    script.failure = const ApiFailure.unreachable();
    await pumpScreen(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-generate')),
    );
    await tester.tap(find.byKey(const ValueKey('recovery-code-confirm')));
    await tester.pumpAndSettle();

    expect(find.byType(MessageBanner), findsOneWidget);
    expect(code, findsNothing);
  });

  testWidgets('SecureDisplay falls back to the plain clipboard and clears '
      'it later', (tester) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          ..setMockMethodCallHandler(
            SecureDisplay.channel,
            (call) async => throw MissingPluginException(),
          );
    String? clipboard;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      switch (call.method) {
        case 'Clipboard.setData':
          clipboard = (call.arguments as Map)['text'] as String?;
        case 'Clipboard.getData':
          return {'text': clipboard};
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await SecureDisplay.copySensitive('SECRET');
    expect(clipboard, 'SECRET');

    await tester.pump(SecureDisplay.clipboardLifetime);
    await tester.pump();
    expect(clipboard, '');
  });
}
