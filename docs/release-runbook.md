# Runbook wydań GI Home Mobile

Szkielet procedury wydania (plan §19.3, §19.4, D12). Wypełniamy go w M1–M4, w miarę
jak zapadają decyzje D4 (konto Google Play) i D5 (bundle ID, konta Apple).

## 0. Zanim zaczniesz

- Sekrety są wyłącznie w CI: GitHub Actions secrets, grupy zmiennych Codemagic albo
  zmienne środowiskowe na Macu osoby wydającej (fastlane). Nigdy w repo. Lista nazw:
  README, sekcja „CI/CD”.
- Bundle ID to wciąż placeholdery (D5): `GI_IOS_BUNDLE_ID` i `GI_ANDROID_PACKAGE_NAME`
  muszą wskazywać aplikacje założone w App Store Connect i Play Console.
- Klucz uploadu Androida (`*.jks`) jest u właściciela i w sekretach CI. Play App Signing
  trzyma klucz aplikacji; zgubiony klucz uploadu resetuje się w Play Console.

## 1. Kandydat do wydania

1. `main` jest zielony: `ci.yml` (format, zakaz `TODO(backend)`, codegen aktualny,
   analiza, testy, bramka pokrycia, goldeny), ostatni nocny `contract.yml` i `e2e.yml`.
2. Ręczna lista sprzętowa z plan §17.1 przeszła (Pi, iOS i 2 producentów Androida,
   potwierdzanie GI_EDGE na prawdziwym sterowniku, VoiceOver/TalkBack po polsku).
3. Wersja w `app/pubspec.yaml` (`version: X.Y.Z+N`) podniesiona w PR. Numer builda
   nadają pipeline'y (numer przebiegu CI / kolejny numer TestFlight).

## 2. Tag `v*` i zapis refu backendu

1. Tag na zmergowanym commicie: `git tag -a vX.Y.Z -m "GI Home X.Y.Z"`, potem
   `git push origin vX.Y.Z`.
2. Tag uruchamia:
   - `.github/workflows/build.yml`: pełne `ci.yml`, AAB prod podpisany kluczem uploadu
     (brak sekretu = błąd builda, bez cichego podpisu debug), kontrola wyrównania 16 KB,
     build iOS bez podpisu;
   - `codemagic.yaml`: `ios-testflight-internal` i `android-play-internal`
     (albo ręcznie `bundle exec fastlane ios internal_ios` /
     `bundle exec fastlane android internal_android`).
3. **Ref backendu:** każdy pipeline wydania kopiuje `contract/backend.lock` (SHA GI Core,
   przeciw któremu przeszły testy kontraktowe) do artefaktów wydania
   (`release-info/` w Codemagic, `build/release-info/` w fastlane, obok AAB w
   `build.yml`). Ten sam SHA wpisz w notatki wydania:

   | Wydanie | Data | Commit aplikacji | Ref backendu (`backend.lock` sha) | Uwagi |
   |---|---|---|---|---|
   | vX.Y.Z | RRRR-MM-DD | `…` | `…` | |

## 3. Testy wewnętrzne

- iOS: build trafia do TestFlight, grupa testerów wewnętrznych z automatyczną
  dystrybucją. Bez Beta App Review.
- Android: ścieżka „Internal testing” w Play. Pierwsze wydanie nowej aplikacji idzie
  jako szkic (`submit_as_draft` / `GI_PLAY_RELEASE_STATUS=draft`), dopóki karta
  aplikacji nie jest kompletna.
- Testerzy zewnętrzni i recenzenci bez Pi używają trybu demo (plan §19.5).
- **Odstępstwo od plan §19.2:** obie ścieżki dostają build **prod**, nie
  `beta`, więc testerzy nie mają ekranu „Funkcje eksperymentalne” ani
  nadpisań flag. Ścieżki beta jeszcze nie ma (osobna karta Play dla
  `.beta`, D4/D5; schematy iOS na macOS); szczegóły i decyzja do podjęcia:
  [store-and-product-decisions.md](decisions/store-and-product-decisions.md),
  „Kanały testowe dostają build prod”.

### 3.1 Notatka dla recenzentów: tryb demo (App Review, Play)

Wklejamy do „App Review Information → Notes” (App Store Connect, także Beta App
Review) i do „App access” w Play Console. Przy każdym wydaniu sprawdzamy, czy tekst
nadal zgadza się z aplikacją (plan §19.5, Guideline 2.3.1: żadnych ukrytych funkcji).

