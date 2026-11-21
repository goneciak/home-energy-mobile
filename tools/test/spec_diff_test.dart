import 'dart:convert';
import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_tools/spec_diff.dart';
import 'package:test/test.dart';

/// Two catalog-shaped endpoints are enough for the rules; the specs below are
/// hand-made, the network is never used.
const _login = Endpoint(
  id: 'AuthController_login',
  method: HttpMethod.post,
  path: '/auth/login',
  roles: {},
  timeout: TimeoutClass.write,
  milestone: Milestone.m1,
  feature: 'auth',
);

const _device = Endpoint(
  id: 'DevicesController_get',
  method: HttpMethod.get,
  path: '/devices/{id}',
  roles: {UserRole.owner},
  timeout: TimeoutClass.read,
  milestone: Milestone.m1,
  feature: 'device',
);

const List<Endpoint> _endpoints = [_login, _device];

/// The client requires `$.id` and `$.name` of a device and reads `$.model`.
const _deviceShape = ClientShape(
  requiredFields: {r'$.id', r'$.name'},
  decodedFields: {r'$.id', r'$.name', r'$.model'},
);

Map<String, Object?> _spec({
  Map<String, Object?>? loginBody,
  Map<String, Object?>? device,
  List<Map<String, Object?>> deviceParameters = const [],
  bool withLogin = true,
  Map<String, Object?> extraPaths = const {},
}) => {
  'openapi': '3.0.0',
  'paths': {
    if (withLogin)
      '/api/v1/auth/login': {
        'post': {
          'operationId': 'AuthController_login',
          'requestBody': {
            'required': true,
            'content': {
              'application/json': {
                'schema': {r'$ref': '#/components/schemas/LoginDto'},
              },
            },
          },
          'responses': {
            '200': {'description': 'ok'},
          },
        },
      },
    '/api/v1/devices/{deviceId}': {
      'get': {
        'operationId': 'DevicesController_get',
        'parameters': [
          {'name': 'deviceId', 'in': 'path', 'required': true},
          ...deviceParameters,
        ],
        'responses': {
          '200': {
            'description': 'ok',
            'content': {
              'application/json': {
                'schema': {r'$ref': '#/components/schemas/DeviceDto'},
              },
            },
          },
        },
      },
    },
    ...extraPaths,
  },
  'components': {
    'schemas': {
      'LoginDto':
          loginBody ??
          {
            'type': 'object',
            'required': ['email', 'password'],
            'properties': {
              'email': {'type': 'string'},
              'password': {'type': 'string'},
            },
          },
      'DeviceDto':
          device ??
          {
            'type': 'object',
            'required': ['id', 'name'],
            'properties': {
              'id': {'type': 'string'},
              'name': {'type': 'string'},
              'model': {'type': 'string', 'nullable': true},
              'notes': {'type': 'string'},
            },
          },
    },
  },
};

SpecDiffReport _diff(Map<String, Object?> live) => diffSpecs(
  snapshot: _spec(),
  live: live,
  endpoints: _endpoints,
  clientShapes: {_device.id: _deviceShape},
);

List<String> _kinds(Iterable<SpecFinding> findings) => [
  for (final f in findings) f.kind,
];

Map<String, Object?> _deviceSchema(
  Map<String, Object?> properties, {
  List<String> required = const ['id', 'name'],
}) => {'type': 'object', 'required': required, 'properties': properties};

