import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/devices/domain/controller_status.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/home/domain/heating_readings.dart';
import 'package:gi_home/src/features/home/presentation/widgets/heating_strategy_section.dart';
import 'package:material_ui/material_ui.dart';

/// Read-only heating card on Home (plan §4.1, §11, M1): the device of the
/// list with its safety cues (suspended heating, dry-run, controller state
/// and faults merged from the list and the details), the boiler and pump
/// relay states and the control temperature from `GET /devices/:id`, and
/// how fresh those details are. Tapping opens the device details.
///
/// Below the readings, [HeatingStrategySection] shows the effective and
/// default control settings, a PV boost, the suspension with its next
/// action, dry-run and a latched fault (plan §12.5, M2 item 3).
class HeatingCard extends StatelessWidget {
  const new({
    required this.device,
    required this.listFetchedAt,
    required this.detail,
    required this.roomName,
    required this.now,
    required this.onTap,
    this.permission = viewOnly,
    this.onResume,
    this.commandStatus,
    super.key,
  });

  /// No heating control at all (role unknown, USER, SERVICE).
  static const viewOnly = HeatingPermission(
    canSwitch: false,
    canSuspend: false,
    canEditStrategy: false,
  );

  /// The device as listed; heating, suspension and dry-run come from here.
  final DeviceListItem device;

  /// When the list carrying [device] arrived.
  final DateTime listFetchedAt;

  final PolledData<DeviceDetail> detail;

  /// `null` when the device has no (known) room.
  final String? roomName;

  final DateTime now;
  final VoidCallback onTap;

  /// What the signed-in user may do with heating (plan §12.8).
  final HeatingPermission permission;

  /// Resumes suspended heating; see [HeatingStrategySection.onResume].
  final VoidCallback? onResume;

