@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/widgets/demo_banner.dart';
import 'package:material_ui/material_ui.dart';

import '../support/golden.dart';

/// The permanent DEMO banner (plan §19.5, §17.1) above a screen: it must
/// stay readable, with "Zakończ demo" reachable, at every text scale.
void main() {
  screenGoldens(
    'Demo: banner above a screen',
    fileName: 'demo_banner',
    screen: () => Column(
      children: [
        DemoBanner(onExit: () {}),
        Expanded(
          child: Scaffold(appBar: AppBar(title: const Text('GI Home Demo'))),
        ),
      ],
    ),
  );
}
