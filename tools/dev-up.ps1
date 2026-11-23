<#
.SYNOPSIS
  Starts the UNMODIFIED GI Core backend in Docker for mobile development, or
  (-Contract) a separate, throwaway contract stack next to it.

.DESCRIPTION
  Dev stack (default). Runs, from the backend checkout (default:
  ..\home-energy-poc next to this repo, override with -BackendDir or
  $env:GI_BACKEND_DIR):

    docker compose -f infrastructure/compose.yml -f <this repo>\tools\backend\compose.override.yml `
      up -d postgres mosquitto gi-core

  then waits for GET /api/v1/health/live and, with -Seed, runs
  `dart run tools/seed_core.dart --init --allow-initialized` from this repo.

  Contract stack (-Contract, plan §17.3). Runs, from this repo:

    docker compose -p gi-mobile-contract-<runId> -f contract/compose.contract.yml up -d --build --wait

  GI Core, its own Postgres (tmpfs), a local-only mosquitto and the fake
  ESPHome device, built from the backend checkout as a read-only context. No
  container names, no fixed host ports: GI Core is published on an ephemeral
  127.0.0.1 port, so it runs beside the dev stack without collisions. The
  script resolves the port (`docker compose port mosquitto 3000`), waits for
  /api/v1/health/live and prints GI_CORE_URL and FAKE_ESPHOME_URL. With -Seed
  it runs the seeder with --init --yes. -Down removes the project and its
  volumes (`down -v`).

  Nothing is written to the backend repo by this script. Compose itself only
  produces files the backend already gitignores (see README, "Backend").
  Re-running is safe: `up -d` leaves services with unchanged configuration as
  they are.

.PARAMETER BackendDir
  Path to the GI Core checkout. Default: $env:GI_BACKEND_DIR, else ..\home-energy-poc.

.PARAMETER Lan
  Dev stack only. Publish GI Core on all interfaces (GI_CORE_BIND_ADDRESS=0.0.0.0)
  for a physical phone on the LAN. Changing this on a running stack recreates
  the containers. Open the port in the Windows firewall (Private profile).

.PARAMETER Port
  Dev stack only. Host port for GI Core (GI_CORE_PORT). Default:
  $env:GI_CORE_PORT, else 3000.

.PARAMETER Seed
  After the health check, run the seeder. Dev stack: --init --allow-initialized
  (initializes the appliance after a y/N prompt if needed, then creates the
  test accounts, demo rooms and devices idempotently). Contract stack:
  --init --yes (also provisions the fake device).

.PARAMETER Contract
  Start (or with -Down remove) a contract stack instead of the dev stack.

.PARAMETER RunId
  Contract stack only: the project is gi-mobile-contract-<RunId>. Default: a
  new random id when starting; required with -Down.

.PARAMETER EdgeSim
  Contract stack only, with -Seed: also provision the GI Edge device simulator
  (discover, claim, complete, synchronize, activation) and wait until GI Core
  reports communicationMode GI_EDGE_V1. The simulator container itself always
  starts with the stack; see docs/gi-edge-simulator.md.

.PARAMETER Down
  Contract stack only: `docker compose -p gi-mobile-contract-<RunId> down -v`.

.PARAMETER TimeoutSeconds
  How long to wait for the health check. The first dev start runs `npm ci`,
  and the first contract build builds the GI Core images, so the default is
  generous.

.EXAMPLE
  .\tools\dev-up.ps1 -Seed

.EXAMPLE
  $env:GI_BACKEND_DIR = 'D:\src\home-energy-poc'; .\tools\dev-up.ps1 -Lan

.EXAMPLE
  .\tools\dev-up.ps1 -Contract -RunId a -Seed
  # GI_CORE_URL=http://127.0.0.1:<port>  ...
  .\tools\dev-up.ps1 -Contract -RunId a -Down
#>
[CmdletBinding()]
param(
  [string]$BackendDir,
  [switch]$Lan,
  [int]$Port,
  [switch]$Seed,
  [switch]$EdgeSim,
  [switch]$Contract,
  [string]$RunId,
  [switch]$Down,
  [int]$TimeoutSeconds = 600
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$override = Join-Path $repoRoot 'tools\backend\compose.override.yml'
$contractCompose = Join-Path $repoRoot 'contract\compose.contract.yml'

function Wait-Health([string]$Url, [int]$Seconds, [string]$Hint) {
  Write-Host "Waiting for $Url (up to $Seconds s)..."
  $deadline = (Get-Date).AddSeconds($Seconds)
  while ((Get-Date) -lt $deadline) {
    try {
      $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
      if ($response.StatusCode -eq 200) { return }
    } catch {
      # Not up yet (connection refused, reset or non-2xx).
    }
    Start-Sleep -Seconds 3
  }
  throw "GI Core did not become healthy within $Seconds s. $Hint"
}

# docker writes progress to stderr. With $ErrorActionPreference = 'Stop',
# Windows PowerShell 5.1 turns redirected native stderr into a terminating
# error, so native calls run with 'Continue' and are judged by the exit code.
function Invoke-Docker {
  $ErrorActionPreference = 'Continue'
  & docker @args
}

function Invoke-Seeder([string[]]$SeedArgs) {
  # Prefer the SDK pinned by FVM (.fvmrc): the dart on PATH may be older than
  # the workspace's SDK constraint and fail to compile the seeder.
  $dart = Join-Path $repoRoot '.fvm\flutter_sdk\bin\dart.bat'
  if (-not (Test-Path -LiteralPath $dart)) {
    if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
      throw 'No FVM SDK (.fvm\flutter_sdk; run "fvm install") and dart is not on PATH - cannot run the seeder.'
    }
    $dart = 'dart'
  }
  Push-Location -LiteralPath $repoRoot
  try {
    $ErrorActionPreference = 'Continue'
    & $dart run tools/seed_core.dart @SeedArgs
    if ($LASTEXITCODE -ne 0) { throw "Seeder failed (exit $LASTEXITCODE)." }
  } finally {
    Pop-Location
  }
}

if (($Down -or $RunId) -and -not $Contract) {
  throw '-RunId and -Down apply to the contract stack only (add -Contract).'
}

if (-not $BackendDir) {
  if ($env:GI_BACKEND_DIR) {
    $BackendDir = $env:GI_BACKEND_DIR
  } else {
    $BackendDir = Join-Path $repoRoot '..\home-energy-poc'
  }
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw 'docker is not on PATH (install Docker Desktop with Compose v2).'
}

if ($Contract) {
  if ($Lan -or $Port) {
    Write-Warning '-Lan and -Port do not apply to -Contract (ephemeral port on 127.0.0.1).'
  }
  if ($Down) {
    if (-not $RunId) { throw '-Down needs the -RunId of the stack to remove.' }
  } elseif (-not $RunId) {
    $RunId = [guid]::NewGuid().ToString('N').Substring(0, 8)
  }
  if ($RunId -notmatch '^[a-z0-9][a-z0-9_-]*$') {
    throw "-RunId must be lowercase letters, digits, '-' or '_' (compose project name): $RunId"
  }
  $project = "gi-mobile-contract-$RunId"

  if ($Down) {
    Invoke-Docker compose -p $project -f $contractCompose down -v
    if ($LASTEXITCODE -ne 0) { throw "docker compose down failed (exit $LASTEXITCODE)." }
    Write-Host "Removed $project (containers, network, volumes)."
    return
  }

  if (-not (Test-Path -LiteralPath (Join-Path $BackendDir 'apps\gi-core\Dockerfile') -PathType Leaf)) {
    throw "Not a GI Core checkout (missing apps\gi-core\Dockerfile): $BackendDir"
  }
  # Absolute, so compose does not resolve it against contract\.
  $env:GI_BACKEND_DIR = (Resolve-Path -LiteralPath $BackendDir).Path

  Write-Host "Backend:  $($env:GI_BACKEND_DIR) (read-only build context)"
  Write-Host "Project:  $project"
  Invoke-Docker compose -p $project -f $contractCompose up -d --build --wait --wait-timeout $TimeoutSeconds
  if ($LASTEXITCODE -ne 0) {
    throw ("docker compose up failed (exit $LASTEXITCODE). Logs: docker compose -p $project logs; " +
      "clean up: .\tools\dev-up.ps1 -Contract -RunId $RunId -Down")
  }

  $corePublished = (Invoke-Docker compose -p $project -f $contractCompose port mosquitto 3000 | Select-Object -First 1)
  $fakePublished = (Invoke-Docker compose -p $project -f $contractCompose port fake-esphome 80 | Select-Object -First 1)
  if (-not $corePublished) { throw "Could not resolve the published GI Core port of $project." }
  $coreUrl = "http://$($corePublished.Trim())"
  $fakeUrl = "http://$($fakePublished.Trim())"
  $simPublished = (Invoke-Docker compose -p $project -f $contractCompose port gi-edge-sim 80 | Select-Object -First 1)
  $simControlPublished = (Invoke-Docker compose -p $project -f $contractCompose port gi-edge-sim 8081 | Select-Object -First 1)
  $simUrl = "http://$($simPublished.Trim())"
  $simControlUrl = "http://$($simControlPublished.Trim())"
  Wait-Health "$coreUrl/api/v1/health/live" $TimeoutSeconds "Logs: docker compose -p $project logs gi-core"
  Write-Host 'GI Core is up.'

  if ($Seed) {
    $seedArgs = @('--base-url', $coreUrl, '--init', '--yes')
    if ($EdgeSim) { $seedArgs += @('--edge-sim', 'gi-edge-sim') }
    Invoke-Seeder $seedArgs
  }

  Write-Host ''
  Write-Host "GI_CONTRACT_PROJECT=$project"
  Write-Host "GI_CORE_URL=$coreUrl"
  Write-Host "FAKE_ESPHOME_URL=$fakeUrl"
  Write-Host "GI_EDGE_SIM_URL=$simUrl"
  Write-Host "GI_EDGE_SIM_CONTROL_URL=$simControlUrl"
  Write-Host ''
  Write-Host 'Contract tests (packages\gi_core_api):'
  Write-Host "  `$env:GI_CORE_URL='$coreUrl'; `$env:FAKE_ESPHOME_URL='$fakeUrl'; `$env:GI_EDGE_SIM_CONTROL_URL='$simControlUrl'; dart test -t contract -j 1"
  Write-Host "GI Edge simulator: curl $simControlUrl/fake/state  (docs/gi-edge-simulator.md)"
  Write-Host "Remove: .\tools\dev-up.ps1 -Contract -RunId $RunId -Down"
  return
}

