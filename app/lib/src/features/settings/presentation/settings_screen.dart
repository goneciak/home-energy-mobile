import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/section_header.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/presentation/change_appliance_dialog.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/application/switch_user_controller.dart';
import 'package:gi_home/src/features/diagnostics/presentation/diagnostic_report_tile.dart';
import 'package:gi_home/src/features/experimental/presentation/experimental_features_screen.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:gi_home/src/features/settings/presentation/language_tile.dart';
import 'package:gi_home/src/features/settings/presentation/switch_user_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Ustawienia" (plan §20 M2 item 6): appliance (name, address, the HTTP
/// indicator, best-effort software version and time zone for the roles
/// allowed to read them), account (role, session expiry, logout, switch
/// user), change appliance, language, app version, open-source licences,
/// diagnostic report.
class SettingsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final profile = ref.watch(applianceProfileProvider);
    final user = ref.watch(currentUserProvider);
    final appInfo = ref.watch(appInfoProvider);
    final sessionExpiry = ref.watch(sessionExpiryProvider);
    final coreVersion = ref.watch(applianceRunningVersionProvider).value;
    final system = ref.watch(systemSettingsProvider).value;

    Future<void> logout() async {
      final result = await ref.read(authSessionProvider.notifier).logout();
      if (!result.serverSessionEnded && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsLogoutLocalOnly)));
      }
    }

    Future<void> switchUser(String email) async {
      final confirmed = await confirmSwitchUser(context, email: email);
      if (!confirmed || !context.mounted) return;
      // The login screen replaces this one; the message is shown there.
      final messenger = ScaffoldMessenger.of(context);
      final result = await ref
          .read(switchUserControllerProvider.notifier)
          .switchUser();
      if (!result.serverSessionEnded) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsLogoutLocalOnly)),
        );
      }
    }

    Future<void> changeAppliance() async {
      final confirmed = await confirmChangeAppliance(
        context,
        applianceLabel: profile?.label ?? '',
        canLogOut: user != null,
      );
      if (confirmed && context.mounted) {
        await ref.read(authSessionProvider.notifier).forgetAppliance();
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: tokens.gap / 2),
        children: [
          if (profile != null) ...[
            SectionHeader(l10n.settingsApplianceSection),
            ListTile(
              leading: const Icon(Icons.local_fire_department_outlined),
              title: Text(l10n.settingsApplianceName),
              subtitle: Text(profile.label),
            ),
            ListTile(
              leading: const Icon(Icons.router_outlined),
              title: Text(l10n.settingsApplianceAddress),
              subtitle: Text(
                profile.address.authority,
                style: GiFonts.monospace(),
              ),
            ),
            ListTile(
              leading: Icon(
                profile.address.isCleartext
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                color: profile.address.isCleartext
                    ? tokens.warning
                    : tokens.teal,
              ),
              title: Text(
                profile.address.isCleartext
                    ? l10n.settingsCleartext
                    : l10n.settingsEncrypted,
              ),
              subtitle: Text(l10n.settingsLanOnly),
            ),
            if (coreVersion != null)
              ListTile(
                key: const ValueKey('settings-core-version'),
                leading: const Icon(Icons.memory_outlined),
                title: Text(l10n.settingsCoreVersion),
                subtitle: Text(l10n.settingsCoreVersionSubtitle(coreVersion)),
              ),
            if (system != null)
              ListTile(
                key: const ValueKey('settings-timezone'),
                leading: const Icon(Icons.public),
                title: Text(l10n.settingsTimezone),
                subtitle: Text(system.timezone),
              ),
          ],
          if (user != null) ...[
            SectionHeader(l10n.settingsAccountSection),
            // The way to "Profil i bezpieczeństwo" (plan §20 M3.5).
            ListTile(
              key: const ValueKey('settings-account'),
              leading: const Icon(Icons.manage_accounts_outlined),
              title: Text(l10n.settingsAccountManage),
              subtitle: Text([user.firstName, ?user.lastName].join(' ')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(AppRoutes.account)),
            ),
            ListTile(
              leading: const Icon(Icons.alternate_email),
              title: Text(l10n.settingsUserEmail),
              subtitle: Text(user.email),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(l10n.settingsUserRole),
              subtitle: Text(roleLabel(l10n, user.role)),
            ),
            if (sessionExpiry != null)
              ListTile(
                key: const ValueKey('settings-session-expiry'),
                leading: Icon(
                  Icons.schedule,
                  color: sessionExpiry.isWarning ? tokens.warning : null,
                ),
                title: Text(
                  l10n.settingsSessionValidUntil(
                    sessionExpiry.expiresAt.toLocal(),
                  ),
                ),
                subtitle: sessionExpiry.daysLeft == null
                    ? null
                    : Text(
                        l10n.settingsSessionRenewSoon(sessionExpiry.daysLeft!),
                      ),
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.settingsLogout),
              onTap: logout,
            ),
            ListTile(
              key: const ValueKey('settings-switch-user'),
              leading: const Icon(Icons.switch_account_outlined),
              title: Text(l10n.settingsSwitchUser),
              subtitle: Text(l10n.settingsSwitchUserSubtitle),
              onTap: () => switchUser(user.email),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text(l10n.settingsChangeAppliance),
            onTap: changeAppliance,
          ),
          SectionHeader(l10n.settingsAppSection),
          const LanguageTile(),
          const _AppVersionTile(),
          ListTile(
            key: const ValueKey('settings-licenses'),
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsLicenses),
            subtitle: Text(l10n.settingsLicensesSubtitle),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: l10n.settingsAppVersionValue(
                appInfo.version,
                appInfo.buildNumber,
              ),
            ),
          ),
          const DiagnosticReportTile(),
        ],
      ),
    );
  }
}

/// The app version. In dev and beta, tapping it
/// [ExperimentalFeaturesScreen.versionTapsToOpen] times opens the hidden
/// experimental features screen; in prod it is not tappable.
class _AppVersionTile extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_AppVersionTile> createState() => _AppVersionTileState();
}

class _AppVersionTileState extends ConsumerState<_AppVersionTile> {
  var _taps = 0;

  void _onTap() {
    if (++_taps < ExperimentalFeaturesScreen.versionTapsToOpen) return;
    _taps = 0;
    unawaited(context.push(AppRoutes.experimental));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appInfo = ref.watch(appInfoProvider);
    final opensExperimental = ref.watch(appFlavorProvider).allowsFlagOverrides;
    return ListTile(
      key: const ValueKey('settings-app-version'),
      leading: const Icon(Icons.info_outline),
      title: Text(l10n.settingsAppVersion),
      subtitle: Text(
        l10n.settingsAppVersionValue(appInfo.version, appInfo.buildNumber),
        style: GiFonts.monospace(),
      ),
      onTap: opensExperimental ? _onTap : null,
    );
  }
}

/// Human-readable role name.
String roleLabel(AppLocalizations l10n, UserRole role) => switch (role) {
  UserRole.owner => l10n.roleOwner,
  UserRole.admin => l10n.roleAdmin,
  UserRole.user => l10n.roleUser,
  UserRole.service => l10n.roleService,
  UserRole.unknown => l10n.roleUnknown,
};
