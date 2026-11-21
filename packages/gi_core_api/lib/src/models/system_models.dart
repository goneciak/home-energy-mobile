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
