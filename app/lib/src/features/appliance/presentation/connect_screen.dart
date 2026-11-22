import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/centered_form.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/open_app_settings_button.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/appliance_search.dart';
import 'package:gi_home/src/features/appliance/application/connect_controller.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_candidate.dart';
import 'package:gi_home/src/features/appliance/presentation/change_appliance_dialog.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/demo/application/demo_mode.dart';
import 'package:material_ui/material_ui.dart';

/// "Znajdź GI Home" (plan §4.1, §9.2): the connection ladder runs as soon
/// as the screen opens and lists every appliance it confirms; the address
/// can always be typed in as well. A picked or typed appliance is confirmed
/// before anything is saved, and one that would replace the saved profile
/// (D1 = A) is asked about first.
class ConnectScreen extends ConsumerStatefulWidget {
  const new({super.key, this.onConnected});

  /// Runs once the confirmed appliance is saved. Without it the router's
  /// guards move on by themselves (no profile was saved before).
  final void Function(BuildContext context)? onConnected;

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _addressFocus = FocusNode();
  bool _startingDemo = false;

  @override
  void dispose() {
    _address.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  void _probe() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    unawaited(
      ref.read(connectControllerProvider.notifier).probe(_address.text),
    );
  }

  /// Fills the field with [preset] for the developer to edit or send; an
  /// address still missing the computer's IP leaves the cursor where it goes.
  void _usePreset(DevAddressPreset preset) {
    _address.value = TextEditingValue(
      text: preset.fill,
      selection: TextSelection.collapsed(
        offset: preset.needsComputerIp ? 0 : preset.fill.length,
      ),
    );
    _addressFocus.requestFocus();
  }

