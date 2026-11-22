import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/core_capabilities.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/settings/data/language_preference_store.dart';
import 'package:gi_home/src/features/settings/domain/session_expiry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
LanguagePreferenceStore languagePreferenceStore(Ref ref) =>
    LanguagePreferenceStore(ref.watch(sharedPreferencesProvider));

/// The language picked in Settings, or `null` for "Automatycznie" (the
/// profile language, else the phone one; plan §13.2). It wins over both.
@Riverpod(keepAlive: true)
class LanguagePreference extends _$LanguagePreference {
  @override
  Locale? build() {
    final code = ref.watch(languagePreferenceStoreProvider).read();
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == code) return Locale(locale.languageCode);
    }
    return null;
  }

  /// Applies [locale] at once and remembers it; `null` is "Automatycznie".
  Future<void> select(Locale? locale) async {
    state = locale == null ? null : Locale(locale.languageCode);
    await ref.read(languagePreferenceStoreProvider).write(locale?.languageCode);
  }
}

/// Best-effort running GI Core version from `GET /appliance/updates/status`
/// (plan §16), for OWNER/ADMIN only, so other roles never cause a 403.
/// `null` when unknown: another role, no check yet, or any failure. Nothing
/// is gated on it, but a change of version re-runs the capability probes
/// ([coreCapabilitiesProvider]). Read each time Settings opens.
@riverpod
Future<String?> applianceRunningVersion(Ref ref) async {
  final role = ref.watch(currentUserProvider.select((user) => user?.role));
  final client = ref.watch(giCoreClientProvider);
  if (role == null ||
      client == null ||
      !GiEndpoints.applianceUpdatesStatus.allows(role)) {
    return null;
  }
  try {
    final status = await client.applianceUpdateStatus();
    final version = status.runningVersion();
    if (ref.mounted) {
      ref.read(coreVersionChangesProvider.notifier).note(version);
    }
    return version;
  } on Object {
    return null;
  }
}

/// `GET /settings/system` (device name, time zone) for OWNER/ADMIN/SERVICE,
/// or `null` for other roles and on any failure: Settings then just leave
/// those rows out.
@riverpod
Future<SystemSettings?> systemSettings(Ref ref) async {
  final role = ref.watch(currentUserProvider.select((user) => user?.role));
  final client = ref.watch(giCoreClientProvider);
  if (role == null ||
      client == null ||
      !GiEndpoints.settingsSystem.allows(role)) {
    return null;
  }
  try {
    return await client.systemSettings();
  } on Object {
    return null;
  }
}

/// How the session's end is shown in Settings (plan §7.6), from the stored
/// refresh cookie's expiry; `null` while signed out or when unknown.
@riverpod
SessionExpiry? sessionExpiry(Ref ref) {
  final expiresAt = ref.watch(sessionExpiresAtProvider);
  if (expiresAt == null) return null;
  return SessionExpiry.of(expiresAt, now: ref.watch(clockProvider)());
}
