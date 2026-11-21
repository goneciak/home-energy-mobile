import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/centered_form.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/auth/application/change_password_controller.dart';
import 'package:gi_home/src/features/auth/domain/password_policy.dart';
import 'package:material_ui/material_ui.dart';

/// Forced password change when `mustChangePassword` is set (plan §4.1).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    unawaited(
      ref
          .read(changePasswordControllerProvider.notifier)
          .submit(currentPassword: _current.text, newPassword: _new.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen(changePasswordControllerProvider, (_, next) {
      if (next case AsyncData(value: final ChangePasswordResult result)) {
        TextInput.finishAutofillContext();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.changePasswordOtherSessionsEnded(result.revokedSessions),
            ),
          ),
        );
        ref.read(changePasswordControllerProvider.notifier).finish();
      }
    });

    final tokens = GiTokens.of(context);
    final state = ref.watch(changePasswordControllerProvider);
    final busy = state.isLoading;
    final error = busy ? null : state.error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle)),
      body: CenteredForm(
        children: [
          Text(
            l10n.changePasswordIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: tokens.gap * 1.5),
          if (error != null) ...[
            MessageBanner(
              message: _errorMessage(l10n, error),
              detail: failureRequestIdLine(l10n, error),
              monospaceDetail: true,
            ),
            SizedBox(height: tokens.gap),
          ],
          AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PasswordField(
                    controller: _current,
                    enabled: !busy,
                    label: l10n.changePasswordCurrentLabel,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) =>
                        (value ?? '').isEmpty ? l10n.passwordRequired : null,
                  ),
                  SizedBox(height: tokens.gap),
                  _PasswordField(
                    controller: _new,
                    enabled: !busy,
                    label: l10n.changePasswordNewLabel,
                    helper: l10n.changePasswordRules,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) =>
                        _policyMessage(l10n, PasswordPolicy.check(value ?? '')),
                  ),
                  SizedBox(height: tokens.gap),
                  _PasswordField(
                    controller: _repeat,
                    enabled: !busy,
                    label: l10n.changePasswordRepeatLabel,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) =>
                        value == _new.text ? null : l10n.passwordMismatch,
                    onSubmitted: _submit,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.gap * 1.5),
          FilledButton(
            onPressed: busy ? null : _submit,
            child: busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.changePasswordSubmit),
          ),
        ],
      ),
    );
  }

  static String? _policyMessage(
    AppLocalizations l10n,
    PasswordProblem? problem,
  ) => switch (problem) {
    null => null,
    PasswordProblem.empty => l10n.passwordRequired,
    PasswordProblem.tooShort => l10n.passwordTooShort,
    PasswordProblem.tooLong => l10n.passwordTooLong,
    PasswordProblem.noLowercase => l10n.passwordNeedsLowercase,
    PasswordProblem.noUppercase => l10n.passwordNeedsUppercase,
    PasswordProblem.noDigit => l10n.passwordNeedsDigit,
  };

  static String _errorMessage(AppLocalizations l10n, Object error) =>
      switch (error) {
        ApiFailure(code: 'USER_CURRENT_PASSWORD_INVALID') =>
          l10n.changePasswordCurrentInvalid,
        ApiFailure(code: 'USER_NEW_PASSWORD_SAME_AS_CURRENT') =>
          l10n.changePasswordSameAsCurrent,
        _ => failureMessage(l10n, error),
      };
}

class _PasswordField extends StatefulWidget {
  const new({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.autofillHints,
    required this.validator,
    this.helper,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String? helper;
  final List<String> autofillHints;
  final FormFieldValidator<String> validator;
  final VoidCallback? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSubmitted = widget.onSubmitted;
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: widget.autofillHints,
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helper,
        helperMaxLines: 3,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscure ? l10n.loginShowPassword : l10n.loginHidePassword,
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: widget.validator,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
    );
  }
}
