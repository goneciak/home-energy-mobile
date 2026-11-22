import 'dart:convert';
import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';

/// What the client does with a 2xx response body, in the field-path notation
/// of `openapi.dart` (`$.items[].id`).
final class ClientShape {
  const new({this.requiredFields = const {}, this.decodedFields = const {}});

  /// Fields whose absence fails decoding.
  final Set<String> requiredFields;

  /// Every field the models read (required or not).
  final Set<String> decodedFields;

  bool requires(String path) => requiredFields.contains(path);

  bool decodes(String path) =>
      decodedFields.contains(path) || requiredFields.contains(path);
}

/// The client's decoder of one endpoint's 2xx body: the same `fromJson` /
/// `toJson` pair `GiCoreClient` (and `AuthSessionManager`) use.
final class ClientDecoder {
  const new(this.decode, this.encode);

  final Object? Function(Object? json) decode;
  final Object? Function(Object? value) encode;
}

Map<String, dynamic> _object(Object? json) => json! as Map<String, dynamic>;

/// Decoders by catalog id, mirroring `GiCoreClient`. Endpoints whose body the
/// client never reads are listed in [bodylessEndpointIds] instead.
final Map<String, ClientDecoder> clientDecoders = {
  GiEndpoints.healthLive.id: ClientDecoder(
    (json) => HealthLive.fromJson(_object(json)),
    (value) => (value! as HealthLive).toJson(),
  ),
  GiEndpoints.setupStatus.id: ClientDecoder(
    (json) => SetupStatus.fromJson(_object(json)),
    (value) => (value! as SetupStatus).toJson(),
  ),
  GiEndpoints.authLogin.id: ClientDecoder(
    (json) => LoginResponse.fromJson(_object(json)),
    (value) => (value! as LoginResponse).toJson(),
  ),
  GiEndpoints.authRefresh.id: ClientDecoder(
    (json) => RefreshResponse.fromJson(_object(json)),
    (value) => (value! as RefreshResponse).toJson(),
  ),
  GiEndpoints.authMe.id: ClientDecoder(
    (json) => CurrentUser.fromJson(_object(json)),
    (value) => (value! as CurrentUser).toJson(),
  ),
  GiEndpoints.usersMeProfile.id: ClientDecoder(
    (json) => UserProfile.fromJson(_object(json)),
    (value) => (value! as UserProfile).toJson(),
  ),
  GiEndpoints.usersMeChangePassword.id: ClientDecoder(
    (json) => ChangePasswordResult.fromJson(_object(json)),
    (value) => (value! as ChangePasswordResult).toJson(),
  ),
  GiEndpoints.roomsList.id: ClientDecoder(
    (json) => [for (final room in json! as List) Room.fromJson(_object(room))],
    (value) => [for (final room in value! as List<Room>) room.toJson()],
  ),
  GiEndpoints.devicesList.id: ClientDecoder(
    (json) => ListPage.fromJson(
      _object(json),
      (item) => DeviceListItem.fromJson(_object(item)),
    ),
    (value) =>
        (value! as ListPage<DeviceListItem>).toJson((item) => item.toJson()),
  ),
  GiEndpoints.devicesDetail.id: ClientDecoder(
    (json) => DeviceDetail.fromJson(_object(json)),
    (value) => (value! as DeviceDetail).toJson(),
  ),
  GiEndpoints.settingsSystem.id: ClientDecoder(
    (json) => SystemSettings.fromJson(_object(json)),
    (value) => (value! as SystemSettings).toJson(),
  ),
  GiEndpoints.applianceUpdatesStatus.id: ClientDecoder(
    (json) => ApplianceUpdateStatus.fromJson(_object(json)),
    (value) => (value! as ApplianceUpdateStatus).toJson(),
  ),
  GiEndpoints.setSwitchState.id: ClientDecoder(
    (json) => SwitchCommandResult.fromJson(_object(json)),
    (value) => (value! as SwitchCommandResult).toJson(),
  ),
  GiEndpoints.updateDevice.id: ClientDecoder(
    (json) => DeviceListItem.fromJson(_object(json)),
    (value) => (value! as DeviceListItem).toJson(),
  ),
  GiEndpoints.updateControlStrategy.id: ClientDecoder(
    (json) => ControlStrategyUpdateResult.fromJson(_object(json)),
    (value) => (value! as ControlStrategyUpdateResult).toJson(),
  ),
  GiEndpoints.schedulesList.id: ClientDecoder(
    (json) => [
      for (final row in json! as List) HeatingSchedule.fromJson(_object(row)),
    ],
    (value) => [
      for (final row in value! as List<HeatingSchedule>) row.toJson(),
    ],
  ),
  GiEndpoints.scheduleCreate.id: _schedule,
  GiEndpoints.scheduleUpdate.id: _schedule,
  GiEndpoints.weatherCurrent.id: ClientDecoder(
    (json) => WeatherEnvelope.fromJson(
      _object(json),
      (data) => CurrentWeather.fromJson(_object(data)),
    ),
    (value) => (value! as WeatherEnvelope<CurrentWeather>).toJson(
      (data) => data.toJson(),
    ),
  ),
  GiEndpoints.weatherHourly.id: ClientDecoder(
    (json) => WeatherEnvelope.fromJson(
      _object(json),
      (data) => [
        for (final row in data! as List) HourlyWeather.fromJson(_object(row)),
      ],
    ),
    (value) => (value! as WeatherEnvelope<List<HourlyWeather>>).toJson(
      (rows) => [for (final row in rows) row.toJson()],
    ),
  ),
  GiEndpoints.weatherDaily.id: ClientDecoder(
    (json) => WeatherEnvelope.fromJson(
      _object(json),
      (data) => [
        for (final row in data! as List) DailyWeather.fromJson(_object(row)),
      ],
    ),
    (value) => (value! as WeatherEnvelope<List<DailyWeather>>).toJson(
      (rows) => [for (final row in rows) row.toJson()],
    ),
  ),
  GiEndpoints.solarCurrent.id: ClientDecoder(
    (json) => SolarStatus.fromJson(_object(json)),
    (value) => (value! as SolarStatus).toJson(),
  ),
  GiEndpoints.pvForecast.id: ClientDecoder(
    (json) => PvForecast.fromJson(_object(json)),
    (value) => (value! as PvForecast).toJson(),
  ),
  GiEndpoints.pvHeatingPlan.id: ClientDecoder(
    (json) => PvHeatingPlan.fromJson(_object(json)),
    (value) => (value! as PvHeatingPlan).toJson(),
  ),
  GiEndpoints.entityHistory.id: ClientDecoder(
    (json) => EntityHistory.fromJson(_object(json)),
    (value) => (value! as EntityHistory).toJson(),
  ),
  GiEndpoints.authSessionsList.id: ClientDecoder(
    (json) => [
      for (final row in json! as List) AuthSessionInfo.fromJson(_object(row)),
    ],
    (value) => [
      for (final row in value! as List<AuthSessionInfo>) row.toJson(),
    ],
  ),
  GiEndpoints.authRecoveryRegenerate.id: ClientDecoder(
    (json) => RecoveryCodeResult.fromJson(_object(json)),
    (value) => (value! as RecoveryCodeResult).toJson(),
  ),
  GiEndpoints.usersMeProfileUpdate.id: ClientDecoder(
    (json) => UserProfile.fromJson(_object(json)),
    (value) => (value! as UserProfile).toJson(),
  ),
};

