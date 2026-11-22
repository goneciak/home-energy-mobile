import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/environment/domain/weather_icons.dart';
import 'package:gi_home/src/features/environment/presentation/environment_labels.dart';
import 'package:material_ui/material_ui.dart';

/// The port of the web panel's `weather-icons.ts`: every base name, the
/// three suffixes, the night overrides, unknown codes and no code.
void main() {
  // Base name → glyph, one row per emoji of BASE_ICONS.
  const table = <String, WeatherGlyph>{
    'clearsky': WeatherGlyph.clearSky,
    'fair': WeatherGlyph.fair,
    'partlycloudy': WeatherGlyph.partlyCloudy,
    'cloudy': WeatherGlyph.cloudy,
    'fog': WeatherGlyph.fog,
    'rainshowers': WeatherGlyph.showers,
    'lightrainshowers': WeatherGlyph.showers,
    'heavyrainshowers': WeatherGlyph.rain,
    'rainshowersandthunder': WeatherGlyph.thunder,
    'lightrainshowersandthunder': WeatherGlyph.thunder,
    'heavyrainshowersandthunder': WeatherGlyph.thunder,
    'sleetshowers': WeatherGlyph.sleetOrSnowShowers,
    'lightsleetshowers': WeatherGlyph.sleetOrSnowShowers,
    'heavysleetshowers': WeatherGlyph.sleetOrSnowShowers,
    'sleetshowersandthunder': WeatherGlyph.thunder,
    'lightsleetshowersandthunder': WeatherGlyph.thunder,
    'heavysleetshowersandthunder': WeatherGlyph.thunder,
    'snowshowers': WeatherGlyph.sleetOrSnowShowers,
    'lightsnowshowers': WeatherGlyph.sleetOrSnowShowers,
    'heavysnowshowers': WeatherGlyph.sleetOrSnowShowers,
    'snowshowersandthunder': WeatherGlyph.thunder,
    'lightsnowshowersandthunder': WeatherGlyph.thunder,
    'heavysnowshowersandthunder': WeatherGlyph.thunder,
    'rain': WeatherGlyph.rain,
    'lightrain': WeatherGlyph.showers,
    'heavyrain': WeatherGlyph.rain,
    'rainandthunder': WeatherGlyph.thunder,
    'lightrainandthunder': WeatherGlyph.thunder,
    'heavyrainandthunder': WeatherGlyph.thunder,
    'sleet': WeatherGlyph.sleetOrSnowShowers,
    'lightsleet': WeatherGlyph.sleetOrSnowShowers,
    'heavysleet': WeatherGlyph.sleetOrSnowShowers,
    'sleetandthunder': WeatherGlyph.thunder,
    'lightsleetandthunder': WeatherGlyph.thunder,
    'heavysleetandthunder': WeatherGlyph.thunder,
    'snow': WeatherGlyph.snow,
    'lightsnow': WeatherGlyph.sleetOrSnowShowers,
    'heavysnow': WeatherGlyph.snow,
    'snowandthunder': WeatherGlyph.thunder,
    'lightsnowandthunder': WeatherGlyph.thunder,
    'heavysnowandthunder': WeatherGlyph.thunder,
  };
  const nightOverrides = <String, WeatherGlyph>{
    'clearsky': WeatherGlyph.clearNight,
    'fair': WeatherGlyph.clearNight,
    'partlycloudy': WeatherGlyph.cloudy,
  };

  test('the table covers every base name the mapper knows', () {
    expect(table.keys, unorderedEquals(weatherBaseSymbols));
    expect(table, hasLength(41));
  });

  for (final MapEntry(key: base, value: glyph) in table.entries) {
    test('$base and its suffixes', () {
      expect(weatherGlyphOf(base), glyph);
      expect(weatherGlyphOf('${base}_day'), glyph);
      expect(weatherGlyphOf('${base}_polartwilight'), glyph, reason: 'day');
      expect(weatherGlyphOf('${base}_night'), nightOverrides[base] ?? glyph);
    });
  }

  test('only _night overrides the glyph, polar twilight keeps the day', () {
    expect(weatherGlyphOf('clearsky_night'), WeatherGlyph.clearNight);
    expect(weatherGlyphOf('fair_night'), WeatherGlyph.clearNight);
    expect(weatherGlyphOf('partlycloudy_night'), WeatherGlyph.cloudy);
    expect(weatherGlyphOf('clearsky_polartwilight'), WeatherGlyph.clearSky);
    expect(weatherGlyphOf('rain_night'), WeatherGlyph.rain);
  });

  test('an unknown code is the thermometer, no code is "—"', () {
    expect(weatherGlyphOf('hail'), WeatherGlyph.unknown);
    expect(weatherGlyphOf('hail_night'), WeatherGlyph.unknown);
    expect(weatherGlyphIcon(WeatherGlyph.unknown), Icons.thermostat);
    expect(weatherGlyphOf(null), isNull);
    expect(weatherGlyphOf(''), isNull);
  });

  test('every glyph has its own icon and a Polish and English label', () {
    final pl = lookupAppLocalizations(const Locale('pl'));
    final en = lookupAppLocalizations(const Locale('en'));
    final icons = WeatherGlyph.values.map(weatherGlyphIcon).toSet();
    expect(icons, hasLength(WeatherGlyph.values.length));
    for (final glyph in WeatherGlyph.values) {
      expect(weatherGlyphLabel(pl, glyph), isNotEmpty);
      expect(weatherGlyphLabel(en, glyph), isNot(weatherGlyphLabel(pl, glyph)));
    }
    expect(weatherConditionLabel(pl, null), pl.commonNoData);
  });
}