> GI Home controls a GI Home appliance on the user's home network (LAN). The
> appliance is a physical device that reviewers cannot reach, so the app has a
> built-in demo mode that needs no account, no network and no hardware.
>
> How to use it: on the first screen ("Connect to GI Home" / „Połącz z GI Home”)
> tap the visible button "Try the demo" („Wypróbuj wersję demonstracyjną”). The
> app opens a sample home, signed in as its owner. A permanent "DEMO" banner is
> shown on every screen while the demo runs; "Exit demo" („Zakończ demo”) in that
> banner returns to the first screen and erases all demo data.
>
> What can be tried: home overview, device details, switching a non-heating
> output (the confirmation arrives a few seconds later, like with real
> hardware), holding the button to suspend heating, resuming it with the
> consequence sheet, and editing the heating setting.
>
> The demo data is bundled with the app and kept only in memory. In demo mode
> the app opens no network connection, stores no credentials and does not
> change a connected appliance. No login credentials are needed.

Polski skrót dla zespołu: wejście to widoczny przycisk na ekranie łączenia;
tryb działa w procesie (`DemoHttpClientAdapter`, bez gniazda localhost),
z danymi z `app/assets/demo_fixtures/demo_core.json`; nic nie trafia do secure
storage ani do zapisanego profilu urządzenia.

### 3.2 Lista kontrolna dystrybucji wewnętrznej (koniec M2, plan §19.7, D4)

**Lokalnie, przed tagiem (Windows, bez sekretów):**

- [ ] `flutter build apk --release --flavor prod -t lib/main.dart --dart-define-from-file=config/prod.json`
      (w `app/`, SDK z FVM). Bez `GI_UPLOAD_*` gradle podpisuje kluczem debug:
      to artefakt do instalacji ręcznej (`adb install`), **nie** do Play.
      Sprawdzone 2026-11-21: `app-prod-release.apk` (~57 MB) buduje się na
      Windows bez konfiguracji podpisu.
- [ ] Ten sam build z `GI_REQUIRE_RELEASE_SIGNING=true` i bez klucza **musi**
      się wysypać (strażnik w `app/android/app/build.gradle.kts`); w CI tak
      działają `build.yml`, Codemagic i fastlane.
- [ ] Instalacja APK na telefonie w LAN z Pi: logowanie, Dom, szczegóły,
      wstrzymanie i wznowienie ogrzewania, tryb demo (§3.1).
- [ ] Przegląd bezpieczeństwa aktualny: [safety-review.md](safety-review.md)
      (każdy wiersz ma kod i test), ADR [0009](decisions/0009-switch-confirmation-semantics.md).

**iOS: TestFlight, testerzy wewnętrzni**

- [ ] Aplikacja w App Store Connect z bundle ID (D5) i `GI_IOS_BUNDLE_ID`.
- [ ] Grupa „Internal” (do 100 osób z rolą w zespole), automatyczna dystrybucja.
- [ ] Notatka trybu demo (§3.1) w „Test Information”; Beta App Review dopiero
      przy testerach zewnętrznych.
- [ ] Export compliance: `ITSAppUsesNonExemptEncryption=NO` (plan §19.7 pkt 3).

**Android: Play, internal testing albo closed testing**

- [ ] Typ konta Play (D4) rozstrzygnięty:
  - konto organizacji: wystarczy ścieżka *Internal testing* (do 100 testerów);
  - **konto osobiste:** potrzebny *Closed testing* z **co najmniej 12
    testerami zapisanymi nieprzerwanie przez 14 dni** przed wnioskiem o
    dostęp produkcyjny. Otwieramy go pod koniec M2; testerzy bez Pi używają
    trybu demo. Zapisz datę startu: _____ (koniec okna = start + 14 dni, w M3).
- [ ] Lista testerów (Google Group lub e-maile) i link do zapisu rozesłany.
- [ ] Pierwsze wydanie jako szkic (`GI_PLAY_RELEASE_STATUS=draft`), dopóki
      karta aplikacji, Data safety („encrypted in transit: No”) i App access
      (notatka demo z §3.1) nie są kompletne.
- [ ] Polityka prywatności z `site/` opublikowana i podlinkowana.

**Tryb demo dla recenzentów (§3.1)**

- [ ] Przycisk „Wypróbuj wersję demonstracyjną” widoczny na ekranie łączenia
      w buildzie prod; baner „DEMO” na każdym ekranie; „Zakończ demo” czyści dane.
- [ ] W demo nie ma ruchu sieciowego (sprawdź w trybie samolotowym).
- [ ] Tekst notatki zgadza się z tym, co da się zrobić w demo (przełącznik
      nie-grzewczy, wstrzymanie przytrzymaniem, wznowienie z arkuszem,
      edycja nastawy).

## 4. Produkcja: stopniowe wdrażanie jako wyłącznik awaryjny

Stopniowe wdrażanie jest naszym jedynym wyłącznikiem (aplikacja nie ma zdalnej
konfiguracji, plan §19.6).

