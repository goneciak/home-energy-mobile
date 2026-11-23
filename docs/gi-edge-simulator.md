# GI Edge device simulator

`tools/gi_edge_sim` simulates a real GI Edge boiler-room controller next to an
unmodified GI Core in the contract stack. It exists so the app can be tested
against the device path the backend actually uses (the device pushes to Core,
Core never opens a connection to it) instead of the legacy ESPHome fake in
`tools/fake_esphome`, which stays for the legacy contract tests.

## What it does

- Serves the device HTTP API on port 80 (`/api/v1/device`, `/api/v1/status`,
  `/api/v1/events`, `/gi-provision`) so Core can discover, synchronize and
  activate it.
- After activation it behaves like the firmware, with the generic image's
  timings:
  - heartbeat every 15 s (`POST /api/v1/edge/heartbeat`) with the full
    diagnostics: state, both temperature sensors, both relays, faults;
  - telemetry every 5 s with only `device_uptime`;
  - command poll every 5 s, acknowledged with `POST /edge/commands/ack`.
- Every request is HMAC-signed over the exact body bytes. One persisted,
  strictly increasing sequence counter serves all requests, a fresh nonce is
  used each time. The signer is tested against the backend's golden vectors.
- The controller state machine mirrors the firmware: `IDLE`,
  `HEATING_REQUESTED`, `HEATING_VERIFYING`, `HEATING`, `STOPPING`, `FAULT`,
  `SAFE_MODE`. A start is accepted only in `IDLE` with enough valid sensor
  reads, only the heating relay (`relay_2`) may be switched remotely, expired
  or repeated commands are refused. Temperatures follow a small thermal model.
- Dry-run is the firmware default until Core pushes `dryRun: false` with a
  poll. In dry-run the outputs stay low, so the heating verification fails and
  the device ends in `FAULT`, as the firmware does.

## Confirmation semantics (kept as they are)

The simulator does not hide how Core behaves for an edge device:

- Core answers a manual switch immediately and optimistically; the result is
  only visible in a later heartbeat (`relayN.commanded` and `relayN.output`,
  with a `lastSeenAt` after the request). The app waits for exactly that.
- The device acknowledges success with `ACCEPTED`, which is not final in Core.
  A command that worked is therefore usually listed as `TIMED_OUT` after its
  deadline. `FAILED` is final.
- An acknowledgement is not a physical confirmation; the relay feedback is
  always `UNKNOWN`.

## Start

```powershell
$env:PATH = "C:\Users\<you>\fvm\versions\3.50.0\bin;" + $env:PATH
.\tools\dev-up.ps1 -Contract -RunId sim1 -Seed -EdgeSim
.\tools\dev-up.ps1 -Contract -RunId sim1 -Down
```

`-Seed -EdgeSim` also provisions and activates the simulator (below) and prints
`GI_EDGE_SIM_URL` and `GI_EDGE_SIM_CONTROL_URL`. Without `-EdgeSim` the
container runs unprovisioned and does nothing until it is activated.

## Provisioning through the public API

This is what the seeder does, in order. Core only accepts a private IPv4 on
port 80 as a device address, so the simulator is addressed by its container
name `gi-edge-sim`.

1. Log in as the owner (`POST /auth/login`).
2. `POST /integrations/esphome/discover` with `{"host": "gi-edge-sim"}`.
3. `GET /provisioning?source=ESPHOME`, then `POST /provisioning/:id/claim`.
4. `POST /provisioning/:id/complete` with `{"name": "...", "type": "ESP32"}`.
5. `POST /devices/:id/synchronize` creates `relay_1`, `relay_2`,
   `temperature_1` and `temperature_2` and the device's address.
6. Activation. Either Core pushes it itself after the synchronize
   (`GI_EDGE_ACTIVATION_BASE_URL` in `contract/contract.env` points at the
   Core), or call `POST /edge/devices/:id/activate-now`, or do it by hand:
   `POST /edge/activations` with `{"deviceId": "<Core UUID>", "coreBaseUrl":
   "http://mosquitto:3000"}` and give the token to the simulator with
   `POST /fake/activate` (below).
7. The device now reports `communicationMode: GI_EDGE_V1`. Finish with
   `PATCH /devices/:id` (`heatingRelayEntityId` = the `relay_2` entity,
   `controlTemperatureEntityId` = `temperature_1`), the entity roles and
   `PATCH /devices/:id/control-strategy`.

The legacy manifest `deviceId` (`gi-edge-sim-01`) is not the Core UUID; the
identity used for pushes is the one Core returns on activation.
A real device also shows `needs_configuration` until the roles of its
diagnostic entities are set; that is not an error.

## Control surface

On the loopback-only port `GI_EDGE_SIM_CONTROL_URL` (container port 8081).

- `GET /fake/state`: identity (without the secret), sequence, boot count, the
  scenario, the device state, the last 50 pushes with Core's HTTP status, the
  last handled commands.
- `POST /fake/scenario` with `{"mode": ...}`:

| mode | effect |
| --- | --- |
| `normal` | clears every injected failure, faults and skew |
| `no_ack` | commands are executed, the acknowledgement never reaches Core |
| `ack_failed` (`error`) | commands are refused with that error and not executed |
| `offline` | no push at all; Core marks the device offline after 90 to 150 s |
| `stale_heartbeat` | telemetry and polls continue, the heartbeat stops |
| `sensor_invalid` (`status`, `sensor`: `supply`, `return`, `both`) | sensor is not `VALID` |
| `fault` (`code`) | latches a fault and goes to `FAULT` |
| `safe_mode` | `SAFE_MODE`, relays off |
| `dry_run` (`enabled`) | toggles dry-run locally (Core pushes its value on the next poll) |
| `clock_skew` (`seconds`) | the device clock is off; beyond 5 minutes Core answers 401 |
| `revoke` | signs with a wrong secret: three 401 answers wipe the credential, reboot and self-heal |
| `reboot` | boot count + 1, uptime and state reset, identity and sequence kept |
| `ack_latency_ms`, `command_latency_ms` (`ms`) | delay before the acknowledgement or the execution |

- `POST /fake/activate` with `{"deviceId": "<Core UUID>", "activationToken":
  "..."}`: the manual activation path.
- `POST /fake/reset`: back to a blank, unprovisioned device.

## Settings

Environment variables of the container: `CORE_URL` (default in the compose
file `http://mosquitto:3000`, wins over the `core_url` Core sends),
`STATE_FILE`, `PHYSICAL_MAC`, `SIM_HEARTBEAT_S`, `SIM_TELEMETRY_S`,
`SIM_POLL_S`, `SIM_VERIFICATION_S` (heating verification window, 20 s),
`SIM_THERMAL_SPEED`, `SIM_NOISE`.

## Tests

`cd tools/gi_edge_sim && dart pub get && dart test`. The tests use a small stub
Core that enforces the signature rules; they need no Docker. The package is
standalone (not part of the workspace) because its image runs `dart pub get`.
