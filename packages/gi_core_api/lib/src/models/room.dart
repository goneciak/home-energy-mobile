import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

/// Element of `GET /rooms` (a plain JSON array, not a page).
@freezed
abstract class Room with _$Room {
  const factory({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    @Default(0) int sortOrder,
  }) = _Room;

  factory fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}
