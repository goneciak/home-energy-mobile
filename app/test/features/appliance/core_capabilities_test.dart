import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/appliance/application/core_capabilities.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';

import '../../support/fake_core_adapter.dart';

/// Feature probing (plan §16 pt 2) through the real client and providers.
void main() {
  const probe = CapabilityProbe.placeholderDeviceId;
  const schedules = 'GET /api/v1/devices/$probe/schedules';
  const pvPlan = 'GET /api/v1/devices/$probe/pv-heating-plan';
  const history =
      'GET /api/v1/devices/$probe/entities/'
      '${CapabilityProbe.placeholderEntityId}/history';
  const sessions = 'GET /api/v1/auth/sessions';

  late FakeCoreAdapter core;
  late GiCoreClient client;

  setUp(() async {
    core = FakeCoreAdapter({
      'POST /api/v1/auth/login': (_) => jsonReply(
        {'accessToken': 'access', 'expiresIn': 900, 'user': ownerUser},
        headers: {
          'set-cookie': [testSetCookie],
        },
      ),
      schedules: (_) =>
          jsonReply(errorEnvelope(404, 'DEVICE_NOT_FOUND'), status: 404),
      history: (_) =>
          jsonReply(errorEnvelope(404, 'DEVICE_ENTITY_NOT_FOUND'), status: 404),
      sessions: (_) => jsonReply(<Object>[]),
      // pv-heating-plan is not routed: this "Core" answers HTTP_404.
    });
    client = GiCoreClient.create(
      address: ApplianceAddress.parse('http://gi-home.local'),
      vault: InMemoryTokenVault(),
      clientInfo: const ClientInfo(appVersion: '0.1.0', platform: 'test'),
      httpClientAdapter: core,
      retryBackoff: (_) => Duration.zero,
    );
    await client.login(email: 'a@gihome.test', password: 'Secret123');
    core.requests.clear();
  });

  tearDown(() => client.close());

  CurrentUser userWith(UserRole role) => CurrentUser(
    id: 'u1',
    email: 'a@gihome.test',
    firstName: 'Anna',
    mustChangePassword: false,
    role: role,
  );

  ProviderContainer containerFor(UserRole? role) {
    final container = ProviderContainer(
      overrides: [
        giCoreClientProvider.overrideWithValue(client),
        currentUserProvider.overrideWithValue(
          role == null ? null : userWith(role),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  int probesSent() => core.requestedRoutes
      .where((r) => [schedules, pvPlan, history, sessions].contains(r))
      .length;

  test('a missing route hides its feature, domain 404s keep theirs', () async {
    final container = containerFor(UserRole.user);
    final caps = await container.read(coreCapabilitiesProvider.future);

    expect(caps[CoreCapability.schedules], CapabilityStatus.present);
    expect(caps[CoreCapability.history], CapabilityStatus.present);
    expect(caps[CoreCapability.sessions], CapabilityStatus.present);
    expect(caps[CoreCapability.pvPlan], CapabilityStatus.absent);
    expect(
      container.read(coreCapabilityAvailableProvider(CoreCapability.pvPlan)),
      isFalse,
    );
    expect(
      container.read(coreCapabilityAvailableProvider(CoreCapability.schedules)),
      isTrue,
    );
    expect(
      core.requestedRoutes.where((r) => r.contains('weather')),
      isEmpty,
      reason: 'weather and the PV forecast are never probed',
    );
  });

  test('results are cached per client: probed once', () async {
    final container = containerFor(UserRole.owner);
    await container.read(coreCapabilitiesProvider.future);
    await container.read(coreCapabilitiesProvider.future);
    container.read(coreCapabilityAvailableProvider(CoreCapability.history));
    expect(probesSent(), 4);
  });

  test('a role the catalog does not allow sends no probe', () async {
    final container = containerFor(UserRole.unknown);
    final caps = await container.read(coreCapabilitiesProvider.future);
    expect(probesSent(), 0);
    expect(caps, CoreCapabilities.unprobed);
  });

  test('signed out: nothing is probed and everything stays visible', () async {
    final container = containerFor(null);
    expect(
      await container.read(coreCapabilitiesProvider.future),
      CoreCapabilities.unprobed,
    );
    expect(probesSent(), 0);
  });

  test('before the probes finish every feature is shown', () {
    final container = containerFor(UserRole.owner);
    for (final capability in CoreCapability.values) {
      expect(
        container.read(coreCapabilityAvailableProvider(capability)),
        isTrue,
      );
    }
  });

  test(
    'a changed Core version re-probes; learning it first does not',
    () async {
      final container = containerFor(UserRole.owner);
      container.listen(coreCapabilitiesProvider, (_, _) {});
      await container.read(coreCapabilitiesProvider.future);
      expect(probesSent(), 4);

      container.read(coreVersionChangesProvider.notifier)
        ..note('1.4.0')
        ..note(null)
        ..note('1.4.0');
      await container.read(coreCapabilitiesProvider.future);
      expect(probesSent(), 4);

      container.read(coreVersionChangesProvider.notifier).note('1.5.0');
      await container.read(coreCapabilitiesProvider.future);
      expect(probesSent(), 8);
    },
  );
}
