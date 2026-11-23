#!/usr/bin/env bash
# Starts the UNMODIFIED GI Core backend in Docker for mobile development, or
# (--contract) a separate, throwaway contract stack next to it.
#
# Dev stack (default). Runs, from the backend checkout (default: ../home-energy-poc
# next to this repo, override with GI_BACKEND_DIR or --backend-dir):
#
#   docker compose -f infrastructure/compose.yml -f <this repo>/tools/backend/compose.override.yml \
#     up -d postgres mosquitto gi-core
#
# then waits for GET /api/v1/health/live and, with --seed, runs
# `dart run tools/seed_core.dart --init --allow-initialized` from this repo.
#
# Contract stack (--contract, plan §17.3). Runs, from this repo:
#
#   docker compose -p gi-mobile-contract-<runId> -f contract/compose.contract.yml up -d --build --wait
#
# (GI Core, its own tmpfs Postgres, local-only mosquitto, fake ESPHome device; ephemeral
# 127.0.0.1 port, no container names, so it runs beside the dev stack), resolves the port
# with `docker compose port mosquitto 3000`, waits for /api/v1/health/live and prints
# GI_CORE_URL, FAKE_ESPHOME_URL, GI_EDGE_SIM_URL and GI_EDGE_SIM_CONTROL_URL (the GI Edge
# device simulator, docs/gi-edge-simulator.md). --seed runs the seeder with --init --yes;
# --edge-sim also provisions and activates the simulator. --down removes the project and
# its volumes (down -v).
#
# Nothing is written to the backend repo by this script. Compose itself only
# produces files the backend already gitignores (see README, "Backend").
# Re-running is safe: `up -d` leaves services with unchanged configuration as they are.
#
# Usage: tools/dev-up.sh [--backend-dir DIR] [--lan] [--port N] [--seed] [--timeout SECONDS]
#        tools/dev-up.sh --contract [--run-id ID] [--seed [--edge-sim]] [--backend-dir DIR] [--timeout SECONDS]
#        tools/dev-up.sh --contract --run-id ID --down
#   --lan       dev only: publish GI Core on 0.0.0.0 (GI_CORE_BIND_ADDRESS) for a physical
#               phone on the LAN; changing it on a running stack recreates the containers
#   --port      dev only: host port (GI_CORE_PORT, default 3000)
#   --seed      run the seeder after the health check
#   --edge-sim  contract only (with --seed): also provision and activate the GI Edge simulator
#   --contract  start (or with --down remove) the contract stack gi-mobile-contract-<run-id>
#   --run-id    contract project suffix (default: random when starting; required with --down)
#   --down      contract only: docker compose ... down -v
#   --timeout   health-check wait in seconds (default 600; the first start runs npm ci or
#               builds the images)
set -euo pipefail

usage() { sed -n '2,41p' "$0" | sed 's/^# \{0,1\}//'; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
override="$repo_root/tools/backend/compose.override.yml"
contract_compose="$repo_root/contract/compose.contract.yml"
backend_dir="${GI_BACKEND_DIR:-$repo_root/../home-energy-poc}"
port="${GI_CORE_PORT:-3000}"
seed=false
timeout=600
contract=false
run_id=""
down=false
dev_only=false
edge_sim=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --backend-dir) backend_dir="${2:?--backend-dir needs a path}"; shift 2 ;;
    --lan) export GI_CORE_BIND_ADDRESS=0.0.0.0; dev_only=true; shift ;;
    --port) port="${2:?--port needs a number}"; dev_only=true; shift 2 ;;
    --seed) seed=true; shift ;;
    --edge-sim) edge_sim=true; shift ;;
    --timeout) timeout="${2:?--timeout needs seconds}"; shift 2 ;;
    --contract) contract=true; shift ;;
    --run-id) run_id="${2:?--run-id needs a value}"; shift 2 ;;
    --down) down=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 64 ;;
  esac
done

die() { echo "error: $*" >&2; exit 1; }

wait_health() { # url seconds hint
  echo "Waiting for $1 (up to ${2}s)..."
  local deadline=$((SECONDS + $2))
  until curl -fsS --max-time 5 --noproxy '*' "$1" >/dev/null 2>&1; do
    if ((SECONDS >= deadline)); then
      die "GI Core did not become healthy within ${2}s. $3"
    fi
    sleep 3
  done
}

run_seeder() {
  # Prefer the SDK pinned by FVM (.fvmrc): the dart on PATH may be older than
  # the workspace's SDK constraint and fail to compile the seeder.
  local dart="$repo_root/.fvm/flutter_sdk/bin/dart"
  if [[ ! -x "$dart" ]]; then
    command -v dart >/dev/null 2>&1 || die "no FVM SDK (.fvm/flutter_sdk; run 'fvm install') and dart is not on PATH; cannot run the seeder"
    dart=dart
  fi
  (cd "$repo_root" && "$dart" run tools/seed_core.dart "$@")
}

if [[ "$contract" != true && ( "$down" == true || -n "$run_id" ) ]]; then
  die "--run-id and --down apply to the contract stack only (add --contract)"
fi
command -v docker >/dev/null 2>&1 || die "docker is not on PATH (install Docker with Compose v2)"
command -v curl >/dev/null 2>&1 || die "curl is not on PATH"

