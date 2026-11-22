import 'dart:ui' show Tristate;

import 'package:alchemist/alchemist.dart' show PumpAction, onlyPumpAndSettle;
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import 'golden.dart';

/// What a screen reader sees: the semantics tree of the current screen,
/// read once. Use [ScreenSemantics.read] after the screen has settled.
final class ScreenSemantics {
  const new(this.nodes);

  /// Reads the tree. Semantics must be enabled (see [auditedScreen]).
  factory read(WidgetTester tester) {
    // The test binding's own pipeline owner is the one that builds the
    // semantics of the tested widgets.
    // ignore: deprecated_member_use
    final owner = tester.binding.pipelineOwner.semanticsOwner;
    final root = owner?.rootSemanticsNode;
    expect(root, isNotNull, reason: 'semantics are not enabled for the test');
    final found = <SemanticsData>[];
    void walk(SemanticsNode node) {
      // A merged node is read as part of its parent.
      if (!node.isInvisible && !node.isMergedIntoParent) {
        found.add(node.getSemanticsData());
      }
      node.visitChildren((child) {
        walk(child);
        return true;
      });
    }

    walk(root!);
    return ScreenSemantics(found);
  }

  /// Every node of the tree below the root, in traversal order.
  final List<SemanticsData> nodes;

  /// Labels of the headings, in reading order.
  List<String> get headings => [
    for (final data in nodes)
      if (data.flagsCollection.isHeader && data.label.isNotEmpty) data.label,
  ];

  /// Labels of the live regions: what a screen reader announces when it
  /// changes without a user action.
  List<String> get liveRegions => [
    for (final data in nodes)
      if (data.flagsCollection.isLiveRegion && data.label.isNotEmpty)
        data.label,
  ];

  /// Whether the node can be tapped, toggled or edited by the user.
  static bool isInteractive(SemanticsData data) =>
      data.hasAction(SemanticsAction.tap) ||
      data.hasAction(SemanticsAction.longPress) ||
      data.flagsCollection.isTextField ||
      data.flagsCollection.isToggled != Tristate.none;

  /// Labels of everything the user can operate; an empty entry is a control
  /// a screen reader cannot name.
  List<String> get controls => [
    for (final data in nodes)
      if (isInteractive(data) && !data.flagsCollection.isHidden) _name(data),
  ];

  static String _name(SemanticsData data) {
    final text = [
      data.label,
      data.tooltip,
      data.hint,
      data.value,
    ].where((part) => part.isNotEmpty).join(' ');
    return text;
  }

  /// Every control has a spoken name.
  void expectControlsNamed({bool requireAny = true}) {
    expect(
      controls,
      everyElement(isNotEmpty),
      reason: 'a tappable, toggleable or editable node has no label',
    );
    if (requireAny) {
      expect(controls, isNotEmpty, reason: 'the screen has no control at all');
    }
  }

  /// A control whose name contains [text].
  void expectControl(Pattern text) => expect(
    controls.any((name) => name.contains(text)),
    isTrue,
    reason: 'no control named like "$text" among $controls',
  );

  /// The headings contain [expected] in this order (others may sit between).
  void expectHeadingsInOrder(List<String> expected) {
    var index = 0;
    for (final heading in headings) {
      if (index < expected.length && heading.contains(expected[index])) {
        index++;
      }
    }
    expect(
      index,
      expected.length,
      reason: 'headings $headings do not hold $expected in order',
    );
  }

  /// A live region announces something containing [text].
  void expectLiveRegion(Pattern text) => expect(
    liveRegions.any((label) => label.contains(text)),
    isTrue,
    reason: 'no live region containing "$text" among $liveRegions',
  );
}

/// A test of the semantics of [screen] as a 430 x 932 phone shows it
/// (Polish, text scale 1.0) with semantics enabled: after [prepare], pumping
/// and [settle], [act] moves the screen to the state under test and [verify]
/// reads what a screen reader sees.
@isTest
void auditedScreen(
  String description, {
  required Widget Function() screen,
  required void Function(ScreenSemantics semantics, WidgetTester tester) verify,
  List<Override> Function()? overrides,
  Future<void> Function(WidgetTester tester)? prepare,
  PumpAction settle = onlyPumpAndSettle,
  Future<void> Function(WidgetTester tester)? act,
}) {
  testWidgets(description, (tester) async {
    tester.view
      ..physicalSize = GoldenDevice.largePhone.size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final handle = tester.ensureSemantics();
    try {
      await prepare?.call(tester);
      await tester.pumpWidget(
        GoldenScreen(
          size: GoldenDevice.largePhone.size,
          locale: const Locale('pl'),
          textScale: 1,
          screen: screen,
          overrides: overrides ?? () => const <Override>[],
        ),
      );
      await settle(tester);
      await act?.call(tester);
      verify(ScreenSemantics.read(tester), tester);
    } finally {
      handle.dispose();
    }
  });
}
