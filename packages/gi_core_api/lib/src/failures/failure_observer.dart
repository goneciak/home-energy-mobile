import 'package:gi_core_api/src/failures/api_failure.dart';

/// Called once with every [ApiFailure] a public client call is about to
/// throw (after automatic retries), so the app can count failures for its
/// local diagnostics (plan §8.4) without wrapping each call.
///
/// It must not throw; an exception from it is ignored.
typedef ApiFailureObserver = void Function(ApiFailure failure);

/// Runs [action] and reports an [ApiFailure] it throws to [observer] before
/// rethrowing it unchanged.
Future<T> observeFailures<T>(
  ApiFailureObserver? observer,
  Future<T> Function() action,
) async {
  if (observer == null) return await action();
  try {
    return await action();
  } on ApiFailure catch (failure) {
    try {
      observer(failure);
    } on Object {
      // Diagnostics must never change what the caller sees.
    }
    rethrow;
  }
}