final _schedule = ClientDecoder(
  (json) => HeatingSchedule.fromJson(_object(json)),
  (value) => (value! as HeatingSchedule).toJson(),
);

/// Catalog entries whose response body the client ignores (204 or unread).
final Set<String> bodylessEndpointIds = {
  GiEndpoints.authLogout.id,
  GiEndpoints.scheduleRemove.id,
  GiEndpoints.authSessionRevoke.id,
  GiEndpoints.authLogoutAll.id,
  GiEndpoints.authRecoveryReset.id,
};

/// Probes [decoder] with recorded [samples]: every field present in a sample
/// the decoder accepts is "decoded" (unless the model drops it as unknown),
/// and a field is "required" when removing it, everywhere in the sample,
/// makes the decoder throw. Samples the decoder rejects as they are (error
/// envelopes) are skipped.
ClientShape probeClientShape(ClientDecoder decoder, Iterable<Object?> samples) {
  final decoded = <String>{};
  final required = <String>{};
  for (final sample in samples) {
    final Object? value;
    try {
      value = decoder.decode(sample);
    } on Object {
      continue;
    }
    final unknown = {
      for (final path in unknownJsonFields(sample, decoder.encode(value)))
        path.replaceAll(RegExp(r'\[\d+\]'), '[]'),
    };
    final paths = jsonFieldPaths(sample);
    for (final path in paths) {
      if (path == r'$') continue;
      if (unknown.any((u) => path == u || path.startsWith('$u.'))) continue;
      decoded.add(path);
      if (path.endsWith('[]') || required.contains(path)) continue;
      try {
        decoder.decode(removeJsonField(sample, path));
      } on Object {
        required.add(path);
      }
    }
  }
  return ClientShape(requiredFields: required, decodedFields: decoded);
}

/// Every field path of [json] (`$`, `$.a`, `$.a[]`, `$.a[].b`).
Set<String> jsonFieldPaths(Object? json) {
  final paths = <String>{};
  void walk(Object? node, String path) {
    paths.add(path);
    switch (node) {
      case final Map<dynamic, dynamic> map:
        for (final MapEntry(:key, :value) in map.entries) {
          walk(value, '$path.$key');
        }
      case final List<dynamic> list:
        for (final item in list) {
          walk(item, '$path[]');
        }
    }
  }

  walk(json, r'$');
  return paths;
}

/// A copy of [json] without the object key at [path] (in every element of
/// the arrays on the way).
Object? removeJsonField(Object? json, String path) {
  final segments = RegExp(r'\.([^.\[]+)|\[\]')
      .allMatches(path.substring(1))
      .map((m) => m[1] ?? '[]')
      .toList();

  Object? remove(Object? node, int index) {
    if (index >= segments.length) return node;
    final segment = segments[index];
    final last = index == segments.length - 1;
    if (segment == '[]') {
      if (node is! List) return node;
      return [for (final item in node) remove(item, index + 1)];
    }
    if (node is! Map) return node;
    return <String, dynamic>{
      for (final MapEntry(:key, :value) in node.entries)
        if (!(last && key == segment))
          '$key': key == segment ? remove(value, index + 1) : value,
    };
  }

  return remove(json, 0);
}

/// Shapes of every endpoint in [clientDecoders], probed with the recorded
/// fixtures `<fixturesDir>/<endpointId>/*.json`.
Map<String, ClientShape> clientShapesFromFixtures(Directory fixturesDir) => {
  for (final MapEntry(key: id, value: decoder) in clientDecoders.entries)
    id: probeClientShape(
      decoder,
      _samples(Directory('${fixturesDir.path}/$id')),
    ),
};

Iterable<Object?> _samples(Directory dir) sync* {
  if (!dir.existsSync()) return;
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    yield jsonDecode(file.readAsStringSync());
  }
}
