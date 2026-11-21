import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/request_language.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/auth/data/counting_token_vault.dart';
import 'package:gi_home/src/features/auth/data/secure_token_vault.dart';
import 'package:gi_home/src/features/auth/data/vault_read_failures.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'core_client_providers.g.dart';

/// Probes addresses typed on the connect screen and the candidates of the
/// connection ladder. Kept alive like the session that rebinds with it.
@Riverpod(keepAlive: true)
ApplianceProbe applianceProbe(Ref ref) => ApplianceProbe(
  clientInfo: ref.watch(clientInfoProvider),
  acceptLanguage: ref.watch(requestLanguageProvider).call,
  httpClientAdapter: ref.watch(coreHttpClientAdapterProvider),
  onFailure: ref.watch(diagnosticsServiceProvider).recordFailure,
);

/// Secure storage of the current profile's refresh cookie. Failed reads are
/// counted across restarts; the third in a row wipes the entry (plan §7.1),
/// and each one feeds the local diagnostic counters.
@Riverpod(keepAlive: true)
TokenVault? tokenVault(Ref ref) {
  final profileId = ref.watch(
    applianceProfileProvider.select((p) => p?.profileId),
  );
  if (profileId == null) return null;
  final diagnostics = ref.watch(diagnosticsServiceProvider);
  return CountingTokenVault(
    inner: SecureTokenVault(
      storage: ref.watch(secureStorageProvider),
      profileId: profileId,
    ),
    failures: VaultReadFailures(
      ref.watch(sharedPreferencesProvider),
      profileId: profileId,
    ),
    onUnavailable: diagnostics.recordVaultUnavailable,
  );
}

/// The GI Core client (and its single [AuthSessionManager]) for the saved
/// appliance; `null` without a profile.
///
/// It is rebuilt only when the appliance, its address or its fingerprint
/// change — never while a session is in use, so two session managers never
/// hold the same refresh cookie.
///
/// Its failures and every forced logout feed the local diagnostic counters
/// (plan §8.4); the subscription starts before `restore()` can run, so no
/// session loss is missed. Its redacted request log goes to the diagnostics
/// ring buffer in every build, and to the console in debug builds.
///
/// The fingerprint check (plan §9.3) may report that the appliance was
/// renamed (the profile follows the new name) or reset (see
/// [forgetResetAppliance]).
@Riverpod(keepAlive: true)
GiCoreClient? giCoreClient(Ref ref) {
  final connection = ref.watch(
    applianceProfileProvider.select((p) => p?.connection),
  );
  final vault = ref.watch(tokenVaultProvider);
  if (connection == null || vault == null) return null;

  final foreground = ref.watch(appForegroundProvider);
  final diagnostics = ref.watch(diagnosticsServiceProvider);
  final client = GiCoreClient.create(
    address: ApplianceAddress.parse(connection.baseUrl),
    vault: vault,
    clientInfo: ref.watch(clientInfoProvider),
    acceptLanguage: ref.watch(requestLanguageProvider).call,
    log: httpLogSink(diagnostics, debugConsole: kDebugMode),
    expectedInitializedAt: connection.initializedAt,
    // Read, not watched: a rename must not rebuild the client.
    expectedDeviceName: ref.read(applianceProfileProvider)?.deviceName,
    onApplianceRenamed: (name) {
      if (!ref.mounted) return;
      unawaited(ref.read(applianceProfileProvider.notifier).applyRename(name));
    },
    waitUntilForeground: foreground.untilForeground,
    httpClientAdapter: ref.watch(coreHttpClientAdapterProvider),
    onFailure: (failure) {
      diagnostics.recordFailure(failure);
      // A reset seen mid-session (a refresh before any request); a reset
      // found while restoring is handled by the session notifier as well.
      if (failure is ApplianceResetFailure && ref.mounted) {
        unawaited(forgetResetAppliance(ref));
      }
    },
  );
  final sessionLost = client.session.states.listen((state) {
    if (state case AuthSessionLost(:final reason)) {
      diagnostics.recordSessionLost(reason);
    }
  });
  ref.onDispose(() {
    unawaited(sessionLost.cancel());
    unawaited(client.close());
  });
  return client;
}

/// The [HttpLogSink] of the GI Core client: every redacted line goes to the
/// diagnostics ring buffer, and with [debugConsole] also to the console.
HttpLogSink httpLogSink(
  DiagnosticsService diagnostics, {
  required bool debugConsole,
}) => (line) {
  diagnostics.recordHttp(line);
  if (debugConsole) debugPrint(line);
};

/// The saved appliance reports `initialized: false`: it was reset (plan
/// §9.3). Its session cookie can no longer be valid and must not reach the
/// appliance once it is set up again, so it is wiped, and the profile loses
/// its fingerprint, which routes to the setup-required screen ("Finish
/// setup"). Safe to call more than once.
Future<void> forgetResetAppliance(Ref ref) async {
  final vault = ref.read(tokenVaultProvider);
  final profiles = ref.read(applianceProfileProvider.notifier);
  try {
    await vault?.clear();
  } on Object {
    // A leftover cookie is rejected by the reset appliance on first use.
  }
  await profiles.markReset();
}
