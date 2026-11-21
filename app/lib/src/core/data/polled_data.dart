import 'package:gi_home/src/core/data/fetched.dart';
import 'package:meta/meta.dart';

/// State of data that is refreshed periodically: the last good value, the
/// error of the latest attempt and whether an attempt is in flight.
///
/// A failed refresh never discards [data]; screens show it together with a
/// banner instead of an empty or error-only screen (plan §8.3).
@immutable
final class PolledData<T> {
  const new({this.data, this.error, this.isRefreshing = false});

  /// Last good value, if any was ever received.
  final Fetched<T>? data;

  /// Error of the latest attempt; `null` once an attempt succeeds.
  final Object? error;

  final bool isRefreshing;

  bool get hasData => data != null;

  /// Nothing to show yet because the first attempt is still running.
  bool get isFirstLoad => data == null && error == null;

  PolledData<T> refreshing() =>
      PolledData(data: data, error: error, isRefreshing: true);

  PolledData<T> succeeded(Fetched<T> data) => PolledData(data: data);

  PolledData<T> failed(Object error) => PolledData(data: data, error: error);

  @override
  bool operator ==(Object other) =>
      other is PolledData<T> &&
      other.data == data &&
      other.error == error &&
      other.isRefreshing == isRefreshing;

  @override
  int get hashCode => Object.hash(data, error, isRefreshing);

  @override
  String toString() =>
      'PolledData(data: $data, error: $error, refreshing: $isRefreshing)';
}
