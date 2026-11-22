import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/widgets/demo_banner.dart';
import 'package:gi_home/src/features/demo/application/demo_mode.dart';
import 'package:material_ui/material_ui.dart';

/// [child] (the app's navigator) with the [DemoBanner] above it for as long
/// as demo mode is on, on every screen. "Zakończ demo" wipes the demo
/// state; routing then returns to the connect screen (or to the saved
/// appliance).
class DemoBannerHost extends ConsumerWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(isDemoProvider);
    // The same children in either case, so the navigator keeps its state.
    return Column(
      children: [
        if (demo)
          DemoBanner(onExit: ref.read(demoModeProvider.notifier).exit)
        else
          const SizedBox.shrink(),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: demo,
            child: child,
          ),
        ),
      ],
    );
  }
}
