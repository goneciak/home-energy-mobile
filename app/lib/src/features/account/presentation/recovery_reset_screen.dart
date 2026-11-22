import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/centered_form.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/secure_content.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:gi_home/src/features/auth/presentation/change_password_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Odzyskiwanie hasła" (plan §4.2, §20 M3.5), public, from the login
/// screen: e-mail, recovery code (uppercased as typed, dashes kept) and a
/// new password (`POST /auth/recovery/reset`). Every session of the user
/// ends; the code stays valid, so a new one is offered after the next
/// login.
class RecoveryResetScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RecoveryResetScreen> createState() =>
      _RecoveryResetScreenState();
}

class _RecoveryResetScreenState extends ConsumerState<RecoveryResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    unawaited(
      ref
          .read(recoveryResetControllerProvider.notifier)
          .submit(
            RecoveryResetRequest(
              email: _email.text,
              recoveryCode: _code.text,
              newPassword: _new.text,
            ),
          ),
    );
  }

  /// The server's e-mail rule, as [RecoveryResetRequest.validate] has it.
  static bool _emailInvalid(String email) => RecoveryResetRequest(
    email: email,
    recoveryCode: '',
    newPassword: '',
  ).validate().contains(RecoveryResetProblem.email);

  void _toLogin() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(recoveryResetControllerProvider);
    final busy = state.isLoading;
    final error = busy ? null : state.error;
    final done = state.value ?? false;

    ref.listen(recoveryResetControllerProvider, (_, next) {
      if (next case AsyncData(value: true)) TextInput.finishAutofillContext();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recoveryResetTitle),
        leading: IconButton(
          tooltip: l10n.recoveryResetBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: _toLogin,
        ),
      ),
      body: CenteredForm(
        children: done
            ? [
                Icon(Icons.check_circle_outline, size: 48, color: tokens.teal),
                SizedBox(height: tokens.gap),
                Text(
                  l10n.recoveryResetDoneTitle,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.gap),
                Text(
                  l10n.recoveryResetDoneBody,
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.gap * 1.5),
                FilledButton(
                  key: const ValueKey('recovery-reset-login'),
                  onPressed: _toLogin,
                  child: Text(l10n.recoveryResetGoToLogin),
                ),
              ]
            : [
                Text(l10n.recoveryResetIntro, style: textTheme.bodyLarge),
                SizedBox(height: tokens.gap * 1.5),
                if (error != null) ...[
                  MessageBanner(
                    message: recoveryResetErrorMessage(l10n, error),
                    detail: failureRequestIdLine(l10n, error),
                    monospaceDetail: true,
                  ),
                  SizedBox(height: tokens.gap),
                ],
                // Plan §7.7: the code and the new password are secrets, so the
                // form is screen-protected and hidden in the background.
                SecureContent(
                  hidden: Padding(
                    key: const ValueKey('recovery-reset-hidden'),
                    padding: EdgeInsets.symmetric(vertical: tokens.gap),
                    child: Text(
                      l10n.recoveryResetHidden,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  child: AutofillGroup(
                    // Hiding the form must not offer to save a half-typed
                    // password; success commits explicitly.
                    onDisposeAction: AutofillContextAction.cancel,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            key: const ValueKey('recovery-reset-email'),
                            controller: _email,
                            enabled: !busy,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.loginEmailLabel,
                              prefixIcon: const Icon(Icons.alternate_email),
                            ),
                            validator: (value) => _emailInvalid(value ?? '')
                                ? l10n.loginEmailInvalid
                                : null,
                          ),
                          SizedBox(height: tokens.gap),
                          TextFormField(
                            key: const ValueKey('recovery-reset-code'),
                            controller: _code,
                            enabled: !busy,
                            autocorrect: false,
                            enableSuggestions: false,
                            keyboardType: TextInputType.visiblePassword,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: const [UpperCaseCodeFormatter()],
                            textInputAction: TextInputAction.next,
                            style: GiFonts.monospace(),
                            decoration: InputDecoration(
                              labelText: l10n.recoveryResetCodeLabel,
                              hintText: 'XXXX-XXXX-XXXX-XXXX-…',
                              helperText: l10n.recoveryResetCodeHelper,
                              helperMaxLines: 3,
                              prefixIcon: const Icon(Icons.key_outlined),
                            ),
                            validator: (value) => recoveryCodeProblemMessage(
                              l10n,
                              RecoveryCodeFormat.check(value ?? ''),
                            ),
                          ),
                          SizedBox(height: tokens.gap),
                          PasswordField(
                            controller: _new,
                            enabled: !busy,
                            label: l10n.changePasswordNewLabel,
                            helper: l10n.changePasswordRules,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (value) => passwordPolicyMessage(
                              l10n,
                              PasswordPolicy.check(value ?? ''),
                            ),
                          ),
                          SizedBox(height: tokens.gap),
                          PasswordField(
                            controller: _repeat,
                            enabled: !busy,
                            label: l10n.changePasswordRepeatLabel,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (value) => value == _new.text
                                ? null
                                : l10n.passwordMismatch,
                            onSubmitted: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: tokens.gap * 1.5),
                FilledButton(
                  key: const ValueKey('recovery-reset-submit'),
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.recoveryResetSubmit),
                ),
              ],
      ),
    );
  }
}

/// The message for a rejected recovery reset. A wrong e-mail and a wrong
/// code read the same, like on the server.
String recoveryResetErrorMessage(AppLocalizations l10n, Object error) =>
    switch (error) {
      ApiFailure(code: GiErrorCodes.authRecoveryInvalid) =>
        l10n.recoveryResetInvalid,
      RateLimitedFailure() => l10n.recoveryResetRateLimited,
      _ => failureMessage(l10n, error),
    };

/// The message for a typed recovery code that cannot be valid, or `null`.
/// A code without dashes passes: they are restored before sending.
String? recoveryCodeProblemMessage(
  AppLocalizations l10n,
  RecoveryCodeProblem? problem,
) => switch (problem) {
  null || RecoveryCodeProblem.missingDashes => null,
  RecoveryCodeProblem.empty => l10n.recoveryResetCodeRequired,
  RecoveryCodeProblem.tooLong ||
  RecoveryCodeProblem.malformed => l10n.recoveryResetCodeMalformed,
};

/// Uppercases a recovery code as it is typed; dashes and the cursor stay.
class UpperCaseCodeFormatter extends TextInputFormatter {
  const new();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
