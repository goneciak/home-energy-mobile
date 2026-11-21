import 'package:gi_core_api/src/failures/api_failure.dart';

/// Server error codes the device-control screens handle (plan §8.2,
/// M2). They pass through [ApiFailure.code] unchanged; the status in each
/// comment decides the [ApiFailure] variant.
abstract final class GiErrorCodes {
  /// 404: the entity is not (or no longer) part of this device.
  static const deviceEntityNotFound = 'DEVICE_ENTITY_NOT_FOUND';

  /// 404: the device does not exist.
  static const deviceNotFound = 'DEVICE_NOT_FOUND';

  /// 409: switching ON while heating is suspended (every switch of the
  /// device; switching OFF is always allowed).
  static const heatingSuspended = 'HEATING_SUSPENDED';

  /// 409: the entity is disabled.
  static const entityDisabled = 'ENTITY_DISABLED';

  /// 422: the entity is not a writable switch.
  static const entityNotWritable = 'ENTITY_NOT_WRITABLE';

  /// 503: the device's stored status is not ONLINE or the entity is
  /// unavailable. Nothing was sent.
  static const deviceOffline = 'DEVICE_OFFLINE';

  /// 503: a legacy ESPHome device without a known address. Nothing was sent.
  static const espHomeDeviceUnreachable = 'ESPHOME_DEVICE_UNREACHABLE';

  /// 502: the ESPHome device answered with a non-2xx status. Missing from
  /// the original plan §8.2; handled like [espHomeCommandUnconfirmed].
  static const espHomeCommandRejected = 'ESPHOME_COMMAND_REJECTED';

  /// 502: the device's echo was malformed or did not match the request.
  static const espHomeCommandUnconfirmed = 'ESPHOME_COMMAND_UNCONFIRMED';

  /// 504: transport error or abort while talking to the device; the
  /// command may or may not have been executed.
  static const espHomeCommandTimeout = 'ESPHOME_COMMAND_TIMEOUT';

  /// 400: the device host resolves to a non-private address.
  static const espHomeHostForbidden = 'ESPHOME_HOST_FORBIDDEN';

  /// 400: the request body failed validation.
  static const validationFailed = 'VALIDATION_FAILED';

  /// 403: the user's role may not call the endpoint.
  static const forbidden = 'HTTP_403';
}

/// Device-command classification of an [ApiFailure].
extension DeviceCommandFailure on ApiFailure {
  /// The command reached the device path but its result is unknown: the
  /// device rejected it, its echo did not match, or it timed out (502
  /// `ESPHOME_COMMAND_REJECTED`/`_UNCONFIRMED`, 504 `_TIMEOUT`), or no answer
  /// arrived at all ([TimeoutFailure]). The switch state must be re-read
  /// before anything is retried.
  bool get isCommandOutcomeUnknown => switch (this) {
    TimeoutFailure() => true,
    ServerFailure(
      errorCode: GiErrorCodes.espHomeCommandRejected ||
          GiErrorCodes.espHomeCommandUnconfirmed ||
          GiErrorCodes.espHomeCommandTimeout,
    ) =>
      true,
    _ => false,
  };
}
