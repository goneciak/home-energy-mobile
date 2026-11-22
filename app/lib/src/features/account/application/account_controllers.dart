import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controllers.g.dart';

GiCoreClient _clientOf(Ref ref) {
  final client = ref.read(giCoreClientProvider);
  if (client == null) throw StateError('No appliance profile');
  return client;
}

/// `GET /auth/sessions`: the user's live sessions, this phone's first,
/// then newest first (plan §4.2, §20 M3.5).
@riverpod
Future<List<AuthSessionInfo>> authSessions(Ref ref) async {
  // Another user, or none, drops the list.
  ref.watch(currentUserProvider.select((user) => user?.id));
  final client = ref.watch(giCoreClientProvider);
  if (client == null) return const [];
  final sessions = await client.authSessions();
  return [
    ...sessions.where((s) => s.current),
    ...sessions.where((s) => !s.current),
  ];
}

/// Saving the profile (`PATCH /users/me/profile`): names and the account
/// language (plan §13.2). On success the profile is fetched again, so the
/// app language follows the server.
@riverpod
class ProfileEditController extends _$ProfileEditController {
  @override
  AsyncValue<UserProfile?> build() => const AsyncData(null);

  /// Returns whether the update was saved.
  Future<bool> save(ProfileUpdate update) async {
    if (update.isEmpty) return true;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => _clientOf(ref).updateProfile(update),
    );
    if (!ref.mounted) return !result.hasError;
    state = result;
    if (!result.hasError) ref.invalidate(userProfileProvider);
    return !result.hasError;
  }
}

/// Ending sessions from the session list: one of them, or all of them
/// (`POST /auth/logout-all`). Ending this phone's session signs out here.
@riverpod
class SessionActionsController extends _$SessionActionsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns whether [session] was revoked.
  Future<bool> revoke(AuthSessionInfo session) => _run(
    () => ref.read(authSessionProvider.notifier).revokeSession(session),
    refresh: !session.current,
  );

  /// Returns whether every session was ended.
  Future<bool> logoutAll() => _run(
    () => ref.read(authSessionProvider.notifier).logoutAll(),
    refresh: false,
  );

  Future<bool> _run(
    Future<void> Function() action, {
    required bool refresh,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (!ref.mounted) return !result.hasError;
    state = result;
    if (refresh && !result.hasError) ref.invalidate(authSessionsProvider);
    return !result.hasError;
  }
}

/// A new recovery code (`POST /auth/recovery/regenerate`). The code lives
/// only in this state, for as long as the screen showing it: it is never
/// stored, logged or sent anywhere else.
@riverpod
class RecoveryCodeController extends _$RecoveryCodeController {
  @override
  AsyncValue<RecoveryCodeResult?> build() => const AsyncData(null);

  Future<void> regenerate() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => _clientOf(ref).regenerateRecoveryCode(),
    );
    if (!ref.mounted) return;
    state = result;
    if (!result.hasError) {
      ref.read(accountPromptsProvider.notifier).recoveryCodeRotated();
    }
  }

  /// Forgets the code once the user saved it.
  void dismiss() => state = const AsyncData(null);
}

/// `POST /auth/recovery/reset` from the login screen (public). On success
/// every session of the user is gone and the code is still valid, so a
/// new one is offered after the next login ([AccountPrompts]).
@riverpod
class RecoveryResetController extends _$RecoveryResetController {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> submit(RecoveryResetRequest request) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => _clientOf(ref).resetPasswordWithRecoveryCode(request),
    );
    if (!ref.mounted) return;
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return;
    }
    ref.read(accountPromptsProvider.notifier).recoveryCodeUsed();
    state = const AsyncData(true);
  }
}

/// What to offer the user right after a login (plan §20 M3.5).
final class PendingAccountPrompts {
  const new({this.reviewSessions = false, this.rotateRecoveryCode = false});

  /// Offer ending older sessions, if there are any.
  final bool reviewSessions;

  /// The password was reset with the recovery code, which stays valid:
  /// offer a new one.
  final bool rotateRecoveryCode;

  bool get isEmpty => !reviewSessions && !rotateRecoveryCode;
}

/// Prompts waiting for the signed-in shell, in memory only.
@Riverpod(keepAlive: true)
class AccountPrompts extends _$AccountPrompts {
  @override
  PendingAccountPrompts build() => const PendingAccountPrompts();

  void loggedIn() => state = PendingAccountPrompts(
    reviewSessions: true,
    rotateRecoveryCode: state.rotateRecoveryCode,
  );

  void recoveryCodeUsed() => state = PendingAccountPrompts(
    reviewSessions: state.reviewSessions,
    rotateRecoveryCode: true,
  );

  void recoveryCodeRotated() =>
      state = PendingAccountPrompts(reviewSessions: state.reviewSessions);

  /// Takes the pending prompts, leaving none.
  PendingAccountPrompts take() {
    final pending = state;
    state = const PendingAccountPrompts();
    return pending;
  }
}
