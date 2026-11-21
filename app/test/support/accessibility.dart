import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether [node] lets the user change something: a toggle, checkbox,
/// radio, slider, editable text or an adjustable value.
bool isWriteControl(SemanticsNode node) {
  final data = node.getSemanticsData();
  final flags = data.flagsCollection;
  return flags.isToggled != Tristate.none ||
      flags.isChecked != CheckedState.none ||
      flags.isInMutuallyExclusiveGroup ||
      flags.isSlider ||
      (flags.isTextField && !flags.isReadOnly) ||
      data.hasAction(SemanticsAction.increase) ||
      data.hasAction(SemanticsAction.decrease) ||
      data.hasAction(SemanticsAction.setText);
}

/// Read-only screens expose no write control in the semantics tree, whatever
/// widget would draw it (plan §12, M1 scope).
Future<void> expectNoWriteControls(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await tester.pump();
  expect(
    find.semantics.byPredicate(
      isWriteControl,
      describeMatch: (plurality) => 'write controls',
    ),
    findsNothing,
  );
  handle.dispose();
}

/// Tap targets, labels and text contrast of the current screen (plan §12.9,
/// DoD §17.2).
Future<void> expectAccessibilityGuidelines(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await tester.pump();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}
