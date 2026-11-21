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
