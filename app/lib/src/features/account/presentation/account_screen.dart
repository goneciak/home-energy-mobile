import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/section_header.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/account/domain/app_locale.dart';
import 'package:gi_home/src/features/appliance/application/core_capabilities.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Account languages offered (GI Core `locale` tags, plan §13.2).
const accountLocales = ['pl-PL', 'en-US'];

/// "Profil i bezpieczeństwo" (plan §4.2, §13.2, §20 M3.5): first and last
/// name, the account language (`PATCH /users/me/profile`, which the app
/// then follows), and the way to the password change, the sessions and the
/// recovery code. Every role may use it.
class AccountScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  String? _loadedFor;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  /// Fills the fields once per user, from the profile or the session user.
  void _fill(String userId, String firstName, String? lastName) {
    if (_loadedFor == userId) return;
    _loadedFor = userId;
    _firstName.text = firstName;
    _lastName.text = lastName ?? '';
  }

  Future<void> _saveNames(String firstName, String? lastName) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final first = _firstName.text.trim();
    final last = _lastName.text.trim();
    final update = ProfileUpdate(
      firstName: first == firstName ? null : first,
      // An empty last name clears it on the server.
      lastName: last == (lastName ?? '') ? null : last,
    );
    final saved = await ref
        .read(profileEditControllerProvider.notifier)
        .save(update);
    if (saved && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.accountSaved)));
    }
  }

  Future<void> _saveLocale(String locale) async {
    final saved = await ref
        .read(profileEditControllerProvider.notifier)
        .save(ProfileUpdate(locale: locale));
    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.accountLanguageSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider).value;
    final edit = ref.watch(profileEditControllerProvider);
    final busy = edit.isLoading;
    final error = busy ? null : edit.error;

    final firstName = profile?.firstName ?? user?.firstName ?? '';
    final lastName = profile != null ? profile.lastName : user?.lastName;
    if (user != null) _fill(user.id, firstName, lastName);
    final language = supportedAppLocale(profile?.locale)?.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: tokens.gap / 2),
        children: [
          SectionHeader(l10n.accountProfileSection),
          if (error != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.gap,
                vertical: tokens.gap / 2,
              ),
              child: MessageBanner(
                message: failureMessage(l10n, error),
                detail: failureRequestIdLine(l10n, error),
                monospaceDetail: true,
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.gap),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const ValueKey('account-first-name'),
                    controller: _firstName,
                    enabled: !busy,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    decoration: InputDecoration(
                      labelText: l10n.accountFirstNameLabel,
                    ),
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return l10n.accountFirstNameRequired;
                      if (text.length > ProfileUpdate.nameMaxLength) {
                        return l10n.accountNameTooLong;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: tokens.gap),
                  TextFormField(
                    key: const ValueKey('account-last-name'),
                    controller: _lastName,
                    enabled: !busy,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.familyName],
                    decoration: InputDecoration(
                      labelText: l10n.accountLastNameLabel,
                    ),
                    validator: (value) =>
                        (value ?? '').trim().length >
                            ProfileUpdate.nameMaxLength
                        ? l10n.accountNameTooLong
                        : null,
                    onFieldSubmitted: (_) =>
                        unawaited(_saveNames(firstName, lastName)),
                  ),
                  SizedBox(height: tokens.gap),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FilledButton(
                      key: const ValueKey('account-save'),
                      onPressed: busy
                          ? null
                          : () => unawaited(_saveNames(firstName, lastName)),
                      child: Text(l10n.accountSave),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(l10n.accountLanguageSection),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.gap),
            child: Text(
              l10n.accountLanguageHint,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: tokens.textMuted),
            ),
          ),
          RadioGroup<String>(
            groupValue: switch (language) {
              'pl' => accountLocales[0],
              'en' => accountLocales[1],
              _ => null,
            },
            onChanged: (value) {
              if (busy || value == null) return;
              unawaited(_saveLocale(value));
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  key: const ValueKey('account-locale-pl-PL'),
                  value: accountLocales[0],
                  enabled: !busy && profile != null,
                  title: Text(l10n.accountLanguagePolish),
                ),
                RadioListTile<String>(
                  key: const ValueKey('account-locale-en-US'),
                  value: accountLocales[1],
                  enabled: !busy && profile != null,
                  title: Text(l10n.accountLanguageEnglish),
                ),
              ],
            ),
          ),
          SectionHeader(l10n.accountSecuritySection),
          ListTile(
            key: const ValueKey('account-change-password'),
            leading: const Icon(Icons.password),
            title: Text(l10n.accountChangePassword),
            subtitle: Text(l10n.accountChangePasswordSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => unawaited(context.push(AppRoutes.accountPassword)),
          ),
          if (ref.watch(
            coreCapabilityAvailableProvider(CoreCapability.sessions),
          ))
            ListTile(
              key: const ValueKey('account-sessions'),
              leading: const Icon(Icons.devices_outlined),
              title: Text(l10n.accountSessions),
              subtitle: Text(l10n.accountSessionsSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(AppRoutes.accountSessions)),
            ),
          ListTile(
            key: const ValueKey('account-recovery-code'),
            leading: const Icon(Icons.key_outlined),
            title: Text(l10n.accountRecoveryCode),
            subtitle: Text(l10n.accountRecoveryCodeSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => unawaited(context.push(AppRoutes.accountRecoveryCode)),
          ),
        ],
      ),
    );
  }
}
