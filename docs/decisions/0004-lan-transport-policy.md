# 0004. Transport tylko w LAN i TransportPolicy jako pierwszy interceptor

- **Status:** Przyjęta (M0), z odnotowanym odstępstwem od planu (10.0.2.2).
- **Data:** 2026-11-19
- **Plan:** §0 (Zdalny dostęp), §9.1, §9.2, §9.4, §9.6, §10, §21 (L13, L14, L22), D6, D17

## Kontekst

GI Core na Pi jest dostępny w sieci domowej przez `http://` na porcie 80
(L14); nie ma certyfikatu, stabilnego identyfikatora ani DNS-SD (L13). Zdalny
dostęp przez GI Cloud ma poważne ograniczenia (L22) i jest poza v1 (D6).
Jednocześnie aplikacja nie może wysyłać haseł ani ciasteczka w jawnym tekście
do dowolnego hosta w internecie.

## Decyzja

- v1 łączy się wyłącznie z urządzeniem GI Home w sieci lokalnej. Brak
  zdalnego dostępu, brak chmury, brak usług zewnętrznych.
- Drabina połączenia (`features/appliance/application/connection_ladder.dart`):
  zapamiętane hosty profilu (`GET /health/live`, 1,5 s) → `gi-home.local`,
  `gi-home-2…5.local` → zawsze widoczny wpis ręczny. Kandydat jest
  potwierdzony, gdy `health/live` zwraca 200 i `/setup/status` się parsuje
  (`ApplianceProbe`). Fallback `multicast_dns` czeka na S3.
- `TransportPolicy` (`packages/gi_core_api/lib/src/http/transport_policy.dart`)
  jest pierwszym interceptorem: `http://` tylko dla `localhost`, `*.local`,
  loopback, link-local, RFC 1918 i IPv6 ULA (`fc00::/7`); wszystko inne
  wymaga `https://`. Naruszenie to `InsecureTransportFailure` przed wysłaniem
  czegokolwiek, więc dane logowania i ciasteczko nigdy nie wychodzą do hosta
  spoza polityki. Brak cichego przejścia z https na http.
- Platformy: iOS `NSAllowsLocalNetworking` bez `NSAllowsArbitraryLoads`;
  Android `network_security_config.xml` z cleartext w `base-config` (wpis IP,
  D17) i zadeklarowane `NEARBY_WIFI_DEVICES` (`neverForLocation`), żądane w
  runtime tylko za flagą `androidLocalNetworkPermissionRequest` (ADR
  [0008](0008-feature-flags.md)).
- Uczciwość co do jawnego tekstu: jednorazowy komunikat przy potwierdzeniu
  adresu `http://` (`ApplianceProfile.cleartextNoticeShown`) i logger, który
  redaguje `cookie`, `set-cookie` i `authorization`.

### Odstępstwo: 10.0.0.0/8, w tym `10.0.2.2`, we wszystkich flavorach

Plan (§9.4) dopuszcza `10.0.2.2` „tylko w flavorze dev”. Adres emulatora
Androida leży jednak w RFC 1918 (`10.0.0.0/8`), a prawdziwe sieci domowe
używają podsieci `10.x`. Zakaz w beta i prod zablokowałby takie domy, więc
`TransportPolicy` nie przyjmuje flavoru i traktuje cały `10/8` jednakowo. Wygody
deweloperskie (preset `http://10.0.2.2:3000`) żyją tylko w flavorze dev
aplikacji. Uzasadnienie jest też w komentarzu klasy `TransportPolicy`.

## Konsekwencje

- Pozytywne: jedna, czysta funkcja polityki ze 100% gałęzi w testach
  (`test/transport_policy_test.dart`); brak zależności od zewnętrznych usług.
- Negatywne: ruch w LAN nie jest szyfrowany i urządzenia nie da się
  uwierzytelnić (L14); deklarujemy to w Data safety („encrypted in transit:
  No”) i w polityce prywatności (`site/privacy.md`). Telefon poza domem nie
  ma dostępu do urządzenia.
- Do potwierdzenia na sprzęcie: zachowanie ATS/NSC z `dart:io` i odmowa sieci
  lokalnej (S2), rozwiązywanie `.local` (S3).
