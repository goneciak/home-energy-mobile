// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthLive _$HealthLiveFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_HealthLive', json, ($checkedConvert) {
      final val = _HealthLive(
        status: $checkedConvert('status', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$HealthLiveToJson(_HealthLive instance) =>
    <String, dynamic>{'status': instance.status};

_SetupStatus _$SetupStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SetupStatus', json, ($checkedConvert) {
      final val = _SetupStatus(
        initialized: $checkedConvert('initialized', (v) => v as bool),
        initializedAt: $checkedConvert(
          'initializedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        deviceName: $checkedConvert('deviceName', (v) => v as String?),
        locale: $checkedConvert('locale', (v) => v as String?),
        timezone: $checkedConvert('timezone', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SetupStatusToJson(_SetupStatus instance) =>
    <String, dynamic>{
      'initialized': instance.initialized,
      'initializedAt': instance.initializedAt?.toIso8601String(),
      'deviceName': instance.deviceName,
      'locale': instance.locale,
      'timezone': instance.timezone,
    };

_ListPage<T> _$ListPageFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate('_ListPage', json, ($checkedConvert) {
  final val = _ListPage<T>(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>).map(fromJsonT).toList(),
    ),
    page: $checkedConvert('page', (v) => (v as num).toInt()),
    limit: $checkedConvert('limit', (v) => (v as num).toInt()),
    total: $checkedConvert('total', (v) => (v as num).toInt()),
    totalPages: $checkedConvert('totalPages', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$ListPageToJson<T>(
  _ListPage<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items.map(toJsonT).toList(),
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
  'totalPages': instance.totalPages,
};

_SystemSettings _$SystemSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SystemSettings', json, ($checkedConvert) {
      final val = _SystemSettings(
        locale: $checkedConvert('locale', (v) => v as String),
        timezone: $checkedConvert('timezone', (v) => v as String),
        deviceName: $checkedConvert('deviceName', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SystemSettingsToJson(_SystemSettings instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'timezone': instance.timezone,
      'deviceName': instance.deviceName,
    };

_ApplianceUpdateStatus _$ApplianceUpdateStatusFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ApplianceUpdateStatus', json, ($checkedConvert) {
  final val = _ApplianceUpdateStatus(
    configured: $checkedConvert('configured', (v) => v as bool),
    lastCheck: $checkedConvert(
      'lastCheck',
      (v) => v == null
          ? null
          : UpdateCheckResult.fromJson(v as Map<String, dynamic>),
    ),
    lastInstall: $checkedConvert(
      'lastInstall',
      (v) => v == null
          ? null
          : UpdateInstallResult.fromJson(v as Map<String, dynamic>),
    ),
    lastError: $checkedConvert('lastError', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ApplianceUpdateStatusToJson(
  _ApplianceUpdateStatus instance,
) => <String, dynamic>{
  'configured': instance.configured,
  'lastCheck': instance.lastCheck?.toJson(),
  'lastInstall': instance.lastInstall?.toJson(),
  'lastError': instance.lastError,
};

_UpdateCheckResult _$UpdateCheckResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_UpdateCheckResult', json, ($checkedConvert) {
      final val = _UpdateCheckResult(
        checkedAt: $checkedConvert(
          'checkedAt',
          (v) => DateTime.parse(v as String),
        ),
        channel: $checkedConvert('channel', (v) => v as String),
        updateAvailable: $checkedConvert('updateAvailable', (v) => v as bool),
        services: $checkedConvert(
          'services',
          (v) =>
              (v as List<dynamic>?)
                  ?.map(
                    (e) =>
                        ServiceUpdateStatus.fromJson(e as Map<String, dynamic>),
                  )
                  .toList() ??
              const <ServiceUpdateStatus>[],
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdateCheckResultToJson(_UpdateCheckResult instance) =>
    <String, dynamic>{
      'checkedAt': instance.checkedAt.toIso8601String(),
      'channel': instance.channel,
      'updateAvailable': instance.updateAvailable,
      'services': instance.services.map((e) => e.toJson()).toList(),
    };

_ServiceUpdateStatus _$ServiceUpdateStatusFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ServiceUpdateStatus', json, ($checkedConvert) {
  final val = _ServiceUpdateStatus(
    service: $checkedConvert('service', (v) => v as String),
    channel: $checkedConvert('channel', (v) => v as String),
    updateAvailable: $checkedConvert('updateAvailable', (v) => v as bool),
    runningImageId: $checkedConvert('runningImageId', (v) => v as String?),
    availableImageId: $checkedConvert('availableImageId', (v) => v as String?),
    runningVersion: $checkedConvert('runningVersion', (v) => v as String?),
    availableVersion: $checkedConvert('availableVersion', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ServiceUpdateStatusToJson(
  _ServiceUpdateStatus instance,
) => <String, dynamic>{
  'service': instance.service,
  'channel': instance.channel,
  'updateAvailable': instance.updateAvailable,
  'runningImageId': instance.runningImageId,
  'availableImageId': instance.availableImageId,
  'runningVersion': instance.runningVersion,
  'availableVersion': instance.availableVersion,
};

_UpdateInstallResult _$UpdateInstallResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_UpdateInstallResult', json, ($checkedConvert) {
      final val = _UpdateInstallResult(
        startedAt: $checkedConvert(
          'startedAt',
          (v) => DateTime.parse(v as String),
        ),
        finishedAt: $checkedConvert(
          'finishedAt',
          (v) => DateTime.parse(v as String),
        ),
        channel: $checkedConvert('channel', (v) => v as String),
        services: $checkedConvert(
          'services',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdateInstallResultToJson(
  _UpdateInstallResult instance,
) => <String, dynamic>{
  'startedAt': instance.startedAt.toIso8601String(),
  'finishedAt': instance.finishedAt.toIso8601String(),
  'channel': instance.channel,
  'services': instance.services,
};