- **App Store:** wydanie z włączonym *phased release* (7 dni: 1%, 2%, 5%, 10%, 20%, 50%,
  100%). Użytkownicy z ręczną aktualizacją dostają wersję od razu.
- **Google Play:** *staged rollout* 10% → 50% → 100%; każdy krok po co najmniej 24 h bez
  sygnałów z sekcji 5.

## 5. Zatrzymanie (halt)

Sygnały: zgłoszenia „nie mogę sterować ogrzewaniem”, błędy logowania, raporty
diagnostyczne od użytkowników (plan §8.4), awarie w Play Console / Xcode Organizer.

1. **Zatrzymaj wdrażanie:**
   - App Store Connect → wersja → *Pause Phased Release* (do 30 dni);
   - Play Console → Wersje → *Halt rollout*.
2. Oceń: problem po stronie aplikacji czy Core? Porównaj ref backendu z tabeli w
   sekcji 2 z wersją Core na Pi zgłaszającego.
3. Napraw na `main`, nowy tag z podniesionym numerem builda, wdrożenie od początku.
   Sklepy nie pozwalają cofnąć wersji: „rollback” to nowa wersja ze starszym kodem.
4. Wznów wdrażanie poprzedniej wersji tylko, jeśli problem okazał się zewnętrzny.

## 6. Po wydaniu

- Uzupełnij tabelę z sekcji 2.
- Jeśli przypięty ref backendu się zmienia (D15), zrób to osobnym PR z ponownie
  nagranymi fixture'ami (`contract/backend.lock`).

## 7. Kalendarz M4 i śledzenie czasu oczekiwania

Terminy zależą od sklepów i testerów, więc tabela zawiera przesunięcia względne
(T = dzień wysłania pierwszego buildu do testerów wewnętrznych), a nie daty.
Kolumny „Data faktyczna”, „Status” i „Dowód” uzupełnia osoba odpowiedzialna po
każdym kroku. Role to symbole: **Właściciel** (konta sklepowe, treści prawne),
**Dev** (build i wydanie), **QA** (testy ręczne), **Koordynator bety**
(program z sekcji 8).

| Krok | Rola | Najwcześniejszy start | Oczekiwany czas | Data faktyczna | Status | Dowód |
|---|---|---|---|---|---|---|
| Play: zamknięty test (12 testerów) | Dev, Właściciel | T | 14 dni nieprzerwanie | | | |
| TestFlight, testerzy wewnętrzni | Dev | T | do kilku godzin przetwarzania | | | |
| Lista kontrolna wydania, ścieżki czytników ekranu | QA | T + 3 dni | 1–2 dni pracy | | | |
| Beta z gospodarstwami (sekcja 8) | Koordynator bety | T + 3 dni | co najmniej 14 dni | | | |
| TestFlight, testerzy zewnętrzni (Beta App Review) | Dev | T + 3 dni | zwykle 1–2 dni | | | |
| Play: wniosek o dostęp produkcyjny | Właściciel | koniec 14-dniowego testu | do kilku dni | | | |
| App Review | Dev, Właściciel | po zamknięciu listy kontrolnej | zwykle 1–3 dni plus bufor na odrzucenie | | | |
| Pętla odrzucenia (jeśli wystąpi) | Dev | dzień odrzucenia | 1–3 dni na poprawkę i ponowne zgłoszenie | | | |
| Play: wdrożenie etapowe 10% → 50% → 100% | Dev | po akceptacji | min. 24 h między krokami | | | |
| App Store: wydanie etapowe | Dev | po akceptacji | 7 dni | | | |

Zasady prowadzenia tabeli:

- Kopię tabeli prowadzimy w zgłoszeniu wydania; każdy krok z czasem
  oczekiwania ma datę wysłania i datę odpowiedzi.
- Treści zgłoszeń i odpowiedzi odnotowujemy w
  [dzienniku zgłoszeń](templates/store-submission-log.md), odpowiedzi na
  odrzucenia według [szablonu](templates/rejection-response-template.md).
- Zgłoszenie do sklepu wymaga zamkniętej [listy kontrolnej wydania](release-checklist.md)
  oraz materiałów z [docs/store](store/review-notes.md).

## 8. Program beta: 3–5 gospodarstw na prawdziwych Raspberry Pi

### 8.1 Dobór uczestników

- Gospodarstwo z działającym GI Core na Raspberry Pi w tej samej sieci Wi-Fi co
  telefon i z co najmniej jednym urządzeniem grzewczym.
- Mieszanka platform (co najmniej jedno gospodarstwo z iPhone'em i jedno z
  Androidem) i wersji Androida.
- Osoba z rolą właściciela lub administratora, gotowa raz w tygodniu przesłać
  raport.
