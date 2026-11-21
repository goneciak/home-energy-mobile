import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_models.freezed.dart';
part 'system_models.g.dart';

/// `GET /health/live`.
@freezed
abstract class HealthLive with _$HealthLive {
  const factory({required String status}) = _HealthLive;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$HealthLiveFromJson(json);

  bool get isLive => status == 'ok';
}

/// `GET /setup/status` (public). `initializedAt` + `deviceName` form the
/// appliance fingerprint (plan §9.3).
@freezed
abstract class SetupStatus with _$SetupStatus {
  const factory({
    required bool initialized,
    DateTime? initializedAt,
    String? deviceName,
    String? locale,
    String? timezone,
  }) = _SetupStatus;

  factory fromJson(Map<String, dynamic> json) => _$SetupStatusFromJson(json);
}

/// `{items, page, limit, total, totalPages}` wrapper used by paginated lists.
@Freezed(genericArgumentFactories: true)
abstract class ListPage<T> with _$ListPage<T> {
  const factory({
    required List<T> items,
    required int page,
    required int limit,
    required int total,
    required int totalPages,
  }) = _ListPage<T>;

  const new _();

  factory fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ListPageFromJson(json, fromJsonT);

  /// Whether the server holds more items than this page returned.
  bool get isTruncated => page < totalPages;
}

/// `GET /settings/system` (`SystemSettingsDto`).
@freezed
abstract class SystemSettings with _$SystemSettings {
  const factory({
    required String locale,
    required String timezone,
    String? deviceName,
  }) = _SystemSettings;

  factory fromJson(Map<String, dynamic> json) => _$SystemSettingsFromJson(json);
}

/// `GET /appliance/updates/status` (`ApplianceUpdateStatus` in
/// `appliance-update.service.ts`). Everything but [configured] is `null`
/// until the first check or install.
@freezed
abstract class ApplianceUpdateStatus with _$ApplianceUpdateStatus {
  const factory({
    required bool configured,
    UpdateCheckResult? lastCheck,
    UpdateInstallResult? lastInstall,
    String? lastError,
  }) = _ApplianceUpdateStatus;

  const new _();

  factory fromJson(Map<String, dynamic> json) =>
      _$ApplianceUpdateStatusFromJson(json);

  /// Best-effort running version of [service] from the last check (plan
  /// §16); `null` when unknown. It may be stale: it is only as fresh as
  /// [UpdateCheckResult.checkedAt].
  String? runningVersion([String service = 'gi-core']) {
    for (final status in lastCheck?.services ?? const <ServiceUpdateStatus>[]) {
      if (status.service == service) return status.runningVersion;
    }
    return null;
  }
}

/// One update check by the Supervisor.
@freezed
abstract class UpdateCheckResult with _$UpdateCheckResult {
  const factory({
    required DateTime checkedAt,
    required String channel,
    required bool updateAvailable,
    @Default(<ServiceUpdateStatus>[]) List<ServiceUpdateStatus> services,
  }) = _UpdateCheckResult;

  factory fromJson(Map<String, dynamic> json) =>
      _$UpdateCheckResultFromJson(json);
}

/// Update state of one appliance service.
@freezed
abstract class ServiceUpdateStatus with _$ServiceUpdateStatus {
  const factory({
    required String service,
    required String channel,
    required bool updateAvailable,
    String? runningImageId,
    String? availableImageId,
    String? runningVersion,
    String? availableVersion,
  }) = _ServiceUpdateStatus;

  factory fromJson(Map<String, dynamic> json) =>
      _$ServiceUpdateStatusFromJson(json);
}

/// The last install run by the Supervisor.
@freezed
abstract class UpdateInstallResult with _$UpdateInstallResult {
  const factory({
    required DateTime startedAt,
    required DateTime finishedAt,
    required String channel,
    @Default(<String>[]) List<String> services,
  }) = _UpdateInstallResult;

  factory fromJson(Map<String, dynamic> json) =>
      _$UpdateInstallResultFromJson(json);
}
