import 'package:gi_core_api/gi_core_api.dart';

/// The device write endpoints the command controllers depend on. Every
/// method throws only [ApiFailure] and is never retried automatically.
abstract interface class DeviceCommandSource {
  /// `PUT /devices/:id/entities/:entityId/state` with `{"state": state}`.
  Future<SwitchCommandResult> setSwitchState(
    String deviceId,
    String entityId, {
    required bool state,
  });

  /// `PATCH /devices/:id` with only `{"heatingSuspended": suspended}`.
  Future<DeviceListItem> setHeatingSuspended(
    String deviceId, {
    required bool suspended,
  });

  /// `PATCH /devices/:id/control-strategy` with all three fields of
  /// [strategy] (the new BASE strategy).
  Future<ControlStrategyUpdateResult> updateControlStrategy(
    String deviceId,
    ControlStrategy strategy,
  );
}

/// [DeviceCommandSource] backed by the GI Core client.
final class GiCoreDeviceCommandSource implements DeviceCommandSource {
  const new(this._client);

  final GiCoreClient _client;

  @override
  Future<SwitchCommandResult> setSwitchState(
    String deviceId,
    String entityId, {
    required bool state,
  }) => _client.setSwitchState(deviceId, entityId, state: state);

  @override
  Future<DeviceListItem> setHeatingSuspended(
    String deviceId, {
    required bool suspended,
  }) => _client.setHeatingSuspended(deviceId, suspended: suspended);

  @override
  Future<ControlStrategyUpdateResult> updateControlStrategy(
    String deviceId,
    ControlStrategy strategy,
  ) => _client.updateControlStrategy(
    deviceId,
    targetTemperatureCelsius: strategy.targetTemperatureCelsius,
    hysteresisCelsius: strategy.hysteresisCelsius,
    mode: strategy.mode,
  );
}
