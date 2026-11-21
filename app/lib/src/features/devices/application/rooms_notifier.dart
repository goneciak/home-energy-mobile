import 'dart:async';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rooms_notifier.g.dart';

/// `GET /rooms`, loaded when a screen that shows rooms opens and on
/// pull-to-refresh; rooms rarely change, so they are not polled (plan §11).
@riverpod
class RoomsNotifier extends _$RoomsNotifier {
  late Future<void> Function() _refresh;

  @override
  PolledData<List<Room>> build() {
    final repository = ref.watch(roomsRepositoryProvider);
    // Bound to this build: after a rebuild (another repository) a new load
    // never joins, nor is overwritten by, one of the previous build.
    final buildRef = ref;
    Future<void>? inFlight;

    Future<void> load() async {
      state = state.refreshing();
      try {
        final rooms = await repository.fetchRooms();
        if (buildRef.mounted) state = state.succeeded(rooms);
      } on Object catch (error) {
        if (buildRef.mounted) state = state.failed(error);
      }
    }

    _refresh = () => inFlight ??= load().whenComplete(() => inFlight = null);
    scheduleMicrotask(() {
      if (buildRef.mounted) unawaited(_refresh());
    });
    return PolledData(data: repository.lastRooms, isRefreshing: true);
  }

  /// Reloads the rooms; joins a load already running. Never throws: the
  /// error is kept in the state next to the last good rooms.
  Future<void> refresh() => _refresh();
}
