# Spike S1: auth przez ciasteczko refresh

Data: 2026-11-19. Backend: `8be59cd` (`contract/backend.lock`). Stos:
`contract/compose.contract.yml` (projekty `gi-mobile-contract-s1457` i
`gi-mobile-contract-s7w`, oba usunięte przez `-Down`). Windows 11, Docker
Desktop, Flutter 3.50.0 / Dart 3.14 z FVM.

**Wynik: §7.4 potwierdzony; test kontraktowy refreshu zielony** (kryterium
wyjścia S1). Zachowanie serwera zgadza się z założeniami planu, z jednym
doprecyzowaniem: ciasteczko starsze niż poprzednie daje `INVALID`, nie
`REUSED`, i nie unieważnia sesji.

## Jak powtórzyć

```powershell
cd C:\home-energy-mobile
# seeder kompiluje się tylko SDK z FVM (Dart 3.14): dopisz go na początek PATH
$env:PATH = "$env:USERPROFILE\fvm\versions\3.50.0\bin;$env:PATH"
.\tools\dev-up.ps1 -Contract -RunId s1 -Seed      # wypisuje GI_CORE_URL i FAKE_ESPHOME_URL
cd packages\gi_core_api
$env:GI_CORE_URL = 'http://127.0.0.1:<port>'; $env:FAKE_ESPHOME_URL = 'http://127.0.0.1:<port>'
dart test -t contract -r expanded test/contract/session_rotation_contract_test.dart
dart test test/auth_session_manager_test.dart -N "process killed"
cd ..\..; .\tools\dev-up.ps1 -Contract -RunId s1 -Down
```

Test kontraktowy: `packages/gi_core_api/test/contract/session_rotation_contract_test.dart`
(tag `contract`, dwa logowania seedowanego USER-a; wartości drukowane z
prefiksem `S1`). Test jednostkowy ścieżki „śmierć procesu”:
`test/auth_session_manager_test.dart`, grupa `ensureFresh`, test „a process
killed between the refresh response and the vault write …”.

Przebiegi: sam plik (stos `s1457`) oraz trzy pełne `dart test -t contract`
(raz na `s1457`, dwa razy na `s7w`; 30 testów, w tym 1 pominięty: §9.3 bez
`GI_CORE_URL_B`). Testy S1 były zielone we wszystkich czterech; jeden pełny
przebieg na `s7w` miał niezwiązany błąd testu S4 (opisany w [S4](s4-conditional-get.md)).
Wyniki S1 były identyczne we wszystkich przebiegach. Pierwszy
przebieg samego pliku logował się jako OWNER; potem test przełączono na
seedowanego USER-a, bo `auth_flow_contract_test.dart` zmienia hasło
właściciela (co unieważnia jego inne sesje), a pliki biegną równolegle.

## Wyniki

### 50 refreshy po kolei

`AuthSessionManager.ensureFresh(force: true)` × 50 po jednym logowaniu:

| Pomiar | Wynik |
|---|---|
| Odpowiedzi | 50 × 200 |
| Różne wartości ciasteczka (z logowaniem) | 51 z 51 |
| Różne access tokeny | 51 z 51 |
| `generation` w sejfie | rośnie o 1 przy każdym refreshu |
| `absoluteExpiry` | nie przesuwa się (`Max-Age` = czas do końca 30-dniowej sesji; L3) |
| Czas refreshu (min / mediana / max) | 7 / 9 / 62 ms; w pełnych przebiegach 6 / 7 / 22 ms i 6 / 7 / 19 ms |

Refresh nie ma limitu żądań: w kodzie tylko `login` i `recovery/reset` mają
`ThrottlerGuard` (`apps/gi-core/src/modules/auth/auth.controller.ts:58-61,
99-102`); 50 refreshy w niecałą sekundę nie dało ani jednego 429.

### Podwójny refresh tym samym ciasteczkiem: REUSED

Pierwszy `POST /api/v1/auth/refresh` z ciasteczkiem C → 200 i rotowane C'.
Drugi z tym samym C → dokładnie ta koperta (pola i wartości stałe, `requestId`
i `timestamp` zmienne):

```json
{
  "statusCode": 401,
  "code": "AUTH_REFRESH_TOKEN_REUSED",
  "message": "Refresh token was already used.",
  "path": "/api/v1/auth/refresh",
  "requestId": "2d7806d0-7fb3-4ac3-b30e-d238580fa130",
  "timestamp": "2026-11-19T04:45:14.319Z"
}
```

- Odpowiedź z REUSED nie ma `Set-Cookie`.
- Serwer unieważnia **całą sesję**: C' (rotacja, która „wygrała”) → 401
  `AUTH_SESSION_REVOKED`, a access token wydany przed incydentem →
  `GET /auth/me` 401 `AUTH_SESSION_REVOKED` od razu, bez czekania na jego
  wygaśnięcie.
