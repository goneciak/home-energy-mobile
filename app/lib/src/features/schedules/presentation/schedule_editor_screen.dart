import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:gi_home/src/features/devices/domain/strategy_edit.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/schedules/application/schedule_providers.dart';
import 'package:gi_home/src/features/schedules/domain/api_weekday.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_mutation_state.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_window.dart';
import 'package:gi_home/src/features/schedules/presentation/schedule_labels.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Editor of a new ([scheduleId] `null`) or existing heating schedule
/// (OWNER, ADMIN). Saving or deleting goes back to the list, which is
/// reloaded together with the device (GI Core reconciles the effective
/// strategy right away). A schedule deleted elsewhere
/// (`HEATING_SCHEDULE_NOT_FOUND`) also goes back, with a note.
class ScheduleEditorScreen extends ConsumerWidget {
  const new({required this.deviceId, super.key, this.scheduleId});

  final String deviceId;
  final String? scheduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mutation = scheduleMutationProvider(deviceId);
    ref.listen(mutation, (_, next) {
      final message = switch (next) {
        ScheduleMutationSaved(deleted: true) => l10n.scheduleDeleted,
        ScheduleMutationSaved() => l10n.scheduleSaved,
        ScheduleMutationGone() => l10n.scheduleGone,
        _ => null,
      };
      if (message == null) return;
      ref.read(mutation.notifier).reset();
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(message)));
      context.go(AppRoutes.deviceSchedules(deviceId));
    });
    final state = ref.watch(mutation);
    final schedules = ref.watch(schedulesProvider(deviceId));
    final canEdit = ref.watch(canEditSchedulesProvider);
    final clock = ref.watch(scheduleClockProvider);
    final now = ref.watch(clockProvider)();
    final id = scheduleId;

    final Widget body;
    if (!canEdit) {
      body = EmptyState(
        icon: Icons.lock_outline,
        title: l10n.heatingViewOnlyHint,
      );
    } else if (schedules.hasValue) {
      final list = schedules.requireValue;
      final existing = id == null
          ? null
          : list.where((s) => s.id == id).firstOrNull;
      body = id != null && existing == null
          ? EmptyState(icon: Icons.search_off, title: l10n.scheduleNotFound)
          : ScheduleEditorForm(
              key: ValueKey('schedule-editor-${id ?? 'new'}'),
              initial: existing,
              others: list,
              clock: clock,
              now: now,
              busy: state.isBusy,
              error: switch (state) {
                ScheduleMutationFailed(:final failure) => failure,
                _ => null,
              },
              onSave: (input) {
                final notifier = ref.read(mutation.notifier);
                if (existing == null) {
                  notifier.create(input).ignore();
                } else {
                  notifier.update(existing.id, _patchOf(input)).ignore();
                }
              },
              onDelete: existing == null
                  ? null
                  : () => ref.read(mutation.notifier).delete(existing.id),
            );
    } else if (schedules.error case final error?) {
      body = ErrorState(
        error: error,
        onRetry: () => ref.read(schedulesProvider(deviceId).notifier).refresh(),
      );
    } else {
      body = const LoadingView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          id == null
              ? l10n.scheduleEditorNewTitle
              : l10n.scheduleEditorEditTitle,
        ),
      ),
      body: body,
    );
  }

  static HeatingSchedulePatch _patchOf(HeatingScheduleInput input) =>
      HeatingSchedulePatch(
        name: input.name,
        daysOfWeek: input.daysOfWeek,
        startTime: input.startTime,
        endTime: input.endTime,
        targetTemperatureCelsius: input.targetTemperatureCelsius,
        hysteresisCelsius: input.hysteresisCelsius,
        enabled: input.enabled,
      );
}

/// The editor's form: name, day chips, start and end (zero-padded 24 h,
/// so never 24:00), target 0..100 °C, hysteresis 1..20 °C and the enabled
/// switch, checked like GI Core's DTO. It warns about what GI Core accepts
/// silently: a whole-day window (start = end) and windows that overlap
/// other enabled schedules (the one added first applies).
///
/// Days and times are edited in the [clock]'s editing clock and handed to
/// [onSave] on the GI Core clock.
class ScheduleEditorForm extends StatefulWidget {
  const new({
    required this.others,
    required this.clock,
    required this.now,
    required this.onSave,
    super.key,
    this.initial,
    this.busy = false,
    this.error,
    this.onDelete,
  });

