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
