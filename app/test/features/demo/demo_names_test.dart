import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/demo/data/demo_names.dart';

void main() {
  final body = [
    {
      'name': 'Kotłownia',
      'displayName': 'Temperatura zasilania',
      'note': 'Salon',
      'rooms': [
        {'name': 'Salon'},
        {'name': 'Mój pokój'},
      ],
      'count': 3,
    },
  ];

  test('Polish and unknown languages leave the body as it is', () {
    expect(localizeDemoNames(body, 'pl'), same(body));
    expect(localizeDemoNames(body, 'de'), same(body));
  });

  test('English translates the fixture names, nested and in lists', () {
    expect(localizeDemoNames(body, 'en'), [
      {
        'name': 'Boiler room',
        'displayName': 'Supply temperature',
        'note': 'Salon',
        'rooms': [
          {'name': 'Living room'},
          {'name': 'Mój pokój'},
        ],
        'count': 3,
      },
    ]);
  });

  test('English does not change the original body', () {
    localizeDemoNames(body, 'en');
    expect((body.first['rooms']! as List).first, {'name': 'Salon'});
  });

  test('scalars and null pass through', () {
    expect(localizeDemoNames(null, 'en'), isNull);
    expect(localizeDemoNames('Salon', 'en'), 'Salon');
  });
}