if [[ "$contract" == true ]]; then
  if [[ "$dev_only" == true ]]; then
    echo "warning: --lan and --port do not apply to --contract (ephemeral port on 127.0.0.1)" >&2
  fi
  if [[ "$down" == true ]]; then
    [[ -n "$run_id" ]] || die "--down needs the --run-id of the stack to remove"
  elif [[ -z "$run_id" ]]; then
    run_id="$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"
  fi
  [[ "$run_id" =~ ^[a-z0-9][a-z0-9_-]*$ ]] \
    || die "--run-id must be lowercase letters, digits, '-' or '_' (compose project name): $run_id"
  project="gi-mobile-contract-$run_id"

  if [[ "$down" == true ]]; then
    docker compose -p "$project" -f "$contract_compose" down -v
    echo "Removed $project (containers, network, volumes)."
    exit 0
  fi

  [[ -f "$backend_dir/apps/gi-core/Dockerfile" ]] \
    || die "not a GI Core checkout (missing apps/gi-core/Dockerfile): $backend_dir"
  # Absolute, so compose does not resolve it against contract/.
  GI_BACKEND_DIR="$(cd "$backend_dir" && pwd)"
  export GI_BACKEND_DIR

  echo "Backend:  $GI_BACKEND_DIR (read-only build context)"
  echo "Project:  $project"
  docker compose -p "$project" -f "$contract_compose" up -d --build --wait --wait-timeout "$timeout" \
    || die "docker compose up failed. Logs: docker compose -p $project logs; clean up: tools/dev-up.sh --contract --run-id $run_id --down"

  core_published="$(docker compose -p "$project" -f "$contract_compose" port mosquitto 3000 | head -n1 | tr -d '\r')"
  fake_published="$(docker compose -p "$project" -f "$contract_compose" port fake-esphome 80 | head -n1 | tr -d '\r')"
  [[ -n "$core_published" ]] || die "could not resolve the published GI Core port of $project"
  core_url="http://$core_published"
  fake_url="http://$fake_published"
  sim_published="$(docker compose -p "$project" -f "$contract_compose" port gi-edge-sim 80 | head -n1 | tr -d '[:space:]')"
  sim_control_published="$(docker compose -p "$project" -f "$contract_compose" port gi-edge-sim 8081 | head -n1 | tr -d '[:space:]')"
  sim_url="http://$sim_published"
  sim_control_url="http://$sim_control_published"
  wait_health "$core_url/api/v1/health/live" "$timeout" "Logs: docker compose -p $project logs gi-core"
  echo "GI Core is up."

  if [[ "$seed" == true ]]; then
    seed_args=(--base-url "$core_url" --init --yes)
    if [[ "$edge_sim" == true ]]; then seed_args+=(--edge-sim gi-edge-sim); fi
    run_seeder "${seed_args[@]}"
  fi

  cat <<EOF

GI_CONTRACT_PROJECT=$project
GI_CORE_URL=$core_url
FAKE_ESPHOME_URL=$fake_url
GI_EDGE_SIM_URL=$sim_url
GI_EDGE_SIM_CONTROL_URL=$sim_control_url

Contract tests (packages/gi_core_api):
  GI_CORE_URL=$core_url FAKE_ESPHOME_URL=$fake_url GI_EDGE_SIM_CONTROL_URL=$sim_control_url dart test -t contract -j 1
GI Edge simulator: curl $sim_control_url/fake/state  (docs/gi-edge-simulator.md)
Remove: tools/dev-up.sh --contract --run-id $run_id --down
EOF
  exit 0
fi

[[ -d "$backend_dir" ]] || die "backend checkout not found: $backend_dir (set GI_BACKEND_DIR or --backend-dir)"
backend_dir="$(cd "$backend_dir" && pwd)"
[[ -f "$backend_dir/infrastructure/compose.yml" ]] \
  || die "not a GI Core checkout (missing infrastructure/compose.yml): $backend_dir"
[[ -f "$backend_dir/apps/gi-core/.env" ]] \
  || die "missing $backend_dir/apps/gi-core/.env (gitignored, required by the backend compose). Create it yourself from apps/gi-core/.env.example following the backend README; this script never writes to the backend repo."

# Compose reads these at runtime; they apply to this process and its children only.
export GI_CORE_PORT="$port"
bind="${GI_CORE_BIND_ADDRESS:-127.0.0.1}"

echo "Backend:  $backend_dir"
echo "Override: $override"
echo "GI Core:  $bind:$port"

(cd "$backend_dir" && docker compose -f infrastructure/compose.yml -f "$override" up -d postgres mosquitto gi-core)

wait_health "http://127.0.0.1:$port/api/v1/health/live" "$timeout" \
  "The first start runs npm ci. Logs: docker logs gi-core"
echo "GI Core is up."

if [[ "$seed" == true ]]; then
  run_seeder --base-url "http://127.0.0.1:$port" --init --allow-initialized
fi

cat <<EOF

App base URL presets:
  Android emulator      10.0.2.2:$port
  iOS simulator         localhost:$port
  Android over USB      adb reverse tcp:$port tcp:$port, then localhost:$port
EOF
if [[ "$bind" == 0.0.0.0 ]]; then
  echo "  Phone on the LAN      <this machine's LAN IP>:$port (allow TCP $port in the firewall)"
else
  echo "  Phone on the LAN      re-run with --lan (GI_CORE_BIND_ADDRESS=0.0.0.0)"
fi