  /// "Wypróbuj wersję demonstracyjną" (plan §19.5): a made-up appliance in
  /// memory; the saved profile and its session are left untouched.
  Future<void> _startDemo() async {
    if (_startingDemo) return;
    setState(() => _startingDemo = true);
    try {
      await ref.read(demoModeProvider.notifier).enter();
      if (mounted) widget.onConnected?.call(context);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.demoStartFailed)));
      }
    } finally {
      if (mounted) setState(() => _startingDemo = false);
    }
  }

  List<Widget> _demoEntry(BuildContext context, {required bool busy}) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    return [
      SizedBox(height: tokens.gap * 2),
      const Divider(),
      SizedBox(height: tokens.gap),
      Text(l10n.demoEntryTitle, style: textTheme.titleMedium),
      const SizedBox(height: 4),
      Text(
        l10n.demoEntryBody,
        style: textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
      ),
      SizedBox(height: tokens.gap),
      OutlinedButton.icon(
        key: const ValueKey('demo-enter'),
        onPressed: busy || _startingDemo ? null : _startDemo,
        icon: const Icon(Icons.play_circle_outline),
        label: Text(l10n.demoEnter),
      ),
    ];
  }

  /// "Tak, połącz": another appliance than the saved one replaces it only
  /// after the same confirmation as "Zmień urządzenie" in Settings.
  Future<void> _confirm(ProbeResult probe) async {
    final controller = ref.read(connectControllerProvider.notifier);
    final profile = ref.read(applianceProfileProvider);
    if (profile != null && controller.replacesProfile(probe)) {
      final signedIn = ref.read(authSessionProvider).value is AuthAuthenticated;
      final confirmed = await confirmChangeAppliance(
        context,
        applianceLabel: profile.label,
        canLogOut: signedIn,
      );
      if (!confirmed || !mounted) return;
    }
    await controller.confirm();
    if (mounted) widget.onConnected?.call(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(connectControllerProvider);
    // Watched while the confirmation shows too, so "No" returns to the
    // results instead of searching again.
    final search = ref.watch(applianceSearchProvider);
    // The confirmation depends on the saved profile (replace, notice).
    ref.watch(applianceProfileProvider);
    final probe = state.value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectTitle)),
      body: CenteredForm(
        children: probe != null && !state.isLoading
            ? [_ConfirmCard(probe: probe, onConfirm: () => _confirm(probe))]
            : [
                ..._searchSection(context, search, probing: state.isLoading),
                ..._addressForm(context, state),
                ..._demoEntry(context, busy: state.isLoading),
              ],
      ),
    );
  }

  List<Widget> _searchSection(
    BuildContext context,
    AsyncValue<ApplianceSearch> search, {
    required bool probing,
  }) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final mutedStyle = textTheme.bodyMedium?.copyWith(color: tokens.textMuted);
    final progress = search.value ?? ApplianceSearch.started;
    final done = progress.done || search.hasError;
    final failure = progress.failure ?? search.error;
    final profile = ref.read(applianceProfileProvider);
    return [
      Text(l10n.connectIntro, style: textTheme.bodyLarge),
      SizedBox(height: tokens.gap * 1.5),
      Row(
        children: [
          Expanded(
            child: Text(l10n.connectSearchTitle, style: textTheme.titleMedium),
          ),
          if (done)
            TextButton.icon(
              onPressed: () => ref.invalidate(applianceSearchProvider),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.connectSearchAgain),
            ),
        ],
      ),
      const SizedBox(height: 8),
      if (!done) ...[
        const LinearProgressIndicator(),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(l10n.connectSearching, style: mutedStyle),
        ),
        const SizedBox(height: 8),
      ],
      for (final candidate in progress.candidates)
        _CandidateTile(
          candidate: candidate,
          isCurrent: profile?.matches(candidate.probe) ?? false,
          onTap: probing
              ? null
              : () => ref
                    .read(connectControllerProvider.notifier)
                    .pick(candidate),
        ),
      if (done && failure != null)
        MessageBanner(
          message: failureMessage(l10n, failure),
          action: failureAction(failure),
        )
      else if (done && progress.candidates.isEmpty)
        Text(l10n.connectSearchNoneFound, style: mutedStyle),
      SizedBox(height: tokens.gap * 2),
    ];
  }

  List<Widget> _addressForm(
    BuildContext context,
    AsyncValue<ProbeResult?> state,
  ) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final error = state.hasError && !state.isLoading ? state.error : null;
    return [
      Text(l10n.connectManualTitle, style: textTheme.titleMedium),
      SizedBox(height: tokens.gap),
      Form(
        key: _formKey,
        child: TextFormField(
          controller: _address,
          focusNode: _addressFocus,
          enabled: !state.isLoading,
          keyboardType: TextInputType.url,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.go,
          decoration: InputDecoration(
            labelText: l10n.connectAddressLabel,
            hintText: l10n.connectAddressHint,
            prefixIcon: const Icon(Icons.router_outlined),
          ),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? l10n.connectAddressRequired : null,
          onFieldSubmitted: (_) => _probe(),
        ),
      ),
      if (error != null) ...[
        SizedBox(height: tokens.gap),
        MessageBanner(
          message: _connectErrorMessage(l10n, error),
          detail: failureRequestIdLine(l10n, error),
          monospaceDetail: true,
          action: failureAction(error),
        ),
      ],
      SizedBox(height: tokens.gap),
      FilledButton.icon(
        onPressed: state.isLoading ? null : _probe,
        icon: state.isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.search),
        label: Text(state.isLoading ? l10n.connectProbing : l10n.connectSubmit),
      ),
      // Dev flavor presets and hints only (plan §9.6); beta and prod users
      // have the field hint (gi-home.local or an IP address).
      if (ref.watch(appFlavorProvider) == AppFlavor.dev) ...[
        SizedBox(height: tokens.gap * 2),
        Text(l10n.connectHintsTitle, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in DevAddressPreset.values)
              ActionChip(
                key: ValueKey('connect-preset-${preset.name}'),
                avatar: Icon(preset.icon, size: 18),
                label: Text(_presetLabel(l10n, preset)),
                onPressed: state.isLoading ? null : () => _usePreset(preset),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final note in [
          l10n.connectHintUsbNote(DevAddressPreset.adbReverseCommand),
          l10n.connectHintLan,
          l10n.connectHintProxyNote,
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              note,
              style: textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          ),
      ],
    ];
  }

  static String _presetLabel(AppLocalizations l10n, DevAddressPreset preset) {
    final name = switch (preset) {
      DevAddressPreset.androidEmulator => l10n.connectHintAndroidEmulator,
      DevAddressPreset.iosSimulator => l10n.connectHintIosSimulator,
      DevAddressPreset.androidUsb => l10n.connectHintAndroidUsb,
      DevAddressPreset.lanPhone => l10n.connectHintLanPhone,
      DevAddressPreset.lanProxy => l10n.connectHintLanProxy,
    };
    final address = preset.needsComputerIp
        ? '<${l10n.connectHintComputerIp}>${preset.fill}'
        : preset.fill;
    return '$name: $address';
  }

  static String _connectErrorMessage(AppLocalizations l10n, Object error) =>
      switch (error) {
        FormatException() => l10n.connectErrorInvalidAddress,
        // Something answered, but not like GI Core does.
        RouteAbsentFailure() ||
        NotFoundFailure() ||
        UnexpectedResponseFailure() ||
        UnexpectedShapeFailure() => l10n.connectErrorNotGiHome,
        _ => failureMessage(l10n, error),
      };
}

