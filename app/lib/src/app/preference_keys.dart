import 'package:gi_home/src/core/config/feature_flag_overrides_store.dart';
import 'package:gi_home/src/features/account/data/session_locale_store.dart';
import 'package:gi_home/src/features/appliance/data/appliance_profile_store.dart';
import 'package:gi_home/src/features/auth/data/reinstall_marker.dart';
import 'package:gi_home/src/features/auth/data/vault_read_failures.dart';
import 'package:gi_home/src/features/settings/data/language_preference_store.dart';

/// Every shared-preferences key the app uses: the allow-list of the
/// preferences cache. A key missing here cannot be read or written.
const Set<String> appPreferenceKeys = {
  ...ApplianceProfileStore.keys,
  ...VaultReadFailures.keys,
  ...ReinstallMarker.keys,
  ...FeatureFlagOverridesStore.keys,
  ...SessionLocaleStore.keys,
  ...LanguagePreferenceStore.keys,
};
