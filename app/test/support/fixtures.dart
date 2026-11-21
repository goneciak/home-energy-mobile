import 'dart:convert';
import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';

/// Recorded GI Core responses shared with `gi_core_api` (secrets redacted);
/// they are the source of truth for response shapes. Tests run from `app/`.
///
/// Layout (plan §17.4): `core/<backendRef>/<endpointId>/<case>.json` under
/// `packages/gi_core_api/test/fixtures`, where `backendRef` is `shortSha` in
/// `contract/backend.lock`; [path] is `<endpointId>/<case>.json`.
Object? fixtureJson(String path) =>
    jsonDecode(File('$_fixturesDir/$path').readAsStringSync());

Map<String, dynamic> fixtureObject(String path) =>
    fixtureJson(path)! as Map<String, dynamic>;

final String _fixturesDir = () {
  const lock = '../contract/backend.lock';
  for (final line in File(lock).readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('shortSha=')) {
      final ref = trimmed.substring('shortSha='.length).trim();
      return '../packages/gi_core_api/test/fixtures/core/$ref';
    }
  }
  throw StateError('$lock has no shortSha=');
}();

/// `DevicesController_list/seeded.json`: 3 seeded devices, one per room plus
/// one without.
List<DeviceListItem> fixtureDevices() => [
  for (final item
      in fixtureObject('DevicesController_list/seeded.json')['items'] as List)
    DeviceListItem.fromJson(item as Map<String, dynamic>),
];

/// `RoomsController_list/seeded.json`: "Kotłownia" and "Salon".
List<Room> fixtureRooms() => [
  for (final room in fixtureJson('RoomsController_list/seeded.json')! as List)
    Room.fromJson(room as Map<String, dynamic>),
];

/// The seeded device without a room, as listed.
Map<String, dynamic> fixtureDeviceJson({
  String id = '341584fe-d238-44e5-b97b-191ff594bb09',
}) => {
  ...(fixtureObject('DevicesController_list/seeded.json')['items'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((d) => d['id'] == id),
};

/// A listed device built on a recorded one, with [overrides] applied.
DeviceListItem listedDevice(Map<String, Object?> overrides) =>
    DeviceListItem.fromJson({...fixtureDeviceJson(), ...overrides});

/// `DevicesController_get/no_room_no_entities.json` (the seeded device
/// without a room or entities).
DeviceDetail fixtureDetail([Map<String, Object?> overrides = const {}]) =>
    DeviceDetail.fromJson({
      ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
      ...overrides,
    });

/// A heating controller with entities shaped like the backend's
/// `toEntityResponse` (`device-details-query.service.ts`) and GI Edge
/// heartbeat diagnostics: relay, temperatures, a text and a structured
/// value, an unavailable and a disabled entity.
Map<String, Object?> entityRichDetailJson() => {
  ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
  'id': '60d5a6b9-e974-45b0-b3ee-43e264d1ec85',
  'name': 'Sterownik kotłowni',
  'manufacturer': 'GI Industries',
  'model': 'kotlownia',
  'firmwareVersion': '1.4.2',
  'status': 'online',
  'roomId': '15a6de6e-f36c-4741-9775-53cd03413ccb',
  'communicationMode': 'GI_EDGE_V1',
  'connectivityState': 'ONLINE',
  'lastSeenAt': '2026-11-18T07:40:30.000Z',
  'heatingRelayEntityId': 'ent-relay-boiler',
  'pumpRelayEntityId': 'ent-relay-pump',
  'controlTemperatureEntityId': 'ent-supply',
  'heatingSuspended': false,
  'dryRun': true,
  'pvBoostActive': true,
  'entities': [
    _entity(
      'ent-relay-boiler',
      'Kocioł',
      'relay1',
      domain: 'switch',
      value: true,
      writable: true,
      function: {'code': 'HEATING', 'name': 'Grzanie'},
    ),
    _entity(
      'ent-relay-pump',
      'relay2',
      'relay2',
      domain: 'switch',
      value: false,
    ),
    _entity(
      'ent-supply',
      'Temperatura zasilania',
      'supply_temp',
      domain: 'sensor',
      deviceClass: 'temperature',
      value: 54.25,
      unit: '°C',
      role: {'code': 'SUPPLY', 'name': 'Zasilanie'},
    ),
    _entity(
      'ent-mode',
      'Tryb pracy',
      'mode',
      domain: 'text_sensor',
      value: 'eco',
    ),
    _entity(
      'ent-blob',
      'Konfiguracja',
      'config',
      domain: 'climate',
      value: {'target': 21, 'mode': 'heat'},
    ),
    _entity(
      'ent-return',
      'Temperatura powrotu',
      'return_temp',
      domain: 'sensor',
      value: 41,
      unit: '°C',
      availability: false,
    ),
    _entity(
      'ent-old',
      'Stary czujnik',
      'old_sensor',
      domain: 'hologram',
      value: null,
      enabled: false,
    ),
  ],
  'diagnostics': {
    'currentState': 'HEATING',
    'activeFaults': ['F_SENSOR'],
    'safetyInterlockActive': false,
    'wifi': {'rssi': -61, 'ip': '192.168.1.40'},
    'uptimeMs': 93784000,
    'bootCount': 12,
    'rebootLoopDetected': false,
  },
  'controlStrategy': {
    'targetTemperatureCelsius': 55,
    'hysteresisCelsius': 4,
    'mode': 'AUTO',
  },
  'baseControlStrategy': {
    'targetTemperatureCelsius': 55,
    'hysteresisCelsius': 4,
    'mode': 'AUTO',
  },
};

Map<String, Object?> _entity(
  String id,
  String displayName,
  String sourceName, {
  required String domain,
  required Object? value,
  String? deviceClass,
  String? unit,
  bool writable = false,
  bool availability = true,
  bool enabled = true,
  Map<String, String>? function,
  Map<String, String>? role,
}) => {
  'id': id,
  'displayName': displayName,
  'sourceName': sourceName,
  'domain': domain,
  'deviceClass': deviceClass,
  'value': value,
  'unit': unit,
  'readable': true,
  'writable': writable,
  'availability': availability,
  'lastSeenAt': '2026-11-18T07:40:30.000Z',
  'assignedFunction': function,
  'assignedRole': role,
  'enabled': enabled,
};
