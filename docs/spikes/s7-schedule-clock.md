# Spike S7: zegar harmonogramów

Data: 2026-11-19. Backend: `8be59cd`. Pytanie (§13.4, §24 p. 8, D8): w jakiej
strefie czasowej proces gi-core liczy okna harmonogramów
(`now.getHours()`/`getDay()` w `heating-schedule-reconciliation.service.ts`).

**Oczekiwane: UTC. Zaobserwowane: UTC** w stosie kontraktowym i w stosie dev;
granica okna harmonogramu przełącza się według UTC. Pi: wniosek z
konfiguracji (UTC), bez pomiaru na sprzęcie.

## Jak powtórzyć

```bash
# stos kontraktowy
C=$(docker compose -p gi-mobile-contract-<runId> ps -q gi-core)
docker exec $C date
docker exec $C sh -c 'echo "TZ=[$TZ]"; ls -l /etc/localtime; node -e "console.log(Intl.DateTimeFormat().resolvedOptions().timeZone, new Date().getTimezoneOffset())"'
docker inspect $C --format '{{range .Config.Env}}{{println .}}{{end}}' | grep '^TZ=' || echo "brak TZ"
# stos dev (tylko odczyt)
docker exec gi-core date
docker exec gi-core sh -c 'echo "TZ=[$TZ]"'
# granica okna (zapisuje harmonogram; tylko stos kontraktowy)
python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> window
```

## Wyniki

| Gdzie | `date` | `TZ` | Node | Jak |
|---|---|---|---|---|
| Stos kontraktowy `s1457`, 04:41:56 UTC | `Thu Nov 19 04:41:56 UTC 2026` | brak (zmienna pusta, nie ma jej w `Config.Env`); brak `/etc/localtime` i `/etc/timezone` | `UTC`, offset 0 | `docker exec` jak wyżej |
| Stos kontraktowy `s7w` | `Thu Nov 19 05:03:48 UTC 2026` | brak | – | `docker exec $C date` |
| Stos dev `gi-core` (`Up 33 hours`), 04:41:58 UTC | `Thu Nov 19 04:41:58 UTC 2026` | brak | `UTC`, offset 0 | `docker exec gi-core …` (tylko odczyt) |
| Pi | nie mierzono | `deploy/raspberry-pi/**` nie ustawia `TZ` ani nie montuje `/etc/localtime` (`grep -rn "TZ\|localtime" deploy infrastructure`: jedyne `TZ: Europe/Warsaw` ma `homeassistant` w `infrastructure/compose.yml:23`) | – | odczyt plików backendu |

Obraz bazowy to `node:22-alpine` (`apps/gi-core/Dockerfile`), bez `tzdata`,
więc bez `TZ` proces działa w UTC. Na Pi z tymi samymi obrazami i compose
oczekujemy UTC; potwierdzenie `docker exec <gi-core> date` na Pi zostaje na
liście sprzętowej.

### Granica okna (stos `s7w`)

`window` utworzył harmonogram na dziś (`daysOfWeek: [4]`, czwartek według
`getDay()` w UTC) z oknem **05:05–05:07 UTC**, cel 40 °C / 2 °C, przy
strategii bazowej `MANUAL 55/4`:

```
05:03:49 POST schedule day=4 05:05-05:07 (UTC) -> 201
05:03:49 controlStrategy {'mode': 'MANUAL', 'hysteresisCelsius': 4, 'targetTemperatureCelsius': 55}
05:05:00 controlStrategy {'mode': 'MANUAL', 'hysteresisCelsius': 2, 'targetTemperatureCelsius': 40}
05:07:00 controlStrategy {'mode': 'MANUAL', 'hysteresisCelsius': 4, 'targetTemperatureCelsius': 55}
05:09:21 DELETE schedule -> 204
```

Okno zadziałało o 05:05 i 05:07 **UTC** (06:05 i 06:07 czasu polskiego). Gdyby
proces liczył w `Europe/Warsaw` (domyślna strefa w `/settings/system`), okno
05:05–05:07 wypadłoby godzinę później. Ustawienie `timezone` w
`/settings/system` nie wpływa na harmonogramy (zgodnie z §13.4).

## Wnioski

- D8: domyślna etykieta zegara harmonogramów to **UTC** z podwójnym czasem
  („06:00 UTC = 07:00 czasu polskiego zimą / 08:00 latem”); konwersja do
  czasu domu tylko opt-in (flaga `scheduleClockConversion`, ADR
  [0008](../decisions/0008-feature-flags.md)).
- L17 potwierdzone dla Docker: godziny harmonogramów zapisane jako czas
  polski przesuną się o 1–2 h, jeśli użytkownik nie wie, że to UTC.
- Do zrobienia na sprzęcie: `date` w kontenerze gi-core na Pi i obserwacja
  granicy okna tam (część „Pi” procedury S7).
