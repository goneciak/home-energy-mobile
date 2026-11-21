import 'package:meta/meta.dart';

/// A value as last received from GI Core, with the time it arrived.
///
/// Repositories keep the last good [Fetched] value so screens can keep
/// showing it (with its age) when a later request fails (plan §8.3).
@immutable
final class Fetched<T> {
  const new(this.value, this.fetchedAt);

  final T value;

  /// When the response carrying [value] was received (phone clock).
  final DateTime fetchedAt;

  @override
  bool operator ==(Object other) =>
      other is Fetched<T> &&
      other.value == value &&
      other.fetchedAt == fetchedAt;

  @override
  int get hashCode => Object.hash(value, fetchedAt);

  @override
  String toString() => 'Fetched($value, at: $fetchedAt)';
}
