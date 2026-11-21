import 'package:gi_core_api/gi_core_api.dart';

/// The read-only device endpoints the repositories depend on. Every method
/// throws only [ApiFailure].
abstract interface class DeviceReadSource {
  /// `GET /devices?limit=100`.
  Future<List<DeviceListItem>> devices();

  /// `GET /devices/:id`.
  Future<DeviceDetail> device(String id);

  /// `GET /rooms`.
  Future<List<Room>> rooms();
}

/// [DeviceReadSource] backed by the GI Core client.
final class GiCoreDeviceReadSource implements DeviceReadSource {
  const new(this._client);

  /// The server caps `limit` at 100; one page covers a home (plan §4.1).
  static const pageSize = 100;

  final GiCoreClient _client;

  @override
  Future<List<DeviceListItem>> devices() async =>
      (await _client.devices()).items;

  @override
  Future<DeviceDetail> device(String id) => _client.device(id);

  @override
  Future<List<Room>> rooms() => _client.rooms();
}
