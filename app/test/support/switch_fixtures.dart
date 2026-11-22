import 'dart:async';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/data/device_command_source.dart';

import 'fixtures.dart';

/// Entity id of the non-heating switch added by [switchDeviceDetail]
/// (GI Edge relay 3, "Oświetlenie kotłowni").
const lightEntityId = 'ent-relay-light';

/// The heating controller of [entityRichDetailJson] with a third, ordinary
/// writable switch ([lightEntityId], `relay3`), ONLINE.
///
/// [relay3] becomes `diagnostics.relay3` when given; otherwise, with
/// [reportLight], the last heartbeat reported it as [lightOn] (output and
/// commanded). [lastSeenAt] is the
/// device-level heartbeat time (server clock). [transform] may rewrite
/// the JSON before decoding (e.g. `localJson` for goldens).
DeviceDetail switchDeviceDetail({
  String mode = 'GI_EDGE_V1',
  bool dryRun = false,
  bool heatingSuspended = false,
  bool lightOn = false,
  bool lightEnabled = true,
  bool lightAvailable = true,
  DateTime? lastSeenAt,
  Map<String, Object?>? relay3,
  bool reportLight = true,
  String connectivity = 'ONLINE',
  String currentState = 'HEATING',
  Map<String, Object?> Function(Map<String, Object?> json)? transform,
}) {
  final json = entityRichDetailJson();
  final entities = [...json['entities']! as List<Object?>];
  final pump = entities[1]! as Map<String, Object?>;
  entities.add({
    ...pump,
    'id': lightEntityId,
    'displayName': 'Oświetlenie kotłowni',
    'sourceName': 'relay_3',
    'value': lightOn,
    'writable': true,
    'enabled': lightEnabled,
    'availability': lightAvailable,
  });
  final detail = <String, Object?>{
    ...json,
    'communicationMode': mode,
    'dryRun': dryRun,
    'heatingSuspended': heatingSuspended,
    'connectivityState': connectivity,
    'lastSeenAt': (lastSeenAt ?? DateTime.utc(2026, 11, 18, 7, 40, 30))
        .toIso8601String(),
    'entities': entities,
    'diagnostics': {
      ...json['diagnostics']! as Map<String, Object?>,
      'currentState': currentState,
      'relay3':
          ?(relay3 ??
          (reportLight ? {'output': lightOn, 'commanded': lightOn} : null)),
    },
  };
  return DeviceDetail.fromJson(transform?.call(detail) ?? detail);
}

/// Scriptable [DeviceCommandSource]: answers with [result] or throws
/// [failure]; every call is recorded.
class FakeCommandSource implements DeviceCommandSource {
  SwitchCommandResult? result;
  ApiFailure? failure;

  /// When set, the request waits for it, like one still in flight.
  Future<void>? gate;

  final List<(String, String, bool)> calls = [];

  @override
  Future<SwitchCommandResult> setSwitchState(
    String deviceId,
    String entityId, {
    required bool state,
  }) async {
    calls.add((deviceId, entityId, state));
    if (gate case final gate?) await gate;
    if (failure case final failure?) throw failure;
    return result!;
  }

  /// Answer of `setHeatingSuspended`; `null` throws [failure] or a 500.
  DeviceListItem Function(bool suspended)? suspendResult;
  final List<(String, bool)> suspendCalls = [];

  @override
  Future<DeviceListItem> setHeatingSuspended(
    String deviceId, {
    required bool suspended,
  }) async {
    suspendCalls.add((deviceId, suspended));
    if (gate case final gate?) await gate;
    if (failure case final failure?) throw failure;
    return suspendResult!(suspended);
  }

  ControlStrategyUpdateResult? strategyResult;
  final List<(String, ControlStrategy)> strategyCalls = [];

  @override
  Future<ControlStrategyUpdateResult> updateControlStrategy(
    String deviceId,
    ControlStrategy strategy,
  ) async {
    strategyCalls.add((deviceId, strategy));
    if (gate case final gate?) await gate;
    if (failure case final failure?) throw failure;
    return strategyResult!;
  }
}