- Przynajmniej jedno gospodarstwo z więcej niż dwoma urządzeniami grzewczymi,
  żeby sprawdzić budżet żądań na ekranie Dom.

### 8.2 Wdrożenie uczestnika

1. Zaproszenie do TestFlight (iOS) albo do zamkniętego testu w Google Play
   (Android).
2. Instalacja aplikacji i połączenie z GI Home zgodnie z opisem na ekranie
   łączenia.
3. Zgoda na raporty diagnostyczne: uczestnik dostaje link do polityki
   prywatności ([site/privacy.md](../site/privacy.md)) i potwierdza, co raport
   zawiera. Raport nie zawiera haseł, tokenów ani kodów odzyskiwania.
4. Krótka rozmowa kontrolna po pierwszym dniu: czy aplikacja znalazła
   urządzenie, czy logowanie przeszło bez pytań o hasło.

### 8.3 Cotygodniowy raport

Uczestnik wysyła raport diagnostyczny z aplikacji raz w tygodniu, koordynator
wypełnia [tygodniowy raport bety](templates/weekly-beta-report.md) (po jednym
wierszu na gospodarstwo). Znaczenie pól:

| Pole | Znaczenie |
|---|---|
| Wersja aplikacji | numer wersji i builda z ekranu Ustawienia |
| Wersja firmware | wersja sterownika w szczegółach urządzenia |
| Dni aktywności | liczba dni z co najmniej jedną sesją w aplikacji |
| Awarie | zgłoszenia z Play Android vitals lub Xcode Organizer plus zgłoszone ręcznie |
| Wymuszone ponowne logowania | sesje zakończone koniecznością podania hasła z powodu klienta (ponowne użycie tokenu odświeżania, niejednoznaczny refresh) |
| Nieudane połączenia | próby połączenia z urządzeniem zakończone błędem, wraz z przyczyną |
| Obserwacje obciążenia | wrażenia o szybkości, liczba telefonów używanych jednocześnie, panel www otwarty lub nie |

### 8.4 Metryki

| Metryka | Definicja | Próg |
|---|---|---|
| Sesje bez awarii | sesje bez awarii podzielone przez wszystkie sesje, z konsol sklepów | co najmniej 99,5% przez co najmniej 14 dni |
| Użytkownicy bez awarii | użytkownicy bez awarii podzieleni przez wszystkich | co najmniej 99,5% przez co najmniej 14 dni |
| Wymuszone ponowne logowanie | sesje zakończone wymuszonym logowaniem z winy klienta podzielone przez wszystkie sesje | poniżej 1% |
| Skuteczność łączenia | udane pierwsze połączenia podzielone przez próby | obserwowana, bez progu |
| Obciążenie | żądań na minutę na Home i szczegółach oraz CPU gi-core ([budżet](load-budget.md)) | zgodnie z budżetem |

### 8.5 Eskalacja i zatrzymanie

- Awaria sterowania ogrzewaniem, niepotwierdzone wstrzymanie lub zgłoszenie
  fałszywego potwierdzenia stanu przekaźnika zatrzymuje betę: koordynator
  informuje uczestników i postępuje według [procedury zatrzymania](#5-zatrzymanie-halt).
- Spadek poniżej progów z sekcji 8.4 otwiera zgłoszenie z priorytetem wydania;
  nie rozpoczynamy zgłoszenia do sklepów, dopóki metryki nie wrócą do normy
  przez pełne okno.
- Okno 14 dni liczymy od ostatniej zmiany kodu aplikacji w buildzie bety.

### 8.6 Kanał bety i jego skutki

Testerzy dostają build `prod`, nie `beta` (zapis w
[decyzjach sklepowych](decisions/store-and-product-decisions.md)). Skutki:
nie ma flag eksperymentalnych w bezpośrednim kanale testowym, identyfikator
aplikacji jest produkcyjny, więc betę i wersję sklepową instaluje się nie
równolegle, a raporty z konsol dotyczą tego samego wariantu, który trafi do
użytkowników. Wolniejsza strona tej decyzji to brak odrębnych liczników bety:
wersje bety odróżniamy numerem builda.

## 9. Listy kontrolne wydania

- [Lista kontrolna wydania](release-checklist.md): kroki techniczne i ręczne
  ścieżki czytników ekranu.
- [Przekazanie M4](m4-handoff.md) i [ponowne nagranie zrzutów golden](m4-golden-rerecord.md)
- [Lista kontrolna wyjścia M4](templates/m4-exit-checklist.md): kryteria v1.0,
  sposób pomiaru i dowody.
- Audyt stanów: [state-audit.md](state-audit.md); budżet obciążenia:
  [load-budget.md](load-budget.md); kompatybilność:
  [compatibility.md](compatibility.md).
