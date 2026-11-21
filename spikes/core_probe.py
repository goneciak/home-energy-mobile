"""Ad hoc probes of spikes S4/S5 (plan M0) against a seeded contract stack.

Standard library only (Python 3.10+). Never point it at the dev stack: the
`schedule`, `window` and `weather` probes write data (a heating schedule, the
house location) and `ratelimit` uses up the login window. Each of them first
checks for the contract stack's fake device (`fake-esphome`, as the Dart
contract tests do with isContractSeeded) and refuses to run without it. The
authoritative checks are the Dart contract tests in
packages/gi_core_api/test/contract; this script only records timelines and
one-off observations for docs/spikes/.

    python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> etag
    python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> statuses
    python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> timeline --seconds 200
    python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> schedule --seconds 150
    python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> window
    python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> weather
    python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> ratelimit

Each command logs in once (login is limited to 5 per minute per IP, failed
attempts included); `ratelimit` then deliberately uses up the window.
"""

import argparse
import datetime
import json
import pathlib
import time
import urllib.error
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
FAKE_MODEL = "fake-esphome"


def seeded(role):
    local = ROOT / "tools" / "seed_accounts.json"
    path = local if local.exists() else ROOT / "tools" / "seed_accounts.example.json"
    accounts = json.loads(path.read_text(encoding="utf-8"))["accounts"]
    account = next(a for a in accounts if a["role"] == role)
    return account["email"], account["password"]


def owner():
    values = {}
    for line in (ROOT / "tools" / "backend" / "dev.env").read_text().splitlines():
        if "=" in line and not line.lstrip().startswith("#"):
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip()
    return values["GI_DEV_EMAIL"], values["GI_DEV_PASSWORD"]


class Core:
    def __init__(self, base):
        self.api = base.rstrip("/") + "/api/v1"
        self.token = None

    def request(self, method, path, body=None, headers=None):
        data = json.dumps(body).encode() if body is not None else None
        all_headers = {"content-type": "application/json"} if data else {}
        if self.token:
            all_headers["authorization"] = "Bearer " + self.token
        all_headers.update(headers or {})
        req = urllib.request.Request(
            self.api + path, data=data, method=method, headers=all_headers
        )
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                return resp.status, dict(resp.headers), resp.read().decode()
        except urllib.error.HTTPError as error:
            return error.code, dict(error.headers), error.read().decode()

    def login(self, credentials):
        email, password = credentials
        status, _, body = self.request(
            "POST", "/auth/login", {"email": email, "password": password}
        )
        if status != 200:
            raise SystemExit(f"login -> {status} {body}")
        self.token = json.loads(body)["accessToken"]

    def json(self, path):
        status, headers, body = self.request("GET", path)
        if status != 200:
            raise SystemExit(f"GET {path} -> {status} {body}")
        return headers, json.loads(body)

    def fake_id(self):
        """The contract stack's fake device. Exits when there is none: this
        Core is not a seeded contract stack (e.g. the shared dev stack), and
        nothing may be written to it."""
        _, page = self.json("/devices?limit=100")
        for device in page["items"]:
            if device["model"] == FAKE_MODEL:
                return device["id"]
        raise SystemExit(
            f"no {FAKE_MODEL} device: {self.api} is not a seeded contract "
            "stack (tools/dev-up.sh --contract --seed); refusing to run")


def now():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%H:%M:%S")


def etag(core):
    core.login(seeded("ADMIN"))
    for path in ["/devices?limit=100", "/devices/" + core.fake_id()]:
        status, headers, _ = core.request("GET", path)
        tag = headers.get("ETag")
        print(path, status, "ETag:", tag, "Cache-Control:",
              headers.get("Cache-Control"), "Last-Modified:",
              headers.get("Last-Modified"))
        if tag:
            status, headers, body = core.request(
                "GET", path, headers={"If-None-Match": tag})
            print("  If-None-Match ->", status, "body bytes:", len(body))


def statuses(core):
    core.login(seeded("USER"))
    _, page = core.json("/devices?limit=100")
    for d in page["items"]:
        print(d["name"], "|", d["status"], "|", d["connectivityState"], "|",
              d["communicationMode"], "|", d["currentState"], "|",
              d["activeFaultCount"], "|", d["lastSeenAt"])


