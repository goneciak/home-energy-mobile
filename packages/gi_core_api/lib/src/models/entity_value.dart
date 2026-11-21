import 'package:freezed_annotation/freezed_annotation.dart';

part 'entity_value.freezed.dart';

/// Closed representation of a device entity's JSON `value` (plan §6.4).
///
/// The backend stores the value as free-form JSON, so every JSON type is
/// accepted; nothing about it can fail decoding.
@freezed
sealed class EntityValue with _$EntityValue {
  const factory none() = EntityValueNone;
  // A one-field union case: the value is the case, not a flag.
  const factory boolean(bool value) = EntityValueBoolean;
  const factory number(num value) = EntityValueNumber;
  const factory text(String value) = EntityValueText;

  /// A JSON object or array, kept as decoded.
  const factory structured(Object value) = EntityValueStructured;

  const new _();

  factory parse(Object? raw) => switch (raw) {
    null => const EntityValue.none(),
    final bool value => EntityValue.boolean(value),
    final num value => EntityValue.number(value),
    final String value => EntityValue.text(value),
    final Object value => EntityValue.structured(value),
  };

  /// The raw JSON value.
  Object? get raw => switch (this) {
    EntityValueNone() => null,
    EntityValueBoolean(:final value) => value,
    EntityValueNumber(:final value) => value,
    EntityValueText(:final value) => value,
    EntityValueStructured(:final value) => value,
  };
}

class EntityValueConverter implements JsonConverter<EntityValue, Object?> {
  const new();

  @override
  EntityValue fromJson(Object? json) => EntityValue.parse(json);

  @override
  Object? toJson(EntityValue value) => value.raw;
}
