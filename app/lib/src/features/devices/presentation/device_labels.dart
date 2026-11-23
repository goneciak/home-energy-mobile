import 'dart:convert';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Effective connectivity; losing it is not a fault, local control keeps
/// working (plan §12.7).
StateLook connectivityLook(AppLocalizations l10n, ConnectivityState state) =>
    switch (state) {
      ConnectivityState.online => (
        label: l10n.connectivityOnline,
        icon: Icons.wifi,
        tone: StatusTone.good,
      ),
      ConnectivityState.stale => (
        label: l10n.connectivityStale,
        icon: Icons.wifi_2_bar,
        tone: StatusTone.warning,
      ),
      ConnectivityState.offline => (
        label: l10n.connectivityOffline,
        icon: Icons.wifi_off,
        tone: StatusTone.warning,
      ),
      ConnectivityState.provisioning => (
        label: l10n.connectivityProvisioning,
        icon: Icons.settings_suggest_outlined,
        tone: StatusTone.neutral,
      ),
      ConnectivityState.error => (
        label: l10n.connectivityError,
        icon: Icons.error_outline,
        tone: StatusTone.danger,
      ),
      ConnectivityState.unknown => (
        label: l10n.connectivityUnknown,
        icon: Icons.help_outline,
        tone: StatusTone.neutral,
      ),
    };

/// Product status of `GET /devices/:id` (lowercase vocabulary).
/// [benign] marks `needs_configuration` that only lists GI Edge's own
/// diagnostics entities (see `needsRealConfiguration`): a hint, not a warning.
StateLook productStatusLook(
  AppLocalizations l10n,
  ProductStatus status, {
  bool benign = false,
}) => switch (status) {
  ProductStatus.online => (
    label: l10n.productStatusOnline,
    icon: Icons.check_circle_outline,
    tone: StatusTone.good,
  ),
  ProductStatus.offline => (
    label: l10n.productStatusOffline,
    icon: Icons.cloud_off_outlined,
    tone: StatusTone.warning,
  ),
  ProductStatus.connecting => (
    label: l10n.productStatusConnecting,
    icon: Icons.sync,
    tone: StatusTone.neutral,
  ),
  ProductStatus.needsConfiguration => (
    label: l10n.productStatusNeedsConfiguration,
    icon: Icons.tune,
    tone: benign ? StatusTone.neutral : StatusTone.warning,
  ),
  ProductStatus.error => (
    label: l10n.productStatusError,
    icon: Icons.error_outline,
    tone: StatusTone.danger,
  ),
  ProductStatus.unknown => (
    label: l10n.productStatusUnknown,
    icon: Icons.help_outline,
    tone: StatusTone.neutral,
  ),
};

/// Controller state machine state reported by GI Edge.
StateLook firmwareStateLook(AppLocalizations l10n, FirmwareState state) {
  final label = switch (state) {
    FirmwareState.boot => l10n.firmwareStateBoot,
    FirmwareState.selfTest => l10n.firmwareStateSelfTest,
    FirmwareState.ready => l10n.firmwareStateReady,
    FirmwareState.idle => l10n.firmwareStateIdle,
    FirmwareState.heatingRequested => l10n.firmwareStateHeatingRequested,
    FirmwareState.heatingVerifying => l10n.firmwareStateHeatingVerifying,
    FirmwareState.heating => l10n.firmwareStateHeating,
    FirmwareState.stopping => l10n.firmwareStateStopping,
    FirmwareState.fault => l10n.firmwareStateFault,
    FirmwareState.safeMode => l10n.firmwareStateSafeMode,
    FirmwareState.unknown => l10n.firmwareStateUnknown,
  };
  return switch (state) {
    FirmwareState.fault || FirmwareState.safeMode => (
      label: label,
      icon: Icons.report_outlined,
      tone: StatusTone.danger,
    ),
    FirmwareState.heating => (
      label: label,
      icon: Icons.local_fire_department,
      tone: StatusTone.info,
    ),
    FirmwareState.unknown => (
      label: label,
      icon: Icons.help_outline,
      tone: StatusTone.neutral,
    ),
    _ => (label: label, icon: Icons.memory, tone: StatusTone.good),
  };
}