void main() {
  group('diffSpecs', () {
    test('identical specs: no findings, exit 0', () {
      final report = _diff(_spec());

      expect(report.findings, isEmpty);
      expect(report.exitCode, 0);
      expect(report.checkedEndpoints, 2);
    });

    test('path placeholders compare by position, not by name', () {
      final live = _spec();
      final paths = live['paths']! as Map<String, Object?>;
      paths['/api/v1/devices/{id}'] = paths.remove(
        '/api/v1/devices/{deviceId}',
      );

      expect(_diff(live).findings, isEmpty);
    });

    test('a removed catalog endpoint is an error', () {
      final report = _diff(_spec(withLogin: false));

      expect(_kinds(report.errors), ['endpoint-removed']);
      expect(report.errors.single.endpointId, 'AuthController_login');
      expect(report.exitCode, 1);
    });

    test('a new required request field is an error', () {
      final report = _diff(
        _spec(
          loginBody: {
            'type': 'object',
            'required': ['email', 'password', 'otp'],
            'properties': {
              'email': {'type': 'string'},
              'password': {'type': 'string'},
              'otp': {'type': 'string'},
            },
          },
        ),
      );

      expect(_kinds(report.errors), ['request-field-required']);
      expect(report.errors.single.field, r'$.otp');
      expect(report.exitCode, 1);
    });

    test('a new optional request field is a warning', () {
      final report = _diff(
        _spec(
          loginBody: {
            'type': 'object',
            'required': ['email', 'password'],
            'properties': {
              'email': {'type': 'string'},
              'password': {'type': 'string'},
              'rememberMe': {'type': 'boolean'},
            },
          },
        ),
      );

      expect(report.errors, isEmpty);
      expect(_kinds(report.warnings), ['request-field-added']);
      expect(report.exitCode, 0);
    });

    test('a new required query parameter is an error', () {
      final report = _diff(
        _spec(
          deviceParameters: [
            {'name': 'view', 'in': 'query', 'required': true},
          ],
        ),
      );

      expect(_kinds(report.errors), ['parameter-required']);
      expect(report.errors.single.field, 'query:view');
    });

    test('removing a response field the client requires is an error', () {
      final report = _diff(
        _spec(
          device: _deviceSchema(
            {
              'id': {'type': 'string'},
              'model': {'type': 'string'},
              'notes': {'type': 'string'},
            },
            required: ['id'],
          ),
        ),
      );

      expect(_kinds(report.errors), ['response-field-removed']);
      expect(report.errors.single.field, r'$.name');
    });

    test('removing a response field the client ignores is a warning', () {
      final report = _diff(
        _spec(
          device: _deviceSchema({
            'id': {'type': 'string'},
            'name': {'type': 'string'},
            'model': {'type': 'string', 'nullable': true},
          }),
        ),
      );

      expect(report.errors, isEmpty);
      expect(_kinds(report.warnings), ['response-field-removed']);
      expect(report.warnings.single.field, r'$.notes');
    });

    test('retyping a response field the client decodes is an error', () {
      final report = _diff(
        _spec(
          device: _deviceSchema({
            'id': {'type': 'integer'},
            'name': {'type': 'string'},
            'model': {'type': 'string', 'nullable': true},
            'notes': {'type': 'string'},
          }),
        ),
      );

      expect(_kinds(report.errors), ['response-field-type-changed']);
      expect(report.errors.single.field, r'$.id');
    });

    test('retyping a field the client does not read is a warning', () {
      final report = _diff(
        _spec(
          device: _deviceSchema({
            'id': {'type': 'string'},
            'name': {'type': 'string'},
            'model': {'type': 'string', 'nullable': true},
            'notes': {'type': 'number'},
          }),
        ),
      );

      expect(report.errors, isEmpty);
      expect(_kinds(report.warnings), ['response-field-type-changed']);
    });

    test('added response fields and new endpoints are warnings', () {
      final report = _diff(
        _spec(
          device: _deviceSchema({
            'id': {'type': 'string'},
            'name': {'type': 'string'},
            'model': {'type': 'string', 'nullable': true},
            'notes': {'type': 'string'},
            'firmware': {
              'type': 'object',
              'properties': {
                'version': {'type': 'string'},
              },
            },
          }),
          extraPaths: {
            '/api/v1/devices/{id}/history': {
              'get': {
                'operationId': 'DevicesController_history',
                'responses': {
                  '200': {'description': 'ok'},
                },
              },
            },
          },
        ),
      );

      expect(report.errors, isEmpty);
      expect(
        _kinds(report.warnings),
        unorderedEquals(['response-field-added', 'endpoint-added']),
      );
      // Only the top of a new subtree is reported.
      expect(
        report.warnings
            .firstWhere((f) => f.kind == 'response-field-added')
            .field,
        r'$.firmware',
      );
      expect(report.exitCode, 0);
    });

    test('operations outside the catalog are ignored apart from additions', () {
      final snapshot = _spec(
        extraPaths: {
          '/api/v1/rooms': {
            'get': {
              'operationId': 'RoomsController_list',
              'responses': {
                '200': {'description': 'ok'},
              },
            },
          },
        },
      );

      final report = diffSpecs(
        snapshot: snapshot,
        live: _spec(),
        endpoints: _endpoints,
        clientShapes: {_device.id: _deviceShape},
      );

      expect(report.findings, isEmpty);
    });
  });

  group('report output', () {
    test('human-readable text lists errors and the verdict', () {
      final text = _diff(_spec(withLogin: false))
          .format(live: 'live.json', snapshot: 'snapshot.json');

      expect(text, contains('spec_diff: live.json vs snapshot.json'));
      expect(text, contains('Errors: 1.'));
      expect(text, contains('[endpoint-removed] AuthController_login'));
      expect(text, isNot(contains('OK: no breaking change')));
    });

    test('JSON output is machine-readable', () {
      final json = _diff(_spec(withLogin: false))
          .toJson(live: 'l', snapshot: 's');

      final decoded = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
      expect(decoded['errors'], 1);
      expect(decoded['warnings'], 0);
      expect((decoded['findings'] as List).single, {
        'severity': 'error',
        'kind': 'endpoint-removed',
        'endpointId': 'AuthController_login',
        'operation': 'POST /api/v1/auth/login',
        'message': 'the catalog operation is missing from the live spec',
      });
    });
  });

  group('client shapes', () {
    test('probing a decoder finds the required and decoded fields', () {
      final shape = probeClientShape(
        ClientDecoder(
          (json) => HealthLive.fromJson(json! as Map<String, dynamic>),
          (value) => (value! as HealthLive).toJson(),
        ),
        [
          {'status': 'ok'},
        ],
      );

      expect(shape.requiredFields, {r'$.status'});
      expect(shape.decodedFields, {r'$.status'});
    });

    test('the recorded fixtures cover every decoded catalog endpoint', () {
      final root = findRepoRoot(from: Directory.current);
      final shapes = clientShapesFromFixtures(
        Directory('${fixturesRoot(root).path}/${readBackendRef(root)}'),
      );

      for (final endpoint in GiEndpoints.all) {
        if (bodylessEndpointIds.contains(endpoint.id)) continue;
        expect(
          shapes[endpoint.id]?.decodedFields,
          isNotEmpty,
          reason: '${endpoint.id} has no decoder or no decodable fixture',
        );
      }
      expect(shapes[GiEndpoints.devicesDetail.id]!.requires(r'$.id'), isTrue);
    });
  });

  group('helpers', () {
    test('docsJsonUri drops /api/v1 and trailing slashes', () {
      expect(
        docsJsonUri('http://127.0.0.1:5000/api/v1/').toString(),
        'http://127.0.0.1:5000/docs-json',
      );
      expect(
        docsJsonUri('localhost:3000').toString(),
        'http://localhost:3000/docs-json',
      );
    });

    test('canonicalJson sorts keys and is stable', () {
      final text = canonicalJson({
        'b': 1,
        'a': {'d': 2, 'c': 3},
      });

      expect(text, '{\n  "a": {\n    "c": 3,\n    "d": 2\n  },\n  "b": 1\n}\n');
      expect(canonicalJson(jsonDecode(text)), text);
    });

    test('the committed snapshot is canonical', () {
      final root = findRepoRoot(from: Directory.current);
      final file = File(
        '${root.path}/contract/openapi/core-${readBackendRef(root)}.json',
      );
      final text = normalizeNewlines(file.readAsStringSync());

      expect(canonicalJson(jsonDecode(text)), text);
      expect(readOperations(readSpecFile(file)), isNotEmpty);
    });

    test('the committed snapshot has every catalog operation', () {
      final root = findRepoRoot(from: Directory.current);
      final snapshot = readSpecFile(
        File('${root.path}/contract/openapi/core-${readBackendRef(root)}.json'),
      );

      final report = diffSpecs(
        snapshot: snapshot,
        live: snapshot,
        endpoints: GiEndpoints.all,
      );
      expect(report.findings, isEmpty);
    });
  });
}