if (-not (Test-Path -LiteralPath $BackendDir -PathType Container)) {
  throw "Backend checkout not found: $BackendDir (set -BackendDir or GI_BACKEND_DIR)."
}
$BackendDir = (Resolve-Path -LiteralPath $BackendDir).Path

$baseCompose = Join-Path $BackendDir 'infrastructure\compose.yml'
if (-not (Test-Path -LiteralPath $baseCompose -PathType Leaf)) {
  throw "Not a GI Core checkout (missing infrastructure\compose.yml): $BackendDir"
}
$coreEnv = Join-Path $BackendDir 'apps\gi-core\.env'
if (-not (Test-Path -LiteralPath $coreEnv -PathType Leaf)) {
  throw ("Missing $coreEnv (gitignored, required by the backend compose). " +
    'Create it yourself from apps\gi-core\.env.example following the backend README; ' +
    'this script never writes to the backend repo.')
}

if (-not $Port) {
  if ($env:GI_CORE_PORT) { $Port = [int]$env:GI_CORE_PORT } else { $Port = 3000 }
}
# Compose reads these at runtime; they apply to this process and its children only.
$env:GI_CORE_PORT = "$Port"
if ($Lan) { $env:GI_CORE_BIND_ADDRESS = '0.0.0.0' }
$bind = if ($env:GI_CORE_BIND_ADDRESS) { $env:GI_CORE_BIND_ADDRESS } else { '127.0.0.1' }