/// Icon of a device: a flame for heating devices, otherwise by type.
IconData deviceIcon({required DeviceType type, required bool isHeating}) {
  if (isHeating) return Icons.local_fire_department;
  return switch (type) {
    DeviceType.esp32 || DeviceType.esp8266 => Icons.memory,
    DeviceType.homeAssistant => Icons.home_work_outlined,
    DeviceType.gateway => Icons.router_outlined,
    DeviceType.virtual => Icons.cloud_outlined,
    DeviceType.generic || DeviceType.unknown => Icons.devices_other,
  };
}

String entityDomainLabel(AppLocalizations l10n, EntityDomain domain) =>
    switch (domain) {
      EntityDomain.sensor => l10n.entityDomainSensor,
      EntityDomain.switch_ => l10n.entityDomainSwitch,
      EntityDomain.binarySensor => l10n.entityDomainBinarySensor,
      EntityDomain.number => l10n.entityDomainNumber,
      EntityDomain.select => l10n.entityDomainSelect,
      EntityDomain.climate => l10n.entityDomainClimate,
      EntityDomain.textSensor => l10n.entityDomainTextSensor,
      EntityDomain.button => l10n.entityDomainButton,
      EntityDomain.unknown => l10n.entityDomainUnknown,
    };

/// "Ostatnio widziane 5 min temu", or "Jeszcze nie połączone".
String lastSeenLabel(
  AppLocalizations l10n,
  DateTime? lastSeenAt,
  DateTime now,
) => lastSeenAt == null
    ? l10n.lastSeenNever
    : l10n.lastSeen(formatRelativeTime(l10n, lastSeenAt, now));

/// An entity value as text, whatever JSON type it has (plan §6.4): numbers
/// in the app locale with the unit, booleans as on/off, objects and arrays
/// as compact JSON. Temperatures ([isTemperature]) always have exactly one
/// decimal ("21,0 °C", plan §13.3); other numbers at most two.
String formatEntityValue(
  AppLocalizations l10n,
  EntityValue value, {
  String? unit,
  String? deviceClass,
}) {
  String withUnit(String text) =>
      unit == null || unit.trim().isEmpty ? text : '$text ${unit.trim()}';
  return switch (value) {
    EntityValueNone() => l10n.commonNoDataValue,
    EntityValueBoolean(:final value) =>
      value ? l10n.entityValueOn : l10n.entityValueOff,
    EntityValueNumber(:final value)
        when isTemperature(unit: unit, deviceClass: deviceClass) =>
      withUnit(formatTemperature(l10n, value)),
    EntityValueNumber(:final value) => withUnit(formatNumber(l10n, value)),
    EntityValueText(:final value) =>
      value.trim().isEmpty ? l10n.commonNoDataValue : withUnit(value.trim()),
    EntityValueStructured(:final value) => _compactJson(value),
  };
}

/// Whether a reading in [unit] of a [deviceClass] entity is a temperature:
/// degrees Celsius, or an entity of the `temperature` device class.
bool isTemperature({String? unit, String? deviceClass}) {
  final normalized = unit?.trim().replaceAll(' ', '');
  return normalized == '°C' ||
      // U+2103 DEGREE CELSIUS, one character.
      normalized == '℃' ||
      deviceClass?.trim().toLowerCase() == 'temperature';
}

/// [value] in the app locale with at most two decimals ("21,5").
String formatNumber(AppLocalizations l10n, num value) {
  final format = NumberFormat.decimalPattern(l10n.localeName)
    ..maximumFractionDigits = 2;
  return format.format(value);
}

/// A temperature in the app locale with exactly one decimal: "21,0" in
/// Polish, "21.0" in English (plan §13.3).
String formatTemperature(AppLocalizations l10n, num value) {
  final format = NumberFormat.decimalPattern(l10n.localeName)
    ..minimumFractionDigits = 1
    ..maximumFractionDigits = 1;
  return format.format(value);
}

/// "1 d 2 godz." or "2 godz. 5 min".
String formatDuration(AppLocalizations l10n, Duration duration) =>
    duration.inDays > 0
    ? l10n.durationDaysHours(duration.inDays, duration.inHours % 24)
    : l10n.durationHoursMinutes(duration.inHours, duration.inMinutes % 60);

String _compactJson(Object value) {
  const maxLength = 80;
  // [value] was decoded from JSON, so it always encodes back.
  final text = jsonEncode(value);
  return text.length <= maxLength
      ? text
      : '${text.substring(0, maxLength - 1)}…';
}
