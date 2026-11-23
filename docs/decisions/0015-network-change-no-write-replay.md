# 0015. Zmiana sieci w trakcie sesji i brak ponawiania zapisów

- **Status:** Przyjęta (M4); zapasowy resolver mDNS domyślnie wyłączony do
  wyniku spike'a S3
- **Data:** 2026-11-22
- **Plan:** M4 (odporność sieci), §9.2, §9.3, §9.4, §11, ADR 0004, ADR 0008

## Kontekst

Do M3 aplikacja szukała przeniesionego urządzenia (nowy adres IP) tylko przy
przywracaniu sesji. Zmiana Wi-Fi albo adresu w trakcie pracy kończyła się
backoffem pollerów (5, 10, 30, 60 s), a każdy poller (lista, szczegóły, karty
ogrzewania) miał własny backoff, więc niedostępny host odpytywały trzy, cztery
niezależne harmonogramy. Sterowanie ogrzewaniem jest krytyczne dla
bezpieczeństwa: żądanie, które zerwało się w drodze, mogło zostać wykonane,
więc powtórzenie go po odzyskaniu łączności mogłoby zadziałać dwa razy.

## Decyzja

**Reakcja na zmianę sieci** (`NetworkRecovery`, startuje z korzenia aplikacji):

- Źródło zdarzeń to `NetworkChangeSource` (`connectivity_plus`, z atrapą w
  testach). Seria zdarzeń jest łączona w 500 ms. `connectivity_plus` zna
  rodzaj sieci (Wi-Fi, dane komórkowe, brak), nie jej nazwę, więc przejście
  z jednego Wi-Fi na drugie łapie niedostępność hosta (patrz niżej).
- Po zmianie: reset backoffu (`ReachabilityTracker.reset`), natychmiastowe
  odświeżenie wszystkich pollerów (`PollCoordinator.refreshAll`, tylko GET) i,
  równolegle, szukanie przeniesionego urządzenia (`ApplianceRebinder`, ta
  sama ścieżka co przy przywracaniu sesji: `ConnectionLadder.findMoved`).
- Przy powrocie na pierwszy plan resetujemy backoff; pollery odświeżają się
  same (z jitterem). Gdy host jest niedostępny, szukanie startuje samo, nie
  częściej niż raz na minutę. To obejmuje nowy adres po restarcie routera,
  którego żadne zdarzenie sieci nie zapowiada.
- Adres w profilu zmienia się wyłącznie po potwierdzeniu odcisku
  (`initializedAt`, ADR 0005); profil `https` nigdy nie jest przenoszony
  (brak degradacji do cleartextu, ADR 0004).

**Backoff dzielony per urządzenie** (`ReachabilityTracker`, jeden na profil):

- Niedostępny host jest sondowany jednym żądaniem naraz, według jednego
  harmonogramu 5, 10, 30, 60 s. Pozostałe pollery czekają na wynik próby i
  nie wysyłają nic; błąd próby publikują swoim ekranom (`onSharedFailure`),
  więc Home, lista i karta pokazują ten sam stan „brak połączenia”.
- Udana próba od razu budzi pozostałe pollery. Błąd, który nie
  mówi o osiągalności (403, 404, błąd kształtu), spowalnia tylko poller, który
  go dostał.
- `Retry-After` (sekundy albo data HTTP) z 429 i 503 zastępuje krok backoffu,
  jest ograniczony do 120 s i dostaje do 1 s jitteru. `ServerFailure` niesie
  teraz `retryAfter`, tak jak `RateLimitedFailure`.
- Ściągnięcie w dół (pull-to-refresh) i `pollNow` omijają kolejkę prób.

**Zapisy nigdy nie są ponawiane:**

- Zmiana sieci, ponowne połączenie i przeniesienie adresu uruchamiają wyłącznie
  GET-y: pollery, `findMoved` (`/health/live`, `/setup/status`) i sondy.
  Kontrolery poleceń (zawieszenie ogrzewania, przełącznik, strategia) mają
  własne pollery odczytu i nie ponawiają `PUT`/`PATCH`; wynik polecenia
  odczytujemy z urządzenia (heartbeat, flaga), nie wysyłając go ponownie.
- Klient nie ma interceptora ponawiania. Automatycznie powtarzane są tylko
  odczyty (`Endpoint.maxRetries` jest dozwolone wyłącznie dla GET, asercja w
  konstruktorze). Jedyny replay to żądanie odrzucone przez serwer kodem 401
  (token wygasł): AuthGuard odrzuca je przed handlerem, więc nic nie
  zostało wykonane, a replay jest jednorazowy, po odświeżeniu tokenu.
- Pilnują tego testy: `app/test/features/devices/no_write_replay_test.dart`
  (jedno żądanie zapisu na jedną akcję użytkownika przed zmianą sieci, w jej
  trakcie i po przeniesieniu adresu; w sieci tylko GET) oraz
  `packages/gi_core_api/test/no_write_retry_test.dart` (brak interceptora
  ponawiania, jedyny replay to 401).

**Zapasowy resolver mDNS** (`MulticastDnsHostResolver`, flaga `mdnsFallback`):

- Pytany dopiero po `SystemHostResolver`, tylko na Androidzie (iOS rozwiązuje
  `.local` samo) i tylko przy włączonej fladze. Zwraca adres IP, który i tak
  przechodzi potwierdzenie `/health/live` i odciskiem.
- Dodaje `CHANGE_WIFI_MULTICAST_STATE` do manifestu (blokada multicastu na czas
  jednego zapytania, `MainActivity`). Na iOS nic nie zmieniamy: bez
  `NSBonjourServices`, bez nowych wpisów.
- Flaga jest wyłączona we wszystkich flavorach (test pilnuje wartości
  domyślnej). Włączenie jej domyślnie zależy od wyniku S3 na fizycznych
  telefonach.

**NEARBY_WIFI_DEVICES** bez zmian: prośba tylko przy fladze
`androidLocalNetworkPermissionRequest` (ADR 0008), odmowa daje
`LocalNetworkDeniedFailure` z przyciskiem „Otwórz ustawienia”; testy w
`connect_screen_test.dart` i `local_network_permission_test.dart`.

## Konsekwencje

- Pozytywne: po zmianie sieci aplikacja wraca bez czekania na backoff;
  niedostępny host widzi jedno sondowanie zamiast kilku; Home, lista i karta
  pokazują ten sam stan.
- Negatywne: poller czekający na sondę nie wysyła własnych żądań, więc przez
  chwilę nie sprawdza, czy jego zasób odpowiada inaczej niż reszta. Błędy
  dotyczące tylko jednego zasobu (403, 404) nie wchodzą do wspólnego
  backoffu i działają jak dotąd.
- Do zrobienia na sprzęcie: S2 (cleartext i sieć lokalna, iPhone, Android 16),
  S3 (`.local`, iOS, Android 10/13/14/15, dwóch producentów) oraz decyzja, czy
  `mdnsFallback` ma być domyślnie włączony. Dopóki ich nie ma, nie
  twierdzimy, że zapasowy resolver działa na urządzeniach.
