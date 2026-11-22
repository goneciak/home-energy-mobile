import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/environment/domain/weather_icons.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The icon of [glyph] (the web panel uses emoji; the app keeps to its
/// icon font so every glyph renders the same on every phone).
IconData weatherGlyphIcon(WeatherGlyph glyph) => switch (glyph) {
  WeatherGlyph.clearSky => Icons.wb_sunny_outlined,
  WeatherGlyph.fair => Icons.wb_twilight,
  WeatherGlyph.partlyCloudy => Icons.wb_cloudy_outlined,
  WeatherGlyph.cloudy => Icons.cloud_outlined,
  WeatherGlyph.fog => Icons.foggy,
  WeatherGlyph.showers => Icons.grain,
  WeatherGlyph.rain => Icons.umbrella_outlined,
  WeatherGlyph.thunder => Icons.thunderstorm_outlined,
  WeatherGlyph.sleetOrSnowShowers => Icons.cloudy_snowing,
  WeatherGlyph.snow => Icons.ac_unit,
  WeatherGlyph.clearNight => Icons.nightlight_outlined,
  WeatherGlyph.unknown => Icons.thermostat,
};

/// What [glyph] means, for the screen and screen readers.
String weatherGlyphLabel(AppLocalizations l10n, WeatherGlyph glyph) =>
    switch (glyph) {
      WeatherGlyph.clearSky => l10n.weatherGlyphClearSky,
      WeatherGlyph.fair => l10n.weatherGlyphFair,
      WeatherGlyph.partlyCloudy => l10n.weatherGlyphPartlyCloudy,
      WeatherGlyph.cloudy => l10n.weatherGlyphCloudy,
      WeatherGlyph.fog => l10n.weatherGlyphFog,
      WeatherGlyph.showers => l10n.weatherGlyphShowers,
      WeatherGlyph.rain => l10n.weatherGlyphRain,
      WeatherGlyph.thunder => l10n.weatherGlyphThunder,
      WeatherGlyph.sleetOrSnowShowers => l10n.weatherGlyphSleetOrSnowShowers,
      WeatherGlyph.snow => l10n.weatherGlyphSnow,
      WeatherGlyph.clearNight => l10n.weatherGlyphClearNight,
      WeatherGlyph.unknown => l10n.weatherGlyphUnknown,
    };

/// The condition text of met.no [symbolCode]; "Brak danych" without one.
String weatherConditionLabel(AppLocalizations l10n, String? symbolCode) =>
    switch (weatherGlyphOf(symbolCode)) {
      null => l10n.commonNoData,
      final glyph => weatherGlyphLabel(l10n, glyph),
    };

/// The icon of met.no [symbolCode], or "—" when there is none. The label
/// is carried by the surrounding semantics, so the icon itself is silent.
class WeatherSymbol extends StatelessWidget {
  const new(this.symbolCode, {super.key, this.size = 24, this.color});

  final String? symbolCode;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final glyph = weatherGlyphOf(symbolCode);
    if (glyph == null) {
      return ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: Text(context.l10n.commonNoDataValue)),
        ),
      );
    }
    return Icon(weatherGlyphIcon(glyph), size: size, color: color);
  }
}

/// "3,5 °C", or "—" without a value.
String weatherTemperatureText(AppLocalizations l10n, double? value) =>
    value == null
    ? l10n.commonNoDataValue
    : l10n.weatherTemperature(formatTemperature(l10n, value));

/// [instant] as the wall time of [zone]: a UTC-flagged [DateTime] whose
/// fields are that zone's wall clock. Format it as it is, never `toLocal()`.
DateTime houseWallTime(DateTime instant, ScheduleZone zone) {
  final utc = instant.toUtc();
  return utc.add(zone.offsetAt(utc));
}

/// "07:41" of [instant] in [zone].
String formatHouseClock(
  AppLocalizations l10n,
  DateTime instant,
  ScheduleZone zone,
) => DateFormat.Hm(l10n.localeName).format(houseWallTime(instant, zone));

/// "13:00" of a house-local wall time, shown as it comes.
String formatWallClock(AppLocalizations l10n, LocalWallTime time) =>
    DateFormat.Hm(l10n.localeName).format(
      DateTime.utc(time.year, time.month, time.day, time.hour, time.minute),
    );

/// "pon., 23 lis" of a calendar day.
String formatWallDay(AppLocalizations l10n, LocalWallTime day) =>
    DateFormat.MMMEd(l10n.localeName)
        .format(DateTime.utc(day.year, day.month, day.day));

/// The note under the weather hours: which zone they are shown in.
String weatherZoneNote(AppLocalizations l10n, ScheduleZone zone) =>
    switch (zone.name) {
      final name? => l10n.weatherTimesHouseZone(name),
      null => l10n.weatherTimesPhoneZone,
    };

/// The PV control mode as a phrase ("tylko prognoza").
String pvModeLabel(AppLocalizations l10n, PvControlMode mode) => switch (mode) {
  PvControlMode.forecastOnly => l10n.pvModeForecastOnly,
  PvControlMode.liveInverterOnly => l10n.pvModeLiveInverterOnly,
  PvControlMode.hybrid => l10n.pvModeHybrid,
  PvControlMode.disabled => l10n.pvPlanDisabled,
  PvControlMode.unknown => l10n.pvModeUnknown,
};
