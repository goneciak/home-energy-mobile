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
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/application/login_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Email + password login with system autofill (plan §4.1, §7.5).
class LoginScreen extends ConsumerStatefulWidget {
  const new({super.key});

  /// Wait after `HTTP_429` when the server sends no `Retry-After`.
  static const defaultRateLimitWait = Duration(seconds: 60);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _password = TextEditingController();
  bool _obscurePassword = true;
  Timer? _countdown;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(
      text: ref.read(applianceProfileProvider)?.lastUserEmail ?? '',
    );
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_secondsLeft > 0 || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(loginControllerProvider.notifier)
        .submit(email: _email.text, password: _password.text);
    if (ok) TextInput.finishAutofillContext();
  }

  void _startCountdown(Duration wait) {
    _countdown?.cancel();
    setState(() => _secondsLeft = wait.inSeconds.clamp(1, 3600));
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginControllerProvider, (_, next) {
      if (next case AsyncError(error: RateLimitedFailure(:final retryAfter))) {
        _startCountdown(retryAfter ?? LoginScreen.defaultRateLimitWait);
      }
    });

    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final submission = ref.watch(loginControllerProvider);
    final profile = ref.watch(applianceProfileProvider);
    final lostReason = switch (ref.watch(authSessionProvider)) {
      AsyncData(value: AuthSessionLost(:final reason))
          when reason != SessionLostReason.noToken =>
        reason,
      _ => null,
    };
    final busy = submission.isLoading;
    final error = busy ? null : submission.error;
    final blocked = busy || _secondsLeft > 0;

    return Scaffold(
      body: CenteredForm(
        children: [
          Icon(Icons.local_fire_department, size: 48, color: tokens.ember),
          SizedBox(height: tokens.gap),
          Text(
            l10n.loginTitle,
            // Italic Fraunces, like the web panel's sign-in heading.
            style: textTheme.headlineMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          if (profile != null)
            Text(
              l10n.loginSubtitle(profile.label),
              style: textTheme.titleMedium?.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: tokens.gap * 1.5),
          if (lostReason != null && error == null) ...[
            MessageBanner(
              message: sessionLostMessage(l10n, lostReason),
              tone: MessageTone.warning,
            ),
            SizedBox(height: tokens.gap),
          ],
          if (_secondsLeft > 0) ...[
            // Only the static message is announced; the ticking countdown
            // is not, so screen readers do not repeat it every second.
            MessageBanner(
              message: l10n.loginErrorRateLimited,
              detail: l10n.loginRetryCountdown(_secondsLeft),
            ),
            SizedBox(height: tokens.gap),
          ] else if (error != null && error is! RateLimitedFailure) ...[
            MessageBanner(
              message: _loginErrorMessage(l10n, error),
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
                  TextFormField(
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
                    validator: (value) => _looksLikeEmail(value ?? '')
                        ? null
                        : l10n.loginEmailInvalid,
                  ),
                  SizedBox(height: tokens.gap),
                  TextFormField(
                    controller: _password,
                    enabled: !busy,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.loginPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? l10n.loginShowPassword
                            : l10n.loginHidePassword,
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) => (value ?? '').isEmpty
                        ? l10n.loginPasswordRequired
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.gap * 1.5),
          FilledButton(
            onPressed: blocked ? null : _submit,
            child: busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.loginSubmit),
          ),
          SizedBox(height: tokens.gap / 2),
          TextButton(
            key: const ValueKey('login-forgot-password'),
            onPressed: busy ? null : () => context.go(AppRoutes.recover),
            child: Text(l10n.loginForgotPassword),
          ),
        ],
      ),
    );
  }

  static bool _looksLikeEmail(String value) {
    final text = value.trim();
    final at = text.indexOf('@');
    return at > 0 && at < text.length - 1 && !text.contains(' ');
  }

  static String _loginErrorMessage(AppLocalizations l10n, Object error) =>
      switch (error) {
        ApiFailure(code: 'AUTH_INVALID_CREDENTIALS') =>
          l10n.loginErrorInvalidCredentials,
        ApiFailure(code: 'USER_DISABLED') => l10n.loginErrorUserDisabled,
        // Login rejects unknown fields; a 400 here means a malformed email.
        ValidationFailure() => l10n.loginEmailInvalid,
        _ => failureMessage(l10n, error),
      };
}
