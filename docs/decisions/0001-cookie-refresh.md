# 0001. Refresh token jako ręcznie obsługiwane ciasteczko, bez cookie jar

- **Status:** Przyjęta (M0). Potwierdzona spike'iem S1 ([wynik](../spikes/s1-auth-cookie.md)).
- **Data:** 2026-11-19
- **Plan:** §7.2, §7.3, §7.4, §21 (L1, L2, L5), spike S1

## Kontekst

GI Core wydaje refresh token wyłącznie jako ciasteczko `HttpOnly`
(`gi_refresh_token`, `Path=/api/v1/auth/refresh`, `Max-Age=2592000`). Nie ma
natywnego przepływu z tokenem w ciele odpowiedzi (L1), a backendu nie
zmieniamy. Rotacja nie ma okna łaski: ponowne użycie poprzedniego ciasteczka
unieważnia całą sesję (L2).

Gotowy `cookie_jar` (`dio_cookie_manager`) nie pasuje:

- wiąże ciasteczko z hostem, a profil musi przetrwać zmianę adresu
  (`gi-home.local` → IP, nowe IP po DHCP, §9.3);
- odrzuca ciasteczka `Secure` wysyłane przez `http` (Core w LAN to `http`);
- wysyłałby ciasteczko na każde żądanie do hosta, a przeglądarka wysyła je
  tylko na ścieżkę refresh;
- nie daje kontroli nad momentem zapisu, a zapis przed użyciem (write-ahead)
  jest jedyną obroną przed REUSED po śmierci procesu.

## Decyzja

Ciasteczko obsługujemy ręcznie w czysto-dartowym pakiecie `gi_core_api`:

- `RefreshCookieCodec.select` (`packages/gi_core_api/lib/src/auth/refresh_cookie.dart`)
  parsuje każdy `Set-Cookie` przez `dart:io Cookie.fromSetCookieValue`, wybiera
  ciasteczko o `Path` kończącym się na `/auth/refresh` (zapasowo po nazwie),
  waliduje wartość wyrażeniem `RefreshCookieCodec.valuePattern` i liczy
  `absoluteExpiry` z `Max-Age`. Brak ciasteczka po logowaniu to klientowy kod
  `REFRESH_COOKIE_MISSING`.
- `AuthSessionManager` (`lib/src/auth/auth_session_manager.dart`) jest jedynym
  kodem, który czyta i wysyła ciasteczko: nagłówek `Cookie:` tylko na
  `POST {cookie.path}`, własne `Dio` bez interceptora auth i bez CancelToken.
- Pojedynczy lot (`_inFlight` + `Lock`), zapis rotowanego ciasteczka do
  sejfu **przed** udostępnieniem nowego access tokenu, brak timerów (nic nie
  odświeża się w tle), stan „niejednoznaczny” po timeoutach i 5xx (następna
  próba dopiero po udanym `GET /health/live`).
- 401 `AUTH_REFRESH_TOKEN_REUSED` / `_INVALID` / `AUTH_SESSION_REVOKED` i 403
  `USER_DISABLED` czyszczą sesję z odpowiednim `SessionLostReason`.

To kompromis po stronie klienta, a nie prośba o zmianę backendu.

## Konsekwencje

- Pozytywne: sesja przeżywa zmianę adresu urządzenia; ciasteczko nigdy nie
  trafia poza ścieżkę refresh ani do hosta, który nie spełnia TransportPolicy
  (ADR [0004](0004-lan-transport-policy.md)); całe zachowanie jest testowalne
  bez Fluttera (`test/auth_session_manager_test.dart`, `test/refresh_cookie_test.dart`).
- Negatywne: utrzymujemy własny parser i własną logikę rotacji. Śmierć procesu
  między odpowiedzią refresh a zapisem kończy się jednym wymuszonym logowaniem
  (zmierzone w S1: serwer zgłasza `AUTH_REFRESH_TOKEN_REUSED` i unieważnia
  sesję). Okno jest zredukowane do czasu jednego zapisu w Keychain/Keystore,
  ale nie znika (L2).
- S1 pokazał dodatkowo, że ciasteczko starsze niż poprzednie daje
  `AUTH_REFRESH_TOKEN_INVALID` i **nie** unieważnia sesji; menedżer i tak
  czyści wtedy dane lokalne, więc nie ma różnicy dla użytkownika.
