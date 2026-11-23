import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

/// A newer GI Core or firmware may add fields and enum values; the app must
/// keep working and treat what it does not know as unknown, never crash.
void main() {
  Map<String, dynamic> listItem() => {
    ...(fixtureObject('DevicesController_list/seeded.json')['items'] as List)
        .cast<Map<String, dynamic>>()
        .first,
  };

  test('a list item with unknown enum values and extra fields decodes', () {
    final item = DeviceListItem.fromJson({
      ...listItem(),
      'status': 'quantum',
      'type': 'TOASTER',
      'communicationMode': 'CARRIER_PIGEON',
      'connectivityState': 'SULKING',
      'currentState': 'LEVITATING',
      'somethingNew': {'nested': true},
    });

    expect(item.connectivityState, ConnectivityState.unknown);
    expect(item.currentState, FirmwareState.unknown);
    expect(item.type, DeviceType.unknown);
    expect(item.communicationMode, CommunicationMode.unknown);
    expect(item.status, DeviceListStatus.unknown);
  });

  test('a detail with unknown values decodes, entities keep their rest', () {
    final detail = DeviceDetail.fromJson({
      ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
      'status': 'hibernating',
      'connectivityState': 'SULKING',
      'extra': 1,
      'controlStrategy': {
        'targetTemperatureCelsius': '55.000000',
        'hysteresisCelsius': 4,
        'mode': 'TURBO',
        'extra': true,
      },
      'entities': [
        {
          'id': 'e1',
          'displayName': 'x',
          'sourceName': 'x',
          'domain': 'hologram',
          'readable': true,
          'writable': false,
          'availability': true,
          'enabled': true,
          'value': null,
          'lastSeenAt': null,
          'extra': [1, 2],
        },
      ],
    });

    expect(detail.connectivityState, ConnectivityState.unknown);
    expect(detail.status, ProductStatus.unknown);
    expect(detail.controlStrategy?.mode, ControlStrategyMode.unknown);
    expect(detail.controlStrategy?.targetTemperatureCelsius, 55);
    expect(detail.entities.single.domain, EntityDomain.unknown);
    expect(detail.entities.single.value, isA<EntityValueNone>());
  });

  test('a firmware state the app does not know is unknown, not an error', () {
    expect(FirmwareState.tryParse('OVERCLOCKED'), FirmwareState.unknown);
    expect(FirmwareState.tryParse('SAFE_MODE'), FirmwareState.safeMode);
    expect(FirmwareState.tryParse(7), isNull);
  });

  test('heartbeat diagnostics tolerate six-decimal floats and odd shapes', () {
    const diagnostics = DeviceDiagnostics({
      'currentState': 'HEATING',
      'activeFaults': ['SENSOR_STALE', 'SOMETHING_NEW'],
      'uptimeMs': 93784000.0,
      'wifi': {'rssi': -92.0},
      'relay2': {'commanded': true, 'output': false},
      'supplyTemperature': {'filtered': '45.500000', 'status': 'NEW_STATUS'},
    });

    expect(diagnostics.activeFaultCount, 2);
    expect(diagnostics.wifiRssi, -92);
    expect(diagnostics.uptime, const Duration(milliseconds: 93784000));
  });
}
