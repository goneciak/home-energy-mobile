/// One glyph of the weather icon set, ported from the web panel's
/// `weather-icons.ts` (one emoji there, one icon and label here).
enum WeatherGlyph {
  /// ☀️ clear sky (day or polar twilight).
  clearSky,

  /// 🌤️ fair.
  fair,

  /// ⛅ partly cloudy.
  partlyCloudy,

  /// ☁️ cloudy (and partly cloudy at night).
  cloudy,

  /// 🌫️ fog.
  fog,

  /// 🌦️ light rain or rain showers.
  showers,

  /// 🌧️ rain or heavy showers.
  rain,

  /// ⛈️ anything with thunder.
  thunder,

  /// 🌨️ sleet, snow showers, light snow.
  sleetOrSnowShowers,

  /// ❄️ snow, heavy snow.
  snow,

  /// 🌙 clear or fair at night.
  clearNight,

  /// 🌡️ a code the app does not know.
  unknown,
}

const Map<String, WeatherGlyph> _baseGlyphs = {
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

/// Only a `_night` suffix changes the glyph; `_polartwilight` keeps the
/// day one.
const Map<String, WeatherGlyph> _nightGlyphs = {
  'clearsky': WeatherGlyph.clearNight,
  'fair': WeatherGlyph.clearNight,
  'partlycloudy': WeatherGlyph.cloudy,
};

/// Every met.no base symbol name the appliance returns.
Iterable<String> get weatherBaseSymbols => _baseGlyphs.keys;

final _suffix = RegExp(r'_(day|night|polartwilight)$');

/// The glyph of met.no [symbolCode] (e.g. `partlycloudy_night`), or `null`
/// when there is no code, which the screens show as "—". An unknown code
/// gets [WeatherGlyph.unknown].
WeatherGlyph? weatherGlyphOf(String? symbolCode) {
  if (symbolCode == null || symbolCode.isEmpty) return null;
  final base = symbolCode.replaceFirst(_suffix, '');
  if (symbolCode.endsWith('_night')) {
    final night = _nightGlyphs[base];
    if (night != null) return night;
  }
  return _baseGlyphs[base] ?? WeatherGlyph.unknown;
}
