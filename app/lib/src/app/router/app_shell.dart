import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/account/presentation/account_prompt_host.dart';
import 'package:gi_home/src/features/attention/application/attention_feed_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Signed-in shell: tabs Dom, Uwaga and Ustawienia with a bottom
/// [NavigationBar]. The "Uwaga" tab carries the number of entries still
/// reported (plan §15). Prompts after a login are shown over it
/// ([AccountPromptHost]).
class AppShell extends StatelessWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: AccountPromptHost(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const AttentionTabIcon(selected: false),
            selectedIcon: const AttentionTabIcon(selected: true),
            label: l10n.navAttention,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

/// The "Uwaga" tab icon with a badge counting the entries still reported;
/// no badge when there are none. The count is also read out.
class AttentionTabIcon extends ConsumerWidget {
  const new({required this.selected, super.key});

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(attentionBadgeCountProvider);
    final icon = Icon(
      selected ? Icons.notifications : Icons.notifications_outlined,
    );
    if (count == 0) return icon;
    return Semantics(
      label: context.l10n.attentionBadgeSemantics(count),
      child: Badge(
        key: const ValueKey('attention-badge'),
        label: Text(count > 99 ? '99+' : '$count'),
        child: icon,
      ),
    );
  }
}
