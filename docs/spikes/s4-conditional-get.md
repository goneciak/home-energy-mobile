# Spike S4: conditional GET (ETag / 304)

Data: 2026-11-19. Backend: `8be59cd`. Stosy kontraktowe `s1457`, `s1v2`,
`s7w` (usunięte). Pytanie: czy `GET /devices` i `GET /devices/:id` zwracają
ETag i 304 na `If-None-Match` (§6.5 pkt 4, §24 p. 5). Od tego zależy praca
nad ETag w M3.

**Wynik: tak.** Oba endpointy zwracają słaby ETag i odpowiadają 304 z pustym
ciałem. Zysk jest jednak ograniczony: ETag urządzenia legacy zmienia się co
30 s bez udziału użytkownika (patrz niżej i [S5](s5-fixtures-quirks.md)).

## Jak powtórzyć

```powershell
# stos jak w S1: .\tools\dev-up.ps1 -Contract -RunId s4 -Seed (SDK z FVM na PATH)
cd packages\gi_core_api
$env:GI_CORE_URL = 'http://127.0.0.1:<port>'
dart test -t contract -r expanded test/contract/core_quirks_contract_test.dart -N "S4"
cd ..\..
python -I -X utf8 spikes/core_probe.py $env:GI_CORE_URL etag
python -I -X utf8 spikes/core_probe.py $env:GI_CORE_URL timeline --seconds 200
```

Test: `packages/gi_core_api/test/contract/core_quirks_contract_test.dart`,
grupa „S4 conditional GET” (wartości z prefiksem `S4`). Przebiegi: sam plik
na `s1457`, pełny zestaw na `s1457` i dwa razy na `s7w`. W pierwszym pełnym
przebiegu na `s7w` wariant `/devices/:id` dostał raz 200 zamiast 304, bo
urządzenie zmieniło się między dwoma żądaniami (równolegle biegnie test
przełączania przekaźnika, a co 30 s odpytanie legacy). Test powtarza teraz
parę żądań, gdy ETag się zmienił (do 5 prób); kolejny przebieg był zielony
za pierwszą próbą. Skrypt `spikes/core_probe.py` (tylko biblioteka
standardowa Pythona) zapisuje oś czasu.

## Wyniki

| Żądanie | Odpowiedź |
|---|---|
| `GET /api/v1/devices?limit=100` (Bearer ADMIN) | 200, `ETag: W/"f22-…"` (0xf22 = 3874 bajty, 4 urządzenia), brak `Cache-Control` i `Last-Modified` |
| to samo z `If-None-Match: <ten ETag>` | **304**, puste ciało, ten sam `ETag` |
| to samo z innym ETagiem (`W/"0-stale"`) | 200 z pełnym ciałem |
| `GET /api/v1/devices/:id` (urządzenie fake) | 200, `ETag: W/"7a5-…"` (1957 bajtów), brak `Cache-Control` i `Last-Modified` |
| to samo z `If-None-Match` | **304**, puste ciało |

- Format: `W/"<długość ciała hex>-<skrót base64>"`, czyli domyślny słaby
  ETag Expressa (`@nestjs/platform-express`). Kod GI Core nie ma własnej
  obsługi ETag (`grep -rni etag apps/gi-core/src` nic nie zwraca), więc to
  zachowanie frameworka, które może zniknąć np. przy zmianie platformy HTTP.
- ETag nie zależy od nagłówka `Authorization`: cache ETag musi być per
  profil i per użytkownik i czyszczony przy wylogowaniu i zmianie
  użytkownika (tak już mówi §7.3 i §7.8).

### Jak często ETag się zmienia

Oś czasu `timeline` (co 10 s, bez żadnych zmian użytkownika; stos `s1457`,
04:41:50–04:44:41 UTC): ETag szczegółów i listy zmieniał się przy każdym
odpytaniu urządzenia legacy, czyli co 30 s (`lastSeenAt` 04:41:31 → 04:42:01 →
04:42:31 → …, razem z `configurationVersion`). Test „configurationVersion and
the ETag change without any user change” potwierdza to w każdym przebiegu:
po 70 s warunkowy GET ze starym ETagiem daje 200.

## Decyzja dla M3

- Interceptor conditional GET (§6.5 pkt 4) **ma sens technicznie** i jest
  tani: 304 działa na obu endpointach.
- Oszczędność będzie mała: przy pollingu 2–30 s (§11) i zmianie co 30 s dla
  każdego urządzenia legacy z ustawioną strategią połowa lub więcej odpowiedzi
  i tak będzie 200; lista zmienia się, gdy zmieni się którekolwiek
  urządzenie. Częstotliwość zmian dla GI Edge (heartbeat) nie była mierzona.
- Rekomendacja: zostawić ETag w M3 jako niskopriorytetowy (głównie unikanie
  dekodowania i przebudowy UI przy 304), z testem kontraktowym S4 jako
  strażnikiem; nie budować na nim żadnej logiki poprawności.
