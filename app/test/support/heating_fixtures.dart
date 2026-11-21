import 'package:gi_core_api/gi_core_api.dart';

import 'fixtures.dart';
import 'switch_fixtures.dart';

/// `{"targetTemperatureCelsius", "hysteresisCelsius", "mode"}` as GI Core
/// stores it.
Map<String, Object?> strategyJson(
  double target,
  double hysteresis,
  String mode,
) => {
  'targetTemperatureCelsius': target,
  'hysteresisCelsius': hysteresis,
  'mode': mode,
};

/// The heating controller of [switchDeviceDetail] with control strategies:
/// [base] is `baseControlStrategy`, [effective] `controlStrategy` (the base
/// one when omitted, `OFF` mode while suspended like GI Core's reconcile).
/// [relays] become `diagnostics.relayN.output` (N = 1, 2, 3) and, unless
/// [commanded] is given, `diagnostics.relayN.commanded` too.
DeviceDetail heatingDetail({
  String mode = 'GI_EDGE_V1',
  Map<String, Object?>? base = const {
    'targetTemperatureCelsius': 55,
    'hysteresisCelsius': 4,
    'mode': 'AUTO',
  },
  Map<String, Object?>? effective,
  bool heatingSuspended = false,
  bool dryRun = false,
  DateTime? lastSeenAt,
  List<bool>? relays,
  List<bool>? commanded,
  double? safeMax,
  String connectivity = 'ONLINE',
  Map<String, Object?> Function(Map<String, Object?> json)? transform,
}) => switchDeviceDetail(
  mode: mode,
  heatingSuspended: heatingSuspended,
  dryRun: dryRun,
  lastSeenAt: lastSeenAt,
  connectivity: connectivity,
  reportLight: false,
  transform: (json) {
    final shownEffective =
        effective ??
        (base == null ? null : {...base, if (heatingSuspended) 'mode': 'OFF'});
    final diagnostics = {...json['diagnostics']! as Map<String, Object?>};
    if (relays != null) {
      for (final (index, on) in relays.indexed) {
        diagnostics['relay${index + 1}'] = {
          'output': on,
          'commanded': commanded?[index] ?? on,
        };
      }
    }
    final result = <String, Object?>{
      ...json,
      'baseControlStrategy': base,
      'controlStrategy': shownEffective,
      'pvBoostActive': false,
      'pvHeatingConfig': safeMax == null
          ? null
          : {
              'mode': 'SURPLUS',
              'safeMaxTemperatureCelsius': safeMax,
              'shortDwellMs': 60000,
              'longDwellMs': 300000,
              'forecastFavorableProductionRatio': 0.5,
            },
      'diagnostics': diagnostics,
    };
    return transform?.call(result) ?? result;
  },
);

/// The `PATCH /devices/:id` answer (list-item shape) at [updatedAt].
DeviceListItem patchedDevice({
  required DateTime updatedAt,
  required bool suspended,
}) => listedDevice({
  'updatedAt': updatedAt.toIso8601String(),
  'heatingSuspended': suspended,
});
