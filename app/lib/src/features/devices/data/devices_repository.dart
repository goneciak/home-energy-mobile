import 'package:gi_core_api/gi_core_api.dart';

import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/devices/data/device_read_source.dart';

/// Device list and device details, keeping the last good value of each with
/// the time it arrived (plan §8.3).
final class DevicesRepository {
  new(this._source, {required this._clock});

  final DeviceReadSource _source;
  final Clock _clock;

  Fetched<List<DeviceListItem>>? _devices;
  final _details = <String, Fetched<DeviceDetail>>{};

  /// Last good device list, if any.
  Fetched<List<DeviceListItem>>? get lastDevices => _devices;

  /// Last good details of device [id], if any.
  Fetched<DeviceDetail>? lastDevice(String id) => _details[id];

  /// Throws [ApiFailure]; the previous value is kept on failure.
  Future<Fetched<List<DeviceListItem>>> fetchDevices() async {
    final items = await _source.devices();
    return _devices = Fetched(List.unmodifiable(items), _clock());
  }

  /// Throws [ApiFailure]. A device that no longer exists ([NotFoundFailure])
  /// is dropped from the cache; other failures keep the previous value.
  Future<Fetched<DeviceDetail>> fetchDevice(String id) async {
    try {
      final detail = await _source.device(id);
      return _details[id] = Fetched(detail, _clock());
    } on NotFoundFailure {
      _details.remove(id);
      rethrow;
    }
  }

  /// Forgets everything, e.g. when the user logs out.
  void clear() {
    _devices = null;
    _details.clear();
  }
}