  /// The schedule being edited; `null` for a new one.
  final HeatingSchedule? initial;

  /// Every schedule of the device (for the overlap warning).
  final List<HeatingSchedule> others;
  final ScheduleClock clock;
  final DateTime now;
  final bool busy;

  /// The failure of the last save, shown above the buttons.
  final Object? error;
  final ValueChanged<HeatingScheduleInput> onSave;

  /// Deletes [initial] after a confirmation; `null` for a new schedule.
  final Future<void> Function()? onDelete;

  @override
  State<ScheduleEditorForm> createState() => _ScheduleEditorFormState();
}

class _ScheduleEditorFormState extends State<ScheduleEditorForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _hysteresis;
  late Set<int> _days;
  late int _start;
  late int _end;
  late bool _enabled;
  var _submitted = false;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final core = initial == null ? null : ScheduleTimes.ofSchedule(initial);
    final shown = core == null
        ? null
        : widget.clock.toEditing(core, now: widget.now);
    _name = TextEditingController(text: initial?.name ?? '');
    _target = TextEditingController();
    _hysteresis = TextEditingController();
    _days = shown != null
        ? {...shown.days}
        : (initial == null ? {1, 2, 3, 4, 5} : <int>{});
    _start = shown?.startMinutes ?? 6 * 60;
    _end = shown?.endMinutes ?? 8 * 60;
    _enabled = initial?.enabled ?? true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final l10n = context.l10n;
    _target.text = formatNumber(
      l10n,
      widget.initial?.targetTemperatureCelsius ?? 50,
    );
    _hysteresis.text = formatNumber(
      l10n,
      widget.initial?.hysteresisCelsius ?? 3,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _hysteresis.dispose();
    super.dispose();
  }

  ScheduleTimes? get _edited => _days.isEmpty
      ? null
      : ScheduleTimes(days: _days, startMinutes: _start, endMinutes: _end);

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final minutes = picked.hour * 60 + picked.minute;
      if (start) {
        _start = minutes;
      } else {
        _end = minutes;
      }
    });
  }

  void _save() {
    setState(() => _submitted = true);
    final formValid = _form.currentState?.validate() ?? false;
    final edited = _edited;
    if (!formValid || edited == null) return;
    final core = widget.clock.toCore(edited, now: widget.now);
    final input = HeatingScheduleInput(
      name: _name.text.trim(),
      daysOfWeek: core.sortedDays,
      startTime: core.startTime,
      endTime: core.endTime,
      targetTemperatureCelsius: StrategyValidation.parse(_target.text)!,
      hysteresisCelsius: StrategyValidation.parse(_hysteresis.text)!,
      enabled: _enabled,
    );
    if (input.validate().isNotEmpty) return;
    widget.onSave(input);
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final onDelete = widget.onDelete;
    if (onDelete == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scheduleDeleteConfirmTitle),
        content: Text(
          l10n.scheduleDeleteConfirmBody(widget.initial?.name ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey('schedule-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.scheduleDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final busy = widget.busy;
    final edited = _edited;
    final core = edited == null
        ? null
        : widget.clock.toCore(edited, now: widget.now);
    final overlapping = core == null || !_enabled
        ? const <HeatingSchedule>[]
        : ActiveSchedule.overlapping(
            core,
            widget.others,
            exceptId: widget.initial?.id,
          );
    final error = widget.error;

    String? numberError(String? text, {required bool target}) {
      final value = StrategyValidation.parse(text ?? '');
      final valid =
          value != null &&
          (target
              ? HeatingScheduleRules.validTarget(value)
              : HeatingScheduleRules.validHysteresis(value));
      if (valid) return null;
      return target ? l10n.scheduleErrorTarget : l10n.scheduleErrorHysteresis;
    }

    final warnings = <String>[
      if (_start == _end) l10n.scheduleWarnWholeDay,
      if (_start > _end)
        l10n.scheduleWarnWraps(HeatingScheduleRules.formatMinutes(_end)),
      if (overlapping.isNotEmpty)
        l10n.scheduleWarnOverlap(overlapping.map((s) => s.name).join(', ')),
    ];

    return Form(
      key: _form,
      child: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          MessageBanner(
            tone: MessageTone.info,
            message: clockLabel(l10n, widget.clock, now: widget.now),
          ),
          SizedBox(height: tokens.gap),
          TextFormField(
            key: const ValueKey('schedule-name'),
            controller: _name,
            enabled: !busy,
            maxLength: HeatingScheduleRules.nameMaxLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.scheduleFieldName,
              errorMaxLines: 3,
            ),
            autovalidateMode: _submitted
                ? AutovalidateMode.always
                : AutovalidateMode.onUserInteraction,
            validator: (text) =>
                HeatingScheduleRules.validName((text ?? '').trim())
                ? null
                : l10n.scheduleErrorName,
          ),
          SizedBox(height: tokens.gap / 2),
          Text(l10n.scheduleFieldDays, style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final day in ApiWeekday.displayOrder)
                FilterChip(
                  key: ValueKey('schedule-day-$day'),
                  label: Text(weekdayShort(l10n, day)),
                  selected: _days.contains(day),
                  onSelected: busy
                      ? null
                      : (selected) => setState(() {
                          if (selected) {
                            _days.add(day);
                          } else {
                            _days.remove(day);
                          }
                        }),
                ),
            ],
          ),
          if (_submitted && _days.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.scheduleErrorDays,
                key: const ValueKey('schedule-days-error'),
                style: textTheme.bodySmall?.copyWith(color: tokens.danger),
              ),
            ),
          SizedBox(height: tokens.gap),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  key: const ValueKey('schedule-start'),
                  label: l10n.scheduleFieldStart,
                  minutes: _start,
                  onTap: busy ? null : () => _pickTime(start: true),
                ),
              ),
              SizedBox(width: tokens.gap),
              Expanded(
                child: _TimeField(
                  key: const ValueKey('schedule-end'),
                  label: l10n.scheduleFieldEnd,
                  minutes: _end,
                  onTap: busy ? null : () => _pickTime(start: false),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.gap),
          TextFormField(
            key: const ValueKey('schedule-target'),
            controller: _target,
            enabled: !busy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.scheduleFieldTarget,
              errorMaxLines: 3,
            ),
            autovalidateMode: _submitted
                ? AutovalidateMode.always
                : AutovalidateMode.onUserInteraction,
            validator: (text) => numberError(text, target: true),
          ),
          SizedBox(height: tokens.gap),
          TextFormField(
            key: const ValueKey('schedule-hysteresis'),
            controller: _hysteresis,
            enabled: !busy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.scheduleFieldHysteresis,
              errorMaxLines: 3,
            ),
            autovalidateMode: _submitted
                ? AutovalidateMode.always
                : AutovalidateMode.onUserInteraction,
            validator: (text) => numberError(text, target: false),
          ),
          SwitchListTile(
            key: const ValueKey('schedule-enabled'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.scheduleFieldEnabled),
            value: _enabled,
            onChanged: busy
                ? null
                : (value) => setState(() => _enabled = value),
          ),
          for (final warning in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MessageBanner(tone: MessageTone.warning, message: warning),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MessageBanner(
                message: failureMessage(l10n, error),
                detail: failureRequestIdLine(l10n, error),
              ),
            ),
          SizedBox(height: tokens.gap / 2),
          FilledButton(
            key: const ValueKey('schedule-save'),
            onPressed: busy ? null : _save,
            child: busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.scheduleSave),
          ),
          if (widget.onDelete != null) ...[
            SizedBox(height: tokens.gap / 2),
            OutlinedButton.icon(
              key: const ValueKey('schedule-delete'),
              onPressed: busy ? null : _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.scheduleDelete),
            ),
          ],
        ],
      ),
    );
  }
}

/// A read-only field showing `HH:mm` that opens the time picker.
class _TimeField extends StatelessWidget {
  const new({
    required this.label,
    required this.minutes,
    required this.onTap,
    super.key,
  });

  final String label;
  final int minutes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(labelText: label, enabled: onTap != null),
      child: Text(
        HeatingScheduleRules.formatMinutes(minutes),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
    ),
  );
}