def timeline(core, seconds):
    core.login(seeded("ADMIN"))
    device = core.fake_id()
    end = time.time() + seconds
    while time.time() < end:
        headers, detail = core.json("/devices/" + device)
        print(now(), "configurationVersion", detail["configurationVersion"],
              "lastSeenAt", detail["lastSeenAt"], "ETag", headers.get("ETag"),
              flush=True)
        time.sleep(10)


def schedule(core, seconds):
    core.login(owner())
    device = core.fake_id()
    # JS getDay() of today (UTC), shifted so the window never matches today.
    today = (datetime.datetime.now(datetime.timezone.utc).weekday() + 1) % 7
    status, _, body = core.request("POST", f"/devices/{device}/schedules", {
        "name": "S5 probe", "daysOfWeek": [(today + 3) % 7],
        "startTime": "06:00", "endTime": "07:00",
        "targetTemperatureCelsius": 50, "hysteresisCelsius": 3,
    })
    print(now(), "POST schedule ->", status)
    schedule_id = json.loads(body)["id"]
    try:
        end = time.time() + seconds
        while time.time() < end:
            _, detail = core.json("/devices/" + device)
            print(now(), "configurationVersion",
                  detail["configurationVersion"], "lastSeenAt",
                  detail["lastSeenAt"], "controlStrategy",
                  detail["controlStrategy"], flush=True)
            time.sleep(5)
    finally:
        status, _, _ = core.request(
            "DELETE", f"/devices/{device}/schedules/{schedule_id}")
        print(now(), "DELETE schedule ->", status)


def window(core):
    """S7: a schedule window of today, 2-4 minutes from now in UTC. If the
    gi-core process clock is UTC, the effective strategy switches to the
    schedule's target at the window start and back at its end."""
    core.login(owner())
    device = core.fake_id()
    utc = datetime.datetime.now(datetime.timezone.utc)
    start = (utc + datetime.timedelta(minutes=2)).strftime("%H:%M")
    end_at = (utc + datetime.timedelta(minutes=4)).strftime("%H:%M")
    today = (utc.weekday() + 1) % 7
    status, _, body = core.request("POST", f"/devices/{device}/schedules", {
        "name": "S7 window", "daysOfWeek": [today], "startTime": start,
        "endTime": end_at, "targetTemperatureCelsius": 40,
        "hysteresisCelsius": 2,
    })
    print(now(), f"POST schedule day={today} {start}-{end_at} (UTC) ->", status)
    schedule_id = json.loads(body)["id"]
    try:
        deadline = time.time() + 330
        last = None
        while time.time() < deadline:
            _, detail = core.json("/devices/" + device)
            strategy = detail["controlStrategy"]
            if strategy != last:
                print(now(), "controlStrategy", strategy, flush=True)
                last = strategy
            time.sleep(5)
    finally:
        status, _, _ = core.request(
            "DELETE", f"/devices/{device}/schedules/{schedule_id}")
        print(now(), "DELETE schedule ->", status)


def weather(core):
    core.login(owner())
    core.fake_id()  # Writes the house location: contract stack only.
    for path in ["/weather/current", "/pv/forecast"]:
        status, _, body = core.request("GET", path)
        print("before location", path, status, body[:160])
    status, _, _ = core.request("PATCH", "/settings/energy/location", {
        "latitude": 52.2297, "longitude": 21.0122,
        "timezone": "Europe/Warsaw", "currency": "PLN",
    })
    print("PATCH /settings/energy/location ->", status)
    for path in ["/weather/current", "/pv/forecast", "/solar/current"]:
        started = time.time()
        status, _, body = core.request("GET", path)
        print("after location", path, status,
              f"{time.time() - started:.1f} s", body[:160])


def ratelimit(core):
    # Uses up the login window: contract stack only.
    core.login(seeded("USER"))
    core.fake_id()
    core.token = None
    for attempt in range(1, 8):
        status, headers, body = core.request("POST", "/auth/login", {
            "email": "nobody@gihome.test", "password": "WrongPass123"})
        limits = {k: v for k, v in headers.items()
                  if k.lower().startswith(("x-ratelimit", "retry-after"))}
        print(attempt, status, limits, json.loads(body).get("code"))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("base_url")
    parser.add_argument("command", choices=[
        "etag", "statuses", "timeline", "schedule", "window", "weather",
        "ratelimit"])
    parser.add_argument("--seconds", type=int, default=150)
    args = parser.parse_args()
    core = Core(args.base_url)
    if args.command in ("timeline", "schedule"):
        globals()[args.command](core, args.seconds)
    else:
        globals()[args.command](core)


if __name__ == "__main__":
    main()
