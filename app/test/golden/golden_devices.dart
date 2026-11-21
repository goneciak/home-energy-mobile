import 'package:gi_core_api/gi_core_api.dart';

import '../support/fixtures.dart';
import '../support/golden.dart';

/// The recorded devices (`DevicesController_list/seeded.json`).
abstract final class GoldenIds {
  /// "Czujnik bez pokoju", no room.
  static const sensor = '341584fe-d238-44e5-b97b-191ff594bb09';

  /// "Lampa w salonie", room "Salon".
  static const lamp = 'fbc51583-9b91-420e-bd94-694c691dcf63';

  /// "Sterownik kotłowni", room "Kotłownia"; the heating controller.
  static const boiler = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';
}

/// A recorded device as listed, last seen [seenAgo] before [goldenNow] in
/// [connectivity], with [overrides] applied.
DeviceListItem goldenListed(
  String id, {
  String connectivity = 'ONLINE',
  Duration? seenAgo = const Duration(seconds: 30),
  Map<String, Object?> overrides = const {},
}) => DeviceListItem.fromJson(
  localJson({
    ...fixtureDeviceJson(id: id),
    'connectivityState': connectivity,
    'status': connectivity.toLowerCase(),
    'lastSeenAt': seenAgo == null
        ? null
        : goldenNow.subtract(seenAgo).toIso8601String(),
    if (id == GoldenIds.boiler) ...{
      'heatingRelayEntityId': 'ent-relay-boiler',
      'pumpRelayEntityId': 'ent-relay-pump',
      'controlTemperatureEntityId': 'ent-supply',
    },
    ...overrides,
  }),
);

/// The heating controller's details (relays, readings, diagnostics), not
/// in dry-run and without faults unless [overrides] say so.
DeviceDetail goldenBoilerDetail([Map<String, Object?> overrides = const {}]) {
  final recorded = entityRichDetailJson();
  return DeviceDetail.fromJson(
    localJson({
      ...recorded,
      'lastSeenAt': goldenNow
          .subtract(const Duration(seconds: 30))
          .toIso8601String(),
      'dryRun': false,
      'diagnostics': {
        ...recorded['diagnostics']! as Map<String, Object?>,
        'activeFaults': <String>[],
      },
      ...overrides,
    }),
  );
}