/// Dev flavor address presets (plan §9.6). They fill the address field and
/// can be edited before probing.
enum DevAddressPreset {
  /// The host's loopback as seen from an Android emulator.
  androidEmulator('10.0.2.2:3000', Icons.android),

  /// The host's loopback as seen from an iOS simulator.
  iosSimulator('localhost:3000', Icons.phone_iphone),

  /// A phone on USB after [adbReverseCommand]; Core stays on loopback.
  androidUsb('localhost:3000', Icons.usb),

  /// Any phone on the LAN, with Core published on `0.0.0.0`
  /// (`GI_CORE_BIND_ADDRESS`); the developer types the computer's IP.
  lanPhone(':3000', Icons.wifi, needsComputerIp: true),

  /// Any phone on the LAN through `tools/dev_lan_proxy`
  /// (`0.0.0.0:8080 → 127.0.0.1:3000`) when Core stays on loopback.
  lanProxy(':8080', Icons.lan_outlined, needsComputerIp: true);

  new(this.fill, this.icon, {this.needsComputerIp = false});

  static const adbReverseCommand = 'adb reverse tcp:3000 tcp:3000';

  /// Text put into the address field.
  final String fill;
  final IconData icon;

  /// Whether the computer's LAN IP has to be typed before [fill].
  final bool needsComputerIp;
}

/// A confirmed appliance found by the connection ladder.
class _CandidateTile extends StatelessWidget {
  const new({
    required this.candidate,
    required this.isCurrent,
    required this.onTap,
  });

  final ApplianceCandidate candidate;

  /// The saved profile's appliance.
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final details = [
      candidate.probe.address.authority,
      if (!candidate.initialized) l10n.connectCandidateNotSetUp,
      if (isCurrent) l10n.connectCandidateCurrent,
    ];
    return Card(
      key: ValueKey('connect-candidate-${candidate.host}'),
      child: ListTile(
        leading: Icon(Icons.local_fire_department, color: tokens.ember),
        title: Text(candidate.deviceName ?? l10n.appTitle),
        subtitle: Text(details.join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// "Czy to Twój GI Home?" — shown before anything is saved or sent. The
/// "not encrypted" notice shows once per profile (plan §9.4).
class _ConfirmCard extends ConsumerWidget {
  const new({required this.probe, required this.onConfirm});

  final ProbeResult probe;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(connectControllerProvider.notifier);
    final deviceName = probe.setup.deviceName ?? l10n.appTitle;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.gap * 1.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.local_fire_department, color: tokens.ember, size: 40),
            SizedBox(height: tokens.gap),
            Text(
              l10n.connectConfirmTitle,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.connectConfirmSubtitle(deviceName, probe.address.authority),
              style: textTheme.titleMedium?.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            if (!probe.setup.initialized) ...[
              SizedBox(height: tokens.gap),
              MessageBanner(
                message: l10n.connectNotInitializedNote,
                tone: MessageTone.info,
              ),
            ],
            if (controller.showsCleartextNotice(probe)) ...[
              SizedBox(height: tokens.gap),
              MessageBanner(
                message: l10n.connectCleartextNote,
                tone: MessageTone.warning,
              ),
            ],
            SizedBox(height: tokens.gap * 1.5),
            FilledButton(
              onPressed: onConfirm,
              child: Text(l10n.connectConfirmYes),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: controller.reset,
              child: Text(l10n.connectConfirmNo),
            ),
          ],
        ),
      ),
    );
  }
}
