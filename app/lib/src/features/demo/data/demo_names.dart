/// The names demo mode shows in English.
///
/// `demo_core.json` is written in Polish; when the app speaks English the
/// demo's device, room, entity and schedule names follow, so the demo reads
/// as one language. Only the fixture's own names are translated: anything
/// the user types in the demo stays as typed.
const _english = <String, String>{
  'Kocioł': 'Boiler',
  'Oświetlenie kotłowni': 'Boiler-room light',
  'Pompa obiegowa': 'Circulation pump',
  'Temperatura': 'Temperature',
  'Temperatura powrotu': 'Return temperature',
  'Temperatura zasilania': 'Supply temperature',
  'Czujnik w salonie': 'Living-room sensor',
  'Grzanie': 'Heating',
  'Kotłownia': 'Boiler room',
  'Poranek': 'Morning',
  'Salon': 'Living room',
  'Sterownik kotłowni': 'Boiler-room controller',
  'Weekend': 'Weekend',
  'Wieczór': 'Evening',
  'Zasilanie': 'Power',
};

const _nameKeys = {'name', 'displayName'};

/// [body] with the demo fixture's names in [languageCode]; unchanged unless
/// it is `en`. Returns a copy and never changes [body].
Object? localizeDemoNames(Object? body, String languageCode) {
  if (languageCode != 'en') return body;
  return _translate(body);
}

Object? _translate(Object? node) {
  if (node is Map) {
    return {
      for (final entry in node.entries)
        entry.key: _nameKeys.contains(entry.key) && entry.value is String
            ? _english[entry.value] ?? entry.value
            : _translate(entry.value),
    };
  }
  if (node is List) return [for (final item in node) _translate(item)];
  return node;
}