Write-Host "Backend:  $BackendDir"
Write-Host "Override: $override"
Write-Host "GI Core:  ${bind}:$Port"

Push-Location -LiteralPath $BackendDir
try {
  Invoke-Docker compose -f 'infrastructure/compose.yml' -f $override up -d postgres mosquitto gi-core
  if ($LASTEXITCODE -ne 0) { throw "docker compose up failed (exit $LASTEXITCODE)." }
} finally {
  Pop-Location
}

Wait-Health "http://127.0.0.1:$Port/api/v1/health/live" $TimeoutSeconds `
  "The first start runs npm ci. Logs: docker logs gi-core (from $BackendDir)."
Write-Host 'GI Core is up.'

if ($Seed) { Invoke-Seeder @('--base-url', "http://127.0.0.1:$Port", '--init', '--allow-initialized') }

Write-Host ''
Write-Host 'App base URL presets:'
Write-Host "  Android emulator      10.0.2.2:$Port"
Write-Host "  iOS simulator         localhost:$Port"
Write-Host "  Android over USB      adb reverse tcp:$Port tcp:$Port, then localhost:$Port"
if ($bind -eq '0.0.0.0') {
  Write-Host "  Phone on the LAN      <this PC's LAN IP>:$Port (firewall: allow TCP $Port, Private profile)"
} else {
  Write-Host '  Phone on the LAN      re-run with -Lan (GI_CORE_BIND_ADDRESS=0.0.0.0)'
}
