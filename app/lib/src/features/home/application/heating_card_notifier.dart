import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/core/polling/polling_budget.dart';
import 'package:gi_home/src/core/polling/ref_polling.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/application/device_snapshot.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/home/domain/device_groups.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'heating_card_notifier.g.dart';

/// At most this many heating card requests run at once (plan §11).
const int heatingCardMaxConcurrency = PollingBudget.heatingCardMaxConcurrency;

/// Shared by every heating card, so Home never has more than
/// [heatingCardMaxConcurrency] `GET /devices/:id` requests in flight.
@Riverpod(keepAlive: true)
ConcurrencyLimiter heatingCardLimiter(Ref ref) =>
    ConcurrencyLimiter(heatingCardMaxConcurrency);

/// The devices of the latest list that get a heating card, in list order.
/// Their number decides the cadence of each card
/// ([heatingCardPolicyProvider]); their order spreads the cards over that
/// cadence.
@Riverpod(keepAlive: true)
List<String> heatingCardIds(Ref ref) {
  final devices = ref.watch(lastDeviceListProvider);
  return [
    for (final device in devices?.value ?? const <DeviceListItem>[])
      if (hasHeatingCard(device)) device.id,
  ];
}

/// How often each heating card polls and when its data counts as outdated:
/// every 15 s for up to two cards, slower beyond that so that Home with the
/// device list stays within the request budget of one phone
/// ([PollingBudget.heatingCardInterval], ADR 0016).
@Riverpod(keepAlive: true)
FreshnessPolicy heatingCardPolicy(Ref ref) =>
    FreshnessPolicy.heatingCards(ref.watch(heatingCardIdsProvider).length);

/// `GET /devices/:id` of one heating device shown as a card on Home, polled
/// every 15 s (slower with more than two cards) while the card is on screen
/// and the app is in the foreground (plan §4.1, §11). Only the card widget
/// watches it, and Home builds its rows lazily, so a card scrolled out of
/// view (or never scrolled to) sends no requests. Only heating devices
/// recognised from the list get a card, so Home never asks for details of
/// other devices.
///
/// Every state is also published to [heatingCardResultsProvider], which the
/// Home condition reads without keeping the card alive.
///
/// A failure keeps the last good details next to the error (the Home
/// condition then reports limited data, plan §11.1) and backs off like
/// every poller; a tick is skipped while a request, or its wait for a free
/// slot, is still running. A card that comes back into view with details
/// younger than the polling interval waits for the next tick instead of
/// asking again, so scrolling back and forth does not add requests.
@riverpod
class HeatingCardNotifier extends _$HeatingCardNotifier {
  late ForegroundPoller _poller;

  @override
  PolledData<DeviceDetail> build(String deviceId) {
    final repository = ref.watch(devicesRepositoryProvider);
    final limiter = ref.watch(heatingCardLimiterProvider);
    final clock = ref.watch(clockProvider);
    final policy = ref.read(heatingCardPolicyProvider);
    Duration phaseOf(FreshnessPolicy policy) {
      final ids = ref.read(heatingCardIdsProvider);
      final slot = ids.indexOf(deviceId);
      return slot <= 0 ? Duration.zero : policy.interval * slot ~/ ids.length;
    }

    // A result of an earlier build (another repository) is never committed.
    final buildRef = ref;
    void publish(PolledData<DeviceDetail> next) {
      if (!buildRef.mounted) return;
      state = next;
      buildRef.read(heatingCardResultsProvider.notifier).put(deviceId, next);
    }

    final cached = repository.lastDevice(deviceId);
    var firstRun = true;
    _poller = ref.pollWhileWatched(
      interval: policy.interval,
      phase: phaseOf(policy),
      onSharedFailure: (error) => publish(state.failed(error)),
      task: () async {
        if (firstRun) {
          firstRun = false;
          if (cached != null &&
              FreshnessPolicy.ageOf(cached.fetchedAt, clock()) <
                  policy.interval) {
            publish(PolledData(data: cached));
            return;
          }
        }
        publish(state.refreshing());
        try {
          final detail = await limiter.run(
            () => repository.fetchDevice(deviceId),
          );
          publish(state.succeeded(detail));
        } on NotFoundFailure catch (error) {
          // Gone since the list was read: show nothing stale; the next list
          // poll drops the card.
          publish(PolledData(error: error));
          rethrow;
        } on Object catch (error) {
          publish(state.failed(error));
          rethrow;
        }
      },
    );
    // More or fewer cards on Home change the cadence of the running poller.
    ref.listen(heatingCardIdsProvider, (_, _) {
      _poller.phase = phaseOf(ref.read(heatingCardPolicyProvider));
    });
    ref.listen(heatingCardPolicyProvider, (_, next) {
      _poller
        ..interval = next.interval
        ..phase = phaseOf(next);
    });
    return PolledData(data: cached, isRefreshing: true);
  }

  /// Pull-to-refresh; joins a refresh already running.
  Future<void> refresh() => _poller.refresh();
}

/// The latest state of every heating card built in this session, by device
/// id. Home's condition is computed from it (plan §11.1) instead of from
/// the cards themselves, so it never keeps an off-screen card polling; a
/// card out of view keeps counting with its last result. Forgotten with a
/// new appliance or user (plan §8.3).
@Riverpod(keepAlive: true)
class HeatingCardResults extends _$HeatingCardResults {
  @override
  Map<String, PolledData<DeviceDetail>> build() {
    ref
      ..watch(devicesRepositoryProvider)
      ..watch(currentUserProvider.select((user) => user?.id));
    return const {};
  }

  void put(String deviceId, PolledData<DeviceDetail> card) {
    if (state[deviceId] == card) return;
    state = Map.unmodifiable({...state, deviceId: card});
  }
}
