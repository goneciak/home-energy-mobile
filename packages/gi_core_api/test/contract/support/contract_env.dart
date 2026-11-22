import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

/// Shared setup of the live contract tests (tag `contract`, the plan's
/// `live`, §17.3).
///
/// Environment:
/// * `GI_CORE_URL`: the Core under test (default `http://localhost:3000`);
///   `tools/dev-up.ps1 -Contract` prints it for a contract stack.
/// * `GI_CORE_URL_B`: a second Core with another `initializedAt`; enables the
///   §9.3 acceptance test.
/// * `FAKE_ESPHOME_URL`: the contract stack's fake device as published on the
///   host; when set, the fake device MUST be provisioned in GI Core and its
///   physical state is checked too.
///
/// Credentials: the owner from `tools/backend/dev.env` (written by
/// `tools/seed_core.dart`), the seeded ADMIN/USER from
/// `tools/seed_accounts.json`, else `tools/seed_accounts.example.json`.
/// They are test values and never printed.
abstract final class ContractEnv {
  static Map<String, String> get _env => Platform.environment;

  static String get coreUrl => _env['GI_CORE_URL'] ?? 'http://localhost:3000';

  static String? get coreUrlB => _nonEmpty(_env['GI_CORE_URL_B']);

  static String? get fakeEsphomeUrl => _nonEmpty(_env['FAKE_ESPHOME_URL']);

  static const clientInfo = ClientInfo(
    appVersion: '0.1.0',
    platform: 'Contract; Dart',
  );

  /// Owner e-mail and password, or null without `tools/backend/dev.env`.
  static ({String email, String password})? owner() {
    final file = File('../../tools/backend/dev.env');
    if (!file.existsSync()) return null;
    final values = <String, String>{};
    for (final line in file.readAsLinesSync()) {
      final eq = line.indexOf('=');
      if (line.trimLeft().startsWith('#') || eq <= 0) continue;
      values[line.substring(0, eq).trim()] = line.substring(eq + 1).trim();
    }
    final email = values['GI_DEV_EMAIL'];
    final password = values['GI_DEV_PASSWORD'];
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }

  /// The seeded account with [role] (`ADMIN`, `USER`).
  static ({String email, String password}) seededAccount(String role) {
    final local = File('../../tools/seed_accounts.json');
    final file = local.existsSync()
        ? local
        : File('../../tools/seed_accounts.example.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final account = (json['accounts'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((a) => a['role'] == role);
    return (
      email: account['email'] as String,
      password: account['password'] as String,
    );
  }

  /// Probes [url]; null when nothing answers as GI Core.
  static Future<ProbeResult?> probe(String url) async {
    try {
      return await ApplianceProbe(clientInfo: clientInfo).probe(url);
    } on Object {
      return null;
    }
  }

  /// Why the suite cannot run against [probe] of [url], or null when it can.
  /// The Core must be reachable and initialized: an uninitialized Core was
  /// never seeded, and the suite never initializes one itself.
  static String? skipReason(String url, ProbeResult? probe) {
    if (owner() == null) {
      return 'tools/backend/dev.env with GI_DEV_EMAIL/GI_DEV_PASSWORD is '
          'missing (run tools/seed_core.dart)';
    }
    if (probe == null) return 'GI Core is not reachable at $url';
    if (!probe.setup.initialized) {
      return 'GI Core at $url is not initialized (run tools/seed_core.dart '
          '--init)';
    }
    return null;
  }

  static String? _nonEmpty(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}

/// What the fake device reports in its manifest (tools/fake_esphome).
abstract final class FakeDevice {
  static const manufacturer = 'GI Contract Fakes';
  static const model = 'fake-esphome';

  static bool matches(DeviceListItem device) =>
      device.manufacturer == manufacturer && device.model == model;
}

/// Whether [devices] show a Core seeded for contract use: only a contract
/// stack can provision the fake device (plan D20), so its presence is the
/// guard for tests that change data (switching, strategy, passwords).
bool isContractSeeded(Iterable<DeviceListItem> devices) =>
    devices.any(FakeDevice.matches);

/// Runs [login], waiting out GI Core's login rate limit (5 per minute per
/// IP, `Retry-After` in seconds) once. The suites together stay within the
/// limit; this only absorbs logins made just before (the seeder, an earlier
/// run).
Future<T> respectingLoginLimit<T>(Future<T> Function() login) async {
  try {
    return await login();
  } on RateLimitedFailure catch (failure) {
    final wait =
        (failure.retryAfter ?? const Duration(seconds: 60)) +
        const Duration(seconds: 1);
    printOnFailure('login rate limited; waiting ${wait.inSeconds} s');
    await Future<void>.delayed(wait);
    return await login();
  }
}

/// A client in strict decoding mode: a field the models do not know fails
/// the call (plan §6.4, §17.3).
GiCoreClient strictClient({
  required ApplianceAddress address,
  required TokenVault vault,
  DateTime? expectedInitializedAt,
  HttpClientAdapter? httpClientAdapter,
  EtagCache? etagCache,
}) => GiCoreClient.create(
  address: address,
  vault: vault,
  clientInfo: ContractEnv.clientInfo,
  expectedInitializedAt: expectedInitializedAt,
  decodeMode: DecodeMode.strict,
  httpClientAdapter: httpClientAdapter,
  etagCache: etagCache,
  etagScope: 'contract',
);

/// A raw Dio on [address]'s API base that never throws on a status code.
Dio rawDio(ApplianceAddress address) => Dio(
  BaseOptions(
    baseUrl: address.apiBaseUrl.toString(),
    validateStatus: (_) => true,
    followRedirects: false,
  ),
);

/// The real network adapter, recording every request it sends (§9.3).
final class RecordingAdapter implements HttpClientAdapter {
  new() : _inner = IOHttpClientAdapter();

  final HttpClientAdapter _inner;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return _inner.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) => _inner.close(force: force);
}

/// The value of header [name] in [options], case-insensitively.
Object? headerOf(RequestOptions options, String name) {
  final lower = name.toLowerCase();
  for (final MapEntry(:key, :value) in options.headers.entries) {
    if (key.toLowerCase() == lower) return value;
  }
  return null;
}
