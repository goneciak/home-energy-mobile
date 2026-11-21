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
