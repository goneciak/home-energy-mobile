import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/attention/domain/attention_feed.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_snapshot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attention_feed_notifier.g.dart';

/// The "Uwaga" list and the badge count (plan §15), from the latest device
/// list and the signed-in user. It never polls by itself: the list is
/// refreshed by Home, device details or the "Uwaga" screen while one of
/// them is visible. Resolved entries are remembered in memory for 24 h and
/// forgotten with the user.
@Riverpod(keepAlive: true)
class AttentionFeedNotifier extends _$AttentionFeedNotifier {
  @override
  AttentionFeed build() {
    final user = ref.watch(currentUserProvider);
    final devices = ref.watch(lastDeviceListProvider);
    final previous = stateOrNull;
    if (user == null) return const AttentionFeed.empty();
    return AttentionFeed.derive(
      userId: user.id,
      devices: devices,
      mustChangePassword: user.mustChangePassword,
      now: ref.read(clockProvider)(),
      previous: previous,
    );
  }
}

/// Number on the "Uwaga" tab: entries still reported.
@riverpod
int attentionBadgeCount(Ref ref) => ref.watch(attentionFeedProvider).badgeCount;
