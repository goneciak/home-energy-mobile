import 'package:gi_core_api/gi_core_api.dart';

import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/devices/data/device_read_source.dart';

/// Rooms of the home, keeping the last good list (plan §8.3).
final class RoomsRepository {
  new(this._source, {required this._clock});

  final DeviceReadSource _source;
  final Clock _clock;

  Fetched<List<Room>>? _rooms;

  /// Last good room list, if any.
  Fetched<List<Room>>? get lastRooms => _rooms;

  /// Throws [ApiFailure]. Rooms come back ordered by `sortOrder`, then
  /// name, the same order GI Core and the web panel use.
  Future<Fetched<List<Room>>> fetchRooms() async {
    final rooms = [...await _source.rooms()]..sort(compareRooms);
    return _rooms = Fetched(List.unmodifiable(rooms), _clock());
  }

  void clear() => _rooms = null;

  static int compareRooms(Room a, Room b) {
    final bySortOrder = a.sortOrder.compareTo(b.sortOrder);
    return bySortOrder != 0
        ? bySortOrder
        : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
