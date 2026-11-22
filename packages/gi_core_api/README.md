# gi_core_api

Pure-Dart (no Flutter) client for the existing, unchangeable GI Core API
(`/api/v1`). See `docs/flutter-app-plan.md` §6–§8 in the repository root.

## What is inside

| Area | Entry point |
|---|---|
| Typed calls | `GiCoreClient` (`healthLive`, `setupStatus`, `login`, `logout`, `me`, `profile`, `changePassword`, `rooms`, `devices`, `device`) |
| Session | `AuthSessionManager` (single owner of the refresh cookie, single-flight refresh, write-ahead persistence, `states` stream) |
| Secure storage port | `TokenVault` (`read` → `VaultResult`), `InMemoryTokenVault` for tests |
| Connect screen | `ApplianceAddress.parse`, `ApplianceProbe.probe` |
| Catalog / role gating | `GiEndpoints`, `Endpoint.allows(role)` |
| Errors | `ApiFailure` (sealed), `ApiErrorEnvelope` |

The refresh token exists only as the `gi_refresh_token` cookie. It is parsed
by hand (`RefreshCookieCodec`), stored through `TokenVault` and sent only to
`POST /auth/refresh`. Every rotation is persisted before the new access token
is used; an ambiguous refresh is never repeated before `GET /health/live`
succeeds.

## Usage

```dart
final probe = await ApplianceProbe(clientInfo: info).probe('192.168.1.10:3000');
final client = GiCoreClient.create(
  address: probe.address,
  vault: mySecureStorageVault,
  clientInfo: info,
  expectedInitializedAt: probe.setup.initializedAt,
);
client.session.states.listen(print);
await client.restoreSession(); // or client.login(email: ..., password: ...)
final devices = await client.devices();
```

## Development

```sh
dart run build_runner build      # freezed + json_serializable
dart analyze
dart test -x contract            # unit tests
dart test -t contract -j 1       # live tests, one file at a time (GI_CORE_URL, default http://localhost:3000)
```

Live tests carry the tag `contract` (the plan's `live`, §17.3) and decode in
strict mode (`DecodeMode.strict`): a field the models do not know fails them.
Run them against a contract stack (`tools/dev-up.ps1 -Contract -Seed`, see the
repo README), which prints `GI_CORE_URL` and `FAKE_ESPHOME_URL`.
`GI_CORE_URL_B` (a second contract stack) enables the two-Core acceptance test
of §9.3. Tests that change data (switching the fake device, the owner
password) run only on a Core seeded for contract use and skip on a dev Core.
Credentials come from `tools/backend/dev.env` (owner) and
`tools/seed_accounts.example.json` (ADMIN, USER, SERVICE). The suites log in
eight times in all; GI Core allows 5 logins per minute, so a login over the
limit waits out `Retry-After` once (`respectingLoginLimit`).

Recorded responses live in
`test/fixtures/core/<backendRef>/<endpointId>/<case>.json` (plan §17.4):
`backendRef` is `shortSha` in `contract/backend.lock`, `endpointId` the
catalog id (`GiEndpoints`, the Swagger operationId), plus
`<case>.set-cookie.txt` for `Set-Cookie` headers. `tools/seed_core.dart
--fixtures` records missing ones.
