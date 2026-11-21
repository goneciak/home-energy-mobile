import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/diagnostics/application/stale_app_notifier.dart';
import 'package:material_ui/material_ui.dart';

/// "Zaktualizuj aplikację" above every screen while [staleAppProvider] is
/// set (plan §16 point 4). It never blocks: the app keeps working with what
/// it can read, and the user may hide the banner. "Otwórz sklep" appears
/// only when the build has a store link for this platform
/// (`config/<flavor>.json`).
class StaleAppBanner extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(staleAppProvider)) return const SizedBox.shrink();
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final storeUrl = ref
        .watch(appConfigProvider)
        .storeUrlFor(Theme.of(context).platform);
    return Material(
      key: const ValueKey('stale-app-banner'),
      color: tokens.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(tokens.gap, 8, tokens.gap, 8),
          child: MessageBanner(
            tone: MessageTone.warning,
            message: l10n.staleAppTitle,
            detail: l10n.staleAppBody,
            action: Wrap(
              spacing: 8,
              children: [
                if (storeUrl != null)
                  TextButton.icon(
                    key: const ValueKey('stale-app-open-store'),
                    onPressed: () => unawaited(
                      ref.read(externalUrlOpenerProvider)(storeUrl),
                    ),
                    icon: const Icon(Icons.system_update_outlined),
                    label: Text(l10n.staleAppOpenStore),
                  ),
                TextButton(
                  key: const ValueKey('stale-app-dismiss'),
                  onPressed: ref.read(staleAppProvider.notifier).dismiss,
                  child: Text(l10n.staleAppDismiss),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [child] (the app's navigator) with the [StaleAppBanner] above it; the
/// banner takes the status bar inset, so the screens below do not add it
/// again.
class StaleAppBannerHost extends ConsumerWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The same children in either case, so the navigator below keeps its
    // state when the banner appears.
    return Column(
      children: [
        const StaleAppBanner(),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: ref.watch(staleAppProvider),
            child: child,
          ),
        ),
      ],
    );
  }
}