  /// The outcome of a suspend/resume started from the card, shown last.
  final Widget? commandStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final connectivity = connectivityLook(l10n, device.connectivityState);
    final fetched = detail.data;
    final status = ControllerStatus.resolve(
      listItem: Fetched(device, listFetchedAt),
      detail: fetched,
    );
    final state = status.currentState?.value;
    final faults = status.activeFaultCount?.value ?? 0;
    final needsConfiguration =
        fetched?.value.status == ProductStatus.needsConfiguration;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
        side: BorderSide(color: tokens.ember.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_fire_department, color: tokens.ember),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.name, style: textTheme.titleMedium),
                        Text(
                          l10n.heatingCardSubtitle(roomName ?? l10n.homeNoRoom),
                          style: textTheme.labelMedium?.copyWith(
                            color: tokens.ember,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastSeenLabel(l10n, device.lastSeenAt, now),
                          style: textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: tokens.textMuted),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusChip(
                    label: connectivity.label,
                    icon: connectivity.icon,
                    tone: connectivity.tone,
                  ),
                  if (device.heatingSuspended)
                    StatusChip(
                      key: const ValueKey('heating-suspended'),
                      label: l10n.badgeHeatingSuspended,
                      icon: Icons.pause_circle_outline,
                      tone: StatusTone.warning,
                    ),
                  if (device.dryRun)
                    StatusChip(
                      key: const ValueKey('dry-run'),
                      label: l10n.badgeDryRun,
                      icon: Icons.science_outlined,
                      tone: StatusTone.warning,
                    ),
                  if (state == null)
                    StatusChip(
                      label: l10n.heatingCardControllerUnknown,
                      icon: Icons.memory,
                    )
                  else
                    _stateChip(firmwareStateLook(l10n, state)),
                  if (faults > 0)
                    StatusChip(
                      label: l10n.faultsCount(faults),
                      icon: Icons.warning_amber_rounded,
                      tone: StatusTone.danger,
                    ),
                  if (needsConfiguration)
                    _stateChip(
                      productStatusLook(l10n, ProductStatus.needsConfiguration),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _Readings(detail: detail, now: now),
              if (fetched != null) ...[
                const SizedBox(height: 8),
                HeatingStrategySection(
                  detail: fetched,
                  permission: permission,
                  faultLatched: state?.isCritical ?? false,
                  now: now,
                  onResume: onResume,
                ),
              ],
              if (commandStatus case final status?) ...[
                const SizedBox(height: 8),
                status,
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _stateChip(StateLook look) =>
      StatusChip(label: look.label, icon: look.icon, tone: look.tone);
}

class _Readings extends StatelessWidget {
  const new({required this.detail, required this.now});

  final PolledData<DeviceDetail> detail;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final fetched = detail.data;
    final muted = textTheme.bodySmall?.copyWith(color: tokens.textMuted);

    final freshness = _freshness(l10n, fetched);
    final notice = freshness == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  detail.error != null
                      ? Icons.sync_problem
                      : Icons.history_toggle_off,
                  size: 16,
                  color: tokens.warning,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(freshness, style: textTheme.bodySmall)),
              ],
            ),
          );

    if (fetched == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notice == null)
            Text(l10n.heatingCardLoading, style: muted)
          else
            notice,
        ],
      );
    }

    final readings = HeatingReadings.of(fetched.value);
    final pump = readings.pumpRelay;
    final temperature = readings.controlTemperature;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReadingRow(
          key: const ValueKey('reading-boiler'),
          icon: _relayIcon(readings.boilerRelay),
          label: l10n.heatingCardBoiler,
          value: _relayText(
            l10n,
            readings.boilerRelay,
            on: l10n.heatingCardBoilerOn,
            off: l10n.heatingCardBoilerOff,
          ),
        ),
        if (pump != null)
          _ReadingRow(
            key: const ValueKey('reading-pump'),
            icon: _relayIcon(pump),
            label: l10n.heatingCardPump,
            value: _relayText(
              l10n,
              pump,
              on: l10n.heatingCardPumpOn,
              off: l10n.heatingCardPumpOff,
            ),
          ),
        if (temperature != null)
          _ReadingRow(
            key: const ValueKey('reading-temperature'),
            icon: Icons.thermostat,
            label: l10n.entityRoleControlTemperature,
            value: _temperatureText(l10n, temperature),
            monospace: temperature.status == ReadingStatus.ok,
          ),
        Text(l10n.heatingCardRelayNote, style: muted),
        ?notice,
      ],
    );
  }

  /// "Dane z 07:41" once the details are older than twice the polling
  /// interval; the failure (with the time of the details shown) when the
  /// latest request failed.
  String? _freshness(AppLocalizations l10n, Fetched<DeviceDetail>? fetched) {
    if (fetched == null) {
      return detail.error == null ? null : l10n.heatingCardFailed;
    }
    final time = formatClockTime(l10n, fetched.fetchedAt, now);
    if (detail.error != null) return l10n.heatingCardFailedSince(time);
    return FreshnessPolicy.heatingCard.isStale(fetched.fetchedAt, now)
        ? l10n.heatingCardDataFrom(time)
        : null;
  }

  static IconData _relayIcon(RelayState state) => switch (state) {
    RelayState.on => Icons.power,
    RelayState.off => Icons.power_off,
    RelayState.noData => Icons.help_outline,
    RelayState.unavailable => Icons.block,
  };

  static String _relayText(
    AppLocalizations l10n,
    RelayState state, {
    required String on,
    required String off,
  }) => switch (state) {
    RelayState.on => on,
    RelayState.off => off,
    RelayState.noData => l10n.commonNoDataValue,
    RelayState.unavailable => l10n.entityUnavailable,
  };

  static String _temperatureText(
    AppLocalizations l10n,
    TemperatureReading reading,
  ) => switch (reading.status) {
    ReadingStatus.ok => _withUnit(
      formatTemperature(l10n, reading.value!),
      reading.unit,
    ),
    ReadingStatus.noData => l10n.commonNoDataValue,
    ReadingStatus.unavailable => l10n.entityUnavailable,
  };

  static String _withUnit(String text, String? unit) =>
      unit == null ? text : '$text $unit';
}

class _ReadingRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.value,
    this.monospace = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Sets a reading in JetBrains Mono with tabular figures.
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final missing = value == l10n.commonNoDataValue;
    final valueStyle = textTheme.titleSmall?.copyWith(color: tokens.text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: tokens.textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Text(
            value,
            // "—" alone reads as nothing to a screen reader (plan §13.3).
            semanticsLabel: missing ? l10n.commonNoData : null,
            style: monospace ? GiFonts.monospace(valueStyle) : valueStyle,
          ),
        ],
      ),
    );
  }
}
