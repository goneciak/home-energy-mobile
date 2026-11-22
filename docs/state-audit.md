# Audyt stanów ekranów

Każdy ekran aplikacji pokazuje te same stany w ten sam sposób: ludzkim
językiem i, gdy to możliwe, z następnym krokiem dla użytkownika. Wymaganie
pochodzi z języka stanów produktu (loading, no data yet, waiting for
telemetry, offline, stale, unknown, error, maintenance, resolved) i jest
uzupełnione o stany ogrzewania: dry-run i suspended. Etykieta „nie
zgłoszono" jako ślepy zaułek jest niedozwolona; zamiast niej mówimy, na co
czekamy albo co zrobić.

Dokument jest sprawdzany testem `app/test/tooling/state_audit_doc_test.dart`:
wszystkie klucze tekstów zapisane jako l10n.klucz w znakach cytatu muszą istnieć w obu plikach ARB,
a w tekstach nie ma etykiet bez następnego kroku.

## Macierz: ekran i stan

Znaczenie komórek: **tak** to stan, który ekran pokazuje (szczegóły w
sekcji „Stany"); „nie dotyczy" oznacza, że do stanu nie da się dojść na
tym ekranie: z natury ekranu (formularz, ekran z danymi lokalnymi) albo z
powodu podanego w komórce. Nie ma komórek z nierozwiązaną luką.

| Ekran | loading | no data yet | waiting for telemetry | offline | stale | unknown | error | maintenance | resolved | dry-run | suspended |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Dom | tak | tak | tak | tak | tak | tak | tak | tak | nie dotyczy: rozwiązane wpisy są w „Uwaga" | tak | tak |
| Szczegóły urządzenia | tak | tak | tak | tak | tak | tak | tak | tak | nie dotyczy: jak wyżej | tak | tak |
| Karta ogrzewania | tak | tak | tak | tak | tak | tak | tak | tak | nie dotyczy: jak wyżej | tak | tak |
| Sterowanie (przełączniki, wstrzymanie) | tak | nie dotyczy: panel jest tylko przy istniejącym elemencie | tak | tak | tak | tak | tak | tak | tak | tak | tak |
| Harmonogramy | tak | tak | nie dotyczy: lista należy do GI Home, nie do czujnika | tak | nie dotyczy: lista jest pobierana na żądanie, bez odświeżania w tle; po nieudanym odświeżeniu pokazuje baner offline | nie dotyczy: harmonogram ma zawsze znany stan | tak | tak | nie dotyczy | nie dotyczy: tryb testowy dotyczy poleceń, nie listy | tak |
| Harmonogram: edytor | tak | nie dotyczy: formularz | nie dotyczy | tak | nie dotyczy | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | tak |
| Historia | tak | tak | nie dotyczy: historia pokazuje to, co zapisano | tak | nie dotyczy: dane są pobierane przy otwarciu okna, bez odświeżania w tle | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | nie dotyczy |
| Uwaga | tak | tak | tak | tak | tak | tak | tak | tak | tak | tak | tak |
| Pogoda i PV | tak | tak | nie dotyczy: dane pochodzą z prognozy, nie z czujnika | tak | tak | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | nie dotyczy |
| Ustawienia | nie dotyczy: ekran czyta tylko dane lokalne | nie dotyczy | nie dotyczy | nie dotyczy: wiersze z GI Home (wersja, strefa) są opcjonalne i znikają bez błędu | nie dotyczy | nie dotyczy | nie dotyczy: akcje (wylogowanie, zmiana urządzenia) pokazują komunikat w pasku | nie dotyczy | nie dotyczy | nie dotyczy | nie dotyczy |
| Konto (profil) | tak | nie dotyczy | nie dotyczy | tak | nie dotyczy | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | nie dotyczy |
| Sesje | tak | tak | nie dotyczy | tak | nie dotyczy | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | nie dotyczy |
| Kod odzyskiwania i reset | tak | nie dotyczy | nie dotyczy | tak | nie dotyczy | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | nie dotyczy |
| Logowanie | tak | nie dotyczy | nie dotyczy | tak | nie dotyczy | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | nie dotyczy |
| Przywracanie sesji | tak | nie dotyczy | nie dotyczy | tak | tak | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | nie dotyczy |
| Znajdź GI Home | tak | tak | nie dotyczy | tak | nie dotyczy | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | nie dotyczy |
| Dokończ konfigurację | nie dotyczy: ekran sprawdza stan na żądanie | nie dotyczy | tak | tak | nie dotyczy | nie dotyczy | tak | tak | tak | nie dotyczy | nie dotyczy |
| Zmiana hasła | tak | nie dotyczy | nie dotyczy | tak | nie dotyczy | nie dotyczy | tak | tak | tak | nie dotyczy | nie dotyczy |

Ekran „Funkcje eksperymentalne" (tylko dev i beta) nie ma żadnego z tych
stanów: czyta wyłącznie lokalne ustawienia.

## Stany

Każdy stan ma wspólny widżet, tekst (klucz w obu językach) i następny krok.

### loading

- Widżet: `LoadingView`, szkielety kart (`Skeleton`), pasek postępu wyszukiwania.
- Tekst: `l10n.commonLoading`, `l10n.restoreConnecting`, `l10n.heatingCardLoading`, `l10n.historyChartLoading`.
- Następny krok: brak, bo postęp widać; pociągnięcie w dół odświeża.
- Testy: `home_screen_test`, złote `account_sessions_loading`, `session_restore_connecting`.

### no data yet

- Widżet: `EmptyState` z ikoną, tytułem i wskazówką.
- Tekst: `l10n.homeEmptyTitle`, `l10n.homeEmptyBody`, `l10n.schedulesEmptyTitle`, `l10n.schedulesEmptyBody`, `l10n.historyEmptyTitle`, `l10n.historyEmptyBody`, `l10n.attentionEmptyTitle`, `l10n.attentionEmptyBody`, `l10n.sessionsEmpty`, `l10n.weatherNoDataTitle`, `l10n.pvForecastNoDataTitle`, `l10n.deviceEntitiesEmpty`, `l10n.heatingStrategyNone`.
- Następny krok: wskazówka mówi, gdzie dodać dane (panel web GI Home) albo że wystarczy poczekać.
- Testy: złote `home_empty`, `schedules_empty`, `history_empty`, `attention_empty`.

### waiting for telemetry

- Widżet: chip na karcie ogrzewania, `FreshnessLabel`, wynik polecenia w panelu przełącznika.
- Tekst: `l10n.heatingCardControllerUnknown` (czekamy na dane ze sterownika), `l10n.freshnessWaitingForReading`, `l10n.attentionNoData`, `l10n.switchValueAwaitingReport`, `l10n.entitySwitchAwaitingReport`, `l10n.switchCommandAwaitingHeartbeat`, `l10n.suspendAppliedAwaitingHeartbeat`.
- Następny krok: nic nie trzeba robić, odczyt jest odpytywany dalej; „Odśwież" jest zawsze pod ręką.
- Testy: `heating_card_test`, `shared_components_test`, złote `switch_awaiting_heartbeat`.

### offline

- Widżet: `FreshnessBanner` nad ostatnimi danymi, `OfflineSnapshotView` przy starcie bez sieci, `ErrorState` przy pierwszym ładowaniu.
- Tekst: `l10n.offlineBannerSince`, `l10n.offlineSnapshotReadOnly`, `l10n.schedulesOfflineBanner`, `l10n.errorUnreachable`, `l10n.connectivityOffline`.
- Następny krok: „Spróbuj ponownie" (`l10n.actionRetry`), przy odmowie dostępu do sieci lokalnej przycisk do ustawień telefonu, na starcie także „Znajdź GI Home".
- Testy: złote `home_offline_stale`, `schedules_offline`, `session_restore_unreachable`, `account_sessions_error`; audyt semantyki `semantics_audit_test`.

### stale

- Widżet: `FreshnessBanner`, `FreshnessLabel`, blokada przełącznika, baner prognozy.
- Tekst: `l10n.staleDataBanner`, `l10n.connectivityStale`, `l10n.freshnessUpdatedStale`, `l10n.lockStaleData`, `l10n.weatherStaleBanner`.
- Następny krok: odświeżenie; polecenia sterujące są zablokowane, dopóki dane nie są świeże.
- Testy: złote `detail_stale`, `heating_card_stale`, `weather_stale`, `switch_stale_lock`.

### unknown

- Widżet: chip stanu, wynik polecenia bez potwierdzenia.
- Tekst: `l10n.connectivityUnknown`, `l10n.firmwareStateUnknown`, `l10n.productStatusUnknown`, `l10n.errorCommandUnconfirmed`, `l10n.switchCommandTimedOut`.
- Następny krok: „Odśwież widok" i sprawdzenie stanu przed kolejną próbą; aplikacja nigdy nie zakłada, że przekaźnik się przełączył.
- Testy: złote `switch_timed_out`, `switch_failed_unconfirmed`.

### error

- Widżet: `ErrorState` (pierwsze ładowanie), `MessageBanner` (formularze i odświeżanie).
- Tekst: `failureMessage` dobiera komunikat do rodzaju błędu, np. `l10n.errorUnreachable`, `l10n.errorTimeout`, `l10n.errorServer`, `l10n.errorForbidden`; kod zgłoszenia pokazuje `l10n.errorRequestId`.
- Następny krok: „Spróbuj ponownie", a przy błędzie dostępu do sieci lokalnej przycisk otwierający ustawienia telefonu.
- Testy: złote `login_error`, `weather_failures`, `account_sessions_error`; audyt `semantics_audit_test` (ogłoszenie błędu czytnikowi ekranu).

### maintenance

- Widżet: ten sam co błąd; odpowiedź 503 z GI Home jest rozpoznawana jako uruchamianie albo konserwacja.
- Tekst: `l10n.errorMaintenance`. Aktualizacja samej aplikacji ma własny ekran: `l10n.staleAppTitle`, `l10n.staleAppBody`.
- Następny krok: „Spróbuj ponownie" za kilka minut; przy starej aplikacji „Otwórz sklep".
- Testy: `failure_messages_test` (503), `stale_app_test`.

### resolved

- Widżet: sekcja „Rozwiązane w ciągu 24 h" na ekranie Uwaga; wynik wykonanego polecenia (potwierdzone wstrzymanie, zaobserwowany raport sterownika); koniec konfiguracji i zmiana hasła.
- Tekst: `l10n.attentionSectionResolved`, `l10n.attentionResolvedAt`, `l10n.switchCommandHeartbeatObserved`, `l10n.suspendAppliedOutputsOff`.
- Następny krok: brak, to potwierdzenie; wpis prowadzi do urządzenia.
- Testy: złoty `attention_list`, `switch_heartbeat_observed`.

### dry-run

- Widżet: znaczek i baner trybu testowego na Dom, w szczegółach i w sterowaniu.
- Tekst: `l10n.badgeDryRun`, `l10n.dryRunBanner`, `l10n.heatingDryRunBanner`, `l10n.switchCommandDryRunRecorded`, `l10n.consequenceDryRunOutputsStayOff`.
- Następny krok: informacja, że polecenia są zapisywane, a przekaźniki zostają wyłączone; wyjście z trybu testowego odbywa się w panelu web.
- Testy: złote `detail_dry_run`, `heating_card_dry_run`, `switch_dry_run_recorded`.

### suspended

- Widżet: znaczek, baner, blokada przełączników i ustawień.
- Tekst: `l10n.badgeHeatingSuspended`, `l10n.heatingSuspendedBanner`, `l10n.heatingSuspendedTitle`, `l10n.heatingSuspendedResumeHint`, `l10n.heatingSuspendedAskOwner`, `l10n.lockSuspendedOnRequest`.
- Następny krok: „Wznów ogrzewanie" (długie przytrzymanie), a dla roli bez uprawnień wskazówka, kogo poprosić.
- Testy: złote `detail_suspended`, `heating_card_suspended`, `heating_resume_sheet`.

## Dostępność

- Rozmiar tekstu 200%, przyciski co najmniej 48 dp i kontrast sprawdza każdy
  złoty test ekranu (`screenGoldens`) na trzech rozmiarach, w dwóch językach
  i przy skali tekstu 1,0, 1,3 i 2,0. Nowe złote ekrany: Ustawienia,
  Przywracanie sesji, Zmiana hasła, Dokończ konfigurację, Funkcje
  eksperymentalne, Sesje (ładowanie i błąd), Harmonogramy offline.
- Etykiety sterowania, kolejność nagłówków i regiony na żywo sprawdza
  `app/test/a11y/semantics_audit_test.dart`; wspólny pomocnik to
  `app/test/support/semantics.dart`. Stan, który pojawia się bez działania
  użytkownika (brak połączenia, nieaktualne dane, błąd, postęp polecenia),
  jest regionem na żywo we wspólnych widżetach (`MessageBanner`,
  `ErrorState`), nie na pojedynczych ekranach.
- Odsłuch z czytnikiem ekranu po polsku wykonuje człowiek na telefonie;
  lista kontrolna jest w procedurze wydania.