- Źródło: `auth.service.ts` (backend) porównuje skrót z
  `previousRefreshTokenHash` i woła `revokeReusedSession`; przegrana rotacja
  równoległa (`updateMany` z `count !== 1`) kończy się tak samo.

### Ciasteczko starsze niż poprzednie: INVALID, sesja żyje

Ciasteczko z logowania (generacja 0) po 50 rotacjach → 401
`AUTH_REFRESH_TOKEN_INVALID` (`message: "Refresh token is invalid."`), a
bieżące ciasteczko dalej działa (refresh 200, `GET /auth/me` 200). Serwer
pamięta tylko jeden poprzedni skrót, więc REUSED dotyczy wyłącznie
bezpośredniego poprzednika. Klient i tak traktuje `INVALID` jako utratę sesji
(`SessionLostReason.refreshTokenInvalid`) i czyści dane lokalne; dla
użytkownika skutek jest ten sam.

### Śmierć procesu między odpowiedzią refresh a zapisem do sejfu

Symulacja (test kontraktowy, część „login 2 of 2”): sejf, którego następny
zapis ciasteczka nigdy się nie kończy (`_DyingVault`), jak proces zabity w
trakcie zapisu.

1. Serwer odpowiedział 200 i rotowane ciasteczko dotarło do zapisu.
2. Nowy access token **nie został wydany** nikomu (write-ahead): przyszłość
   `ensureFresh` się nie zakończyła, a w sejfie zostało stare ciasteczko.
3. „Restart”: nowy klient z sejfem zawierającym stare ciasteczko,
   `session.restore()` → `AuthState.sessionLost(refreshTokenReused)`, sejf
   wyczyszczony, `GET /auth/me` nie został wysłany.
4. Serwer: ciasteczko, które „umarło” z procesem → 401
   `AUTH_SESSION_REVOKED`; access token sprzed incydentu → 401
   `AUTH_SESSION_REVOKED`.

Skutek: **jedno wymuszone logowanie, nigdy ciche odzyskanie** ani pętla
refreshy. To zgodne z §7.4 i L2; okno ryzyka to czas jednego zapisu w
Keychain/Keystore. Test jednostkowy z `FakeCore` sprawdza to samo
deterministycznie (kolejność: brak żądania z nowym tokenem, po restarcie
dokładnie jeden refresh ze starym ciasteczkiem i brak `/auth/me`).

## Limity żądań

| Co | Zaobserwowano | Jak |
|---|---|---|
| `POST /auth/login` | 5 prób na minutę na IP, **także nieudane**; odpowiedzi 1–5 mają `X-RateLimit-Limit: 5`, `X-RateLimit-Remaining: 4…0`, `X-RateLimit-Reset: 60`; szósta → 429 `HTTP_429`, `message: "ThrottlerException: Too Many Requests"`, nagłówek `Retry-After: 60` | 7 × `curl -d '{"email":"nobody@gihome.test","password":"WrongPass123"}' <GI_CORE_URL>/api/v1/auth/login` (stos `s1457`) i `python -I -X utf8 spikes/core_probe.py <GI_CORE_URL> ratelimit` (stos `s1v2`), ten sam wynik |
| `Retry-After` | sekundy do końca okna: 60 przy natychmiastowym przekroczeniu, 47 w S8 | j.w. oraz [S8](s8-contract-stack.md) |
| Wpływ na testy | pełny `dart test -t contract` robi 7 logowań (auth_flow 2, devices 2, core_quirks 1, session_rotation 2); w drugim pełnym przebiegu (stos `s7w`) wyniki S1 pojawiły się dopiero po 1:03, czyli plik czekał na `Retry-After` (`respectingLoginLimit`); pełne przebiegi trwały 71–74 s | `dart test -t contract` |
| `POST /auth/refresh` | brak limitu (patrz wyżej) | 50 refreshy |

## Wnioski dla aplikacji

- `AuthSessionManager` nie wymaga zmian: pojedynczy lot, write-ahead i
  mapowanie REUSED/INVALID/REVOKED zachowują się na żywo jak w testach
  jednostkowych.
- Komunikat po `SessionLostReason.refreshTokenReused` powinien mówić o
  ponownym logowaniu, nie o „naruszeniu bezpieczeństwa”: najczęstszą
  przyczyną będzie przerwany zapis albo zgubiona odpowiedź, nie kradzież.
- Limit logowania liczy też nieudane próby: odliczanie z `Retry-After` w
  formularzu logowania (§7.5) jest potrzebne, a telefony za jednym NAT
  dzielą limit (L24).
