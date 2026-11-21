import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/data/device_read_source.dart';

/// Scriptable [DeviceReadSource]: each endpoint answers with its current
/// value or throws its current failure, and every call is recorded.
class FakeDeviceSource implements DeviceReadSource {
  new({
    this.deviceList = const [],
    this.roomList = const [],
    Map<String, DeviceDetail>? details,
  }) : details = {...?details};

  List<DeviceListItem> deviceList;
  List<Room> roomList;
  final Map<String, DeviceDetail> details;

  ApiFailure? devicesFailure;
  ApiFailure? roomsFailure;
  ApiFailure? detailFailure;

  /// When set, `devices()` / `device()` wait for it before answering, like
  /// a request still in flight.
  Future<void>? devicesGate;
  Future<void>? roomsGate;
  Future<void>? detailGate;

  final List<String> calls = [];

  @override
  Future<List<DeviceListItem>> devices() async {
    calls.add('devices');
    if (devicesGate case final gate?) await gate;
    if (devicesFailure case final failure?) throw failure;
    return deviceList;
  }

  @override
  Future<List<Room>> rooms() async {
    calls.add('rooms');
    if (roomsGate case final gate?) await gate;
    if (roomsFailure case final failure?) throw failure;
    return roomList;
  }

  @override
  Future<DeviceDetail> device(String id) async {
    calls.add('device:$id');
    if (detailGate case final gate?) await gate;
    if (detailFailure case final failure?) throw failure;
    return details[id] ??
        (throw const ApiFailure.notFound(code: 'DEVICE_NOT_FOUND'));
  }
}
