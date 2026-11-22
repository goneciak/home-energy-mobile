import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/router/app_shell.dart';
import 'package:gi_home/src/features/attention/application/attention_feed_notifier.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/test_app.dart';

void main() {
  Future<void> pumpIcon(WidgetTester tester, int count) => tester.pumpWidget(
    testScreen(
      const Scaffold(body: Center(child: AttentionTabIcon(selected: false))),
      overrides: [attentionBadgeCountProvider.overrideWithValue(count)],
    ),
  );

  testWidgets('shows the number of entries still reported', (tester) async {
    await pumpIcon(tester, 3);
    expect(find.byKey(const ValueKey('attention-badge')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('3 sprawy')), findsOneWidget);
  });

  testWidgets('caps the number at 99+', (tester) async {
    await pumpIcon(tester, 120);
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('no badge when nothing needs attention', (tester) async {
    await pumpIcon(tester, 0);
    expect(find.byKey(const ValueKey('attention-badge')), findsNothing);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });
}
