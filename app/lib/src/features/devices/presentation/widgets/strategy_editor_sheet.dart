import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/devices/application/strategy_edit_controller.dart';
import 'package:gi_home/src/features/devices/domain/confirmation_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_command_state.dart';
import 'package:gi_home/src/features/devices/domain/strategy_edit.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/devices/presentation/heating_safety_labels.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/heating_control_panel.dart';
import 'package:material_ui/material_ui.dart';

/// Opens the control strategy editor for [detail]'s device.
Future<void> showStrategyEditor(
  BuildContext context, {
  required Fetched<DeviceDetail> detail,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => StrategyEditorSheet(detail: detail),
);

/// Edits the BASE control strategy (plan §12.5, M2 item 4): target,
/// hysteresis and mode, validated like GI Core within the UI limits of
/// [StrategyLimits]. Saving re-reads the device first; a change made
/// elsewhere (base values or the suspension) is shown as a diff to reapply
/// or discard, never overwritten silently.
class StrategyEditorSheet extends ConsumerStatefulWidget {
  const new({required this.detail, super.key});

  /// The device as it was when the editor opened.
  final Fetched<DeviceDetail> detail;

  @override
  ConsumerState<StrategyEditorSheet> createState() =>
      _StrategyEditorSheetState();
}

class _StrategyEditorSheetState extends ConsumerState<StrategyEditorSheet> {
  final _form = GlobalKey<FormState>();
  late StrategyBaseline _baseline;
  late final TextEditingController _target;
  late final TextEditingController _hysteresis;
  late ControlStrategyMode _mode;

  DeviceDetail get _device => widget.detail.value;

  @override
  void initState() {
    super.initState();
    _baseline = StrategyBaseline.of(_device);
    _target = TextEditingController();
    _hysteresis = TextEditingController();
  }

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load(_baseline.base ?? _device.controlStrategy);
  }

  void _load(ControlStrategy? strategy) {
    final l10n = context.l10n;
    String text(double? value) =>
        value == null ? '' : formatTemperature(l10n, value);
    _target.text = text(strategy?.targetTemperatureCelsius);
    _hysteresis.text = text(strategy?.hysteresisCelsius);
    final mode = strategy?.mode;
    _mode = mode == null || mode == ControlStrategyMode.unknown
        ? ControlStrategyMode.auto
        : mode;
  }

  @override
  void dispose() {
    _target.dispose();
    _hysteresis.dispose();
    super.dispose();
  }

  StrategyEditControllerProvider get _provider =>
      strategyEditControllerProvider(_device.id);

  Future<void> _save({StrategyBaseline? against}) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final draft = StrategyValidation.draft(
      target: _target.text,
      hysteresis: _hysteresis.text,
      mode: _mode,
    );
    if (draft == null) return;
    final startedFrom = against ?? _baseline;
    final requirement = ConfirmationPolicy.of(
      ChangeStrategy(from: startedFrom.base, to: draft),
      _device,
    );
    if (requirement.needsConfirmation) {
      final confirmed = await _confirm(requirement);
      if (!confirmed || !mounted) return;
    }
    if (against != null) setState(() => _baseline = against);
    await ref
        .read(_provider.notifier)
        .submit(startedFrom: startedFrom, draft: draft);
  }

  void _discard(StrategyBaseline current) {
    setState(() {
      _baseline = current;
      _load(current.base);
    });
    ref.read(_provider.notifier).reset();
  }

  Future<bool> _confirm(ConfirmationRequirement requirement) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.strategyConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final consequence in requirement.consequences)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(consequenceText(l10n, consequence)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey('strategy-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.strategyConfirmSave),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(_provider);
    final busy = state.isBusy;
    final safeMax = _device.pvHeatingConfig?.safeMaxTemperatureCelsius;
    final typedTarget = StrategyValidation.parse(_target.text);

    String? fieldError(StrategyFieldError? error, double min, double max) =>
        switch (error) {
          null => null,
          StrategyFieldError.notANumber => l10n.strategyErrorNotANumber,
          StrategyFieldError.outOfRange => l10n.strategyErrorRange(
            formatTemperature(l10n, min),
            formatTemperature(l10n, max),
          ),
          StrategyFieldError.notOnStep => l10n.strategyErrorStep(
            formatTemperature(l10n, StrategyLimits.targetStep),
          ),
        };

    final children = <Widget>[
      Text(l10n.strategyEditorTitle, style: textTheme.titleMedium),
      Text(
        l10n.strategyEditorIntro,
        style: textTheme.bodySmall?.copyWith(color: tokens.textMuted),
      ),
      if (_baseline.suspended)
        MessageBanner(
          key: const ValueKey('strategy-suspended-note'),
          tone: MessageTone.warning,
          message: l10n.strategySuspendedNote,
        ),
      TextFormField(
        key: const ValueKey('strategy-target'),
        controller: _target,
        enabled: !busy,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l10n.strategyTargetLabel),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (_) => setState(() {}),
        validator: (text) => fieldError(
          StrategyValidation.target(text ?? ''),
          StrategyLimits.targetMin,
          StrategyLimits.targetMax,
        ),
      ),
      if (safeMax != null && typedTarget != null && typedTarget > safeMax)
        Text(
          l10n.strategyAboveSafeMaxWarning(formatTemperature(l10n, safeMax)),
          key: const ValueKey('strategy-above-safe-max'),
          style: textTheme.bodySmall?.copyWith(color: tokens.warning),
        ),
      TextFormField(
        key: const ValueKey('strategy-hysteresis'),
        controller: _hysteresis,
        enabled: !busy,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l10n.strategyHysteresisLabel),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (text) => fieldError(
          StrategyValidation.hysteresis(text ?? ''),
          StrategyLimits.hysteresisMin,
          StrategyLimits.hysteresisMax,
        ),
      ),
      Text(l10n.strategyModeLabel, style: textTheme.labelLarge),
      SegmentedButton<ControlStrategyMode>(
        key: const ValueKey('strategy-mode'),
        segments: [
          for (final mode in const [
            ControlStrategyMode.auto,
            ControlStrategyMode.off,
            ControlStrategyMode.manual,
          ])
            ButtonSegment(
              value: mode,
              label: Text(strategyModeShort(l10n, mode)),
            ),
        ],
        selected: {_mode},
        onSelectionChanged: busy
            ? null
            : (selected) => setState(() => _mode = selected.single),
      ),
      Text(switch (_mode) {
        ControlStrategyMode.off => l10n.heatingStrategyModeOff,
        ControlStrategyMode.manual => l10n.heatingStrategyModeManual,
        _ => l10n.heatingStrategyModeAuto,
      }, style: textTheme.bodySmall?.copyWith(color: tokens.textMuted)),
      ..._outcome(l10n, state),
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(tokens.gap, 0, tokens.gap, tokens.gap),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, child) in children.indexed) ...[
                  if (index > 0) const SizedBox(height: 12),
                  child,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _outcome(AppLocalizations l10n, StrategyEditState state) {
    final save = FilledButton(
      key: const ValueKey('strategy-save'),
      onPressed: state.isBusy ? null : _save,
      child: Text(l10n.strategySave),
    );
    final cancel = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(l10n.actionCancel),
    );
    return switch (state) {
      StrategyEditIdle() => [save, cancel],
      StrategyEditChecking() => [_busy(l10n.strategyChecking)],
      StrategyEditSaving() => [_busy(l10n.strategySaving)],
      StrategyEditLocked(:final decision) => [
        MessageBanner(
          tone: MessageTone.warning,
          message: lockReasonText(l10n, decision.primary),
        ),
        save,
        cancel,
      ],
      StrategyEditFailed(:final failure) => [
        MessageBanner(
          key: const ValueKey('strategy-failed'),
          message: failureMessage(l10n, failure),
          detail: failureRequestIdLine(l10n, failure),
          monospaceDetail: true,
        ),
        save,
        cancel,
      ],
      StrategyEditConflict(:final conflict) => [
        _ConflictView(conflict: conflict),
        FilledButton(
          key: const ValueKey('strategy-reapply'),
          onPressed: () => _save(against: conflict.current),
          child: Text(l10n.strategyConflictReapply),
        ),
        OutlinedButton(
          key: const ValueKey('strategy-discard'),
          onPressed: () => _discard(conflict.current),
          child: Text(l10n.strategyConflictDiscard),
        ),
      ],
      StrategyEditSaved(:final result, :final suspended) => [
        _SavedView(result: result, suspended: suspended),
        FilledButton(
          key: const ValueKey('strategy-close'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
      ],
    };
  }

  Widget _busy(String text) => Row(
    key: const ValueKey('strategy-busy'),
    children: [
      const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      const SizedBox(width: 12),
      Expanded(child: Semantics(liveRegion: true, child: Text(text))),
    ],
  );
}

class _ConflictView extends StatelessWidget {
  const new({required this.conflict});

  final StrategyConflict conflict;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String temp(double? value) =>
        value == null ? l10n.strategyValueNone : formatTemperature(l10n, value);
    String mode(ControlStrategyMode? value) =>
        value == null ? l10n.strategyValueNone : strategyModeShort(l10n, value);
    String suspended({required bool value}) =>
        value ? l10n.strategyValueSuspended : l10n.strategyValueActive;
    final a = conflict.started;
    final b = conflict.current;
    final rows = [
      for (final field in conflict.fields)
        switch (field) {
          StrategyConflictField.target => l10n.strategyConflictRow(
            l10n.strategyFieldTarget,
            temp(a.base?.targetTemperatureCelsius),
            temp(b.base?.targetTemperatureCelsius),
          ),
          StrategyConflictField.hysteresis => l10n.strategyConflictRow(
            l10n.strategyFieldHysteresis,
            temp(a.base?.hysteresisCelsius),
            temp(b.base?.hysteresisCelsius),
          ),
          StrategyConflictField.mode => l10n.strategyConflictRow(
            l10n.strategyFieldMode,
            mode(a.base?.mode),
            mode(b.base?.mode),
          ),
          StrategyConflictField.suspended => l10n.strategyConflictRow(
            l10n.strategyFieldSuspended,
            suspended(value: a.suspended),
            suspended(value: b.suspended),
          ),
        },
    ];
    return MessageBanner(
      key: const ValueKey('strategy-conflict'),
      tone: MessageTone.warning,
      message: l10n.strategyConflictTitle,
      detail: [l10n.strategyConflictBody, ...rows].join('\n'),
    );
  }
}

class _SavedView extends StatelessWidget {
  const new({required this.result, required this.suspended});

  final ControlStrategyUpdateResult result;
  final bool suspended;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final base = result.baseControlStrategy;
    final effective = result.controlStrategy;
    return MessageBanner(
      key: const ValueKey('strategy-saved'),
      tone: MessageTone.info,
      message: l10n.strategySavedTitle,
      detail: [
        if (base != null) l10n.strategySavedBase(strategyValueText(l10n, base)),
        if (effective != null)
          l10n.strategySavedEffective(strategyValueText(l10n, effective)),
        if (suspended) l10n.strategySavedSuspended,
      ].join('\n'),
    );
  }
}
