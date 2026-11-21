# Decyzje produktowe i sklepowe (D1–D8, D12, D13): propozycje

Exit M0 wymaga „odpowiedzi na D1–D8 i D4” (plan §20). Poniżej są
**propozycje** z planu (§23, §19.7) z tym, co już wynika z kodu i spike'ów.
Żadna nie jest rozstrzygnięta: decyduje właściciel produktu. Kod
zaimplementowany według wartości domyślnej da się zmienić; przy każdej
pozycji jest napisane, czego dotyczy zmiana.

Status każdej pozycji: **Proponowane – czeka na decyzję właściciela.**

| ID | Pytanie | Propozycja (plan) | Co jest już w kodzie / co wiemy | Status |
|---|---|---|---|---|
| D1 | Wiele urządzeń GI Home w v1? | **A:** dokładnie jeden profil; wybór innego urządzenia zastępuje profil po potwierdzeniu i czyści dane. Alternatywa **B:** lista profili w M3 (+1 d), polling i „Uwaga” tylko dla aktywnego. | Zaimplementowane A (ADR [0005](0005-appliance-fingerprint-single-profile.md)): `ApplianceProfile`, `change_appliance_dialog.dart`, `AuthSessionNotifier.replaceAppliance`. Klucze sejfu są już per `profileId`, więc B nie wymaga migracji sekretów. | Proponowane – czeka na decyzję właściciela |
| D2 | Odbiorcy v1 | OWNER/ADMIN sterują; USER i SERVICE tylko podgląd (SERVICE czyta strefę z `/settings/system`). | Zgodne z katalogiem ról (`GiEndpoints`) i testem kontraktowym: USER dostaje `HTTP_403` na `PUT …/state` (S6). | Proponowane – czeka na decyzję właściciela |
| D3 | Zapisywać 15-minutowy access token? | **Tak.** | Zaimplementowane (ADR [0006](0006-secure-storage-access-token.md)): klucz `p/<profileId>/at`, użycie przy zimnym starcie po sprawdzeniu odcisku. Wyłączenie = brak zapisu w `TokenVault`. | Proponowane – czeka na decyzję właściciela |
| D4 | Typ konta Google Play | Do decyzji w M0. **Organizacja** (wymaga D-U-N-S, bez reguły 14 dni) albo **osobiste** (closed test ≥ 12 testerów przez 14 kolejnych dni przed wnioskiem o produkcję; ścieżka closed testing od końca M2, testerzy bez Pi w trybie demo). | Plan nie wskazuje wariantu. Wpływ na harmonogram: przy koncie osobistym 14 dni mija w trakcie M3 (§19.7). Wymagania Play warto potwierdzić w Play Console przed decyzją (§24 p. 12). | Proponowane – czeka na decyzję właściciela |
| D5 | Dystrybucja, konta Apple, bundle ID, nazwa „GI Home” | Wewnętrznie w M2 (TestFlight internal, Play internal), w sklepach w v1.0; nazwa „GI Home”. | Bundle ID są dziś niespójne między platformami (patrz „Otwarte” niżej). `fastlane/Appfile` i `codemagic.yaml` czytają ID ze zmiennych (`GI_IOS_BUNDLE_ID`, `GI_ANDROID_PACKAGE_NAME`) i czekają na tę decyzję. | Proponowane – czeka na decyzję właściciela |
| D6 | Zdalny dostęp w 1.x? | **Nie** (L22). | Aplikacja działa wyłącznie w LAN (ADR [0004](0004-lan-transport-policy.md)); polityka prywatności w `site/` to opisuje. | Proponowane – czeka na decyzję właściciela |
| D7 | Natywny kreator setupu | **Nie**; przekazanie do panelu web (`http://<host>/setup`). | `setup_required_screen.dart` kieruje do przeglądarki. `POST /setup/initialize` jest publiczny i bez limitu (L8). | Proponowane – czeka na decyzję właściciela |
| D8 | Domyślny zegar harmonogramów i konwersja | Z S7 (oczekiwane UTC); domyślnie tylko etykieta; konwersja opt-in. | **S7 zmierzył UTC** w obu stosach Docker ([S7](../spikes/s7-schedule-clock.md)); na Pi wynika to z konfiguracji (brak `TZ`), bez pomiaru na sprzęcie. Konwersja jest za flagą `scheduleClockConversion`, domyślnie wyłączoną we wszystkich flavorach (ADR [0008](0008-feature-flags.md)). | Proponowane – czeka na decyzję właściciela |
| D12 | CI dla iOS | **Codemagic.** | `codemagic.yaml` istnieje; podpisywanie czeka na konta Apple (D5). | Proponowane – czeka na decyzję właściciela |
| D13 | Minimalne OS, target i orientacja | iOS 15+, tylko iPhone, portret; Android API 26+, `targetSdk` 36, poziom na ≥ 600 dp. | W kodzie: `IPHONEOS_DEPLOYMENT_TARGET = 15.0`, `TARGETED_DEVICE_FAMILY = 1`; Android `minSdk = 26`, `compileSdk`/`targetSdk = 36`. Termin wymagań Play dla `targetSdk` do potwierdzenia w Play Console (§24 p. 12). | Proponowane – czeka na decyzję właściciela |

## Otwarte: niezgodne identyfikatory aplikacji (dotyczy D5)

- **Android:** `applicationId = "pl.gihome.gi_home"` (prod), z sufiksami
  `.dev` i `.beta` (`app/android/app/build.gradle.kts`; tabela flavorów w
  `README.md`).
- **iOS:** `PRODUCT_BUNDLE_IDENTIFIER = pl.gihome.giHome`
  (`app/ios/Runner.xcodeproj/project.pbxproj`), jeden schemat `Runner`, bez
  osobnych ID dla dev i beta.

Różnica (`gi_home` vs `giHome`) pochodzi z domyślnych szablonów
`flutter create` (Android nie dopuszcza `giHome` w konwencji pakietu z
podkreśleniem, iOS nie dopuszcza `_`). Nie jest błędem technicznym, ale ID
po pierwszym wydaniu nie da się zmienić, więc właściciel powinien wybrać
docelowe identyfikatory przed rejestracją aplikacji w App Store Connect i
Play Console. Do decyzji:

1. docelowy bundle ID iOS i `applicationId` Android (np. ujednolicenie do
   `pl.gihome.home` na obu platformach albo akceptacja obecnej pary);
2. czy iOS dostaje osobne ID dla dev i beta (plan §19.2 mówi „osobne
   bundle ID”), czyli osobne schematy i konfiguracje Xcode;
3. właściciel domeny `gihome.pl` (odwrócona domena w ID powinna należeć do
   wydawcy).

Zmiana ID nie jest robiona w tym pakiecie pracy.

## Otwarte: kanały testowe dostają build prod, nie beta (odstępstwo od §19.2)

Plan §19.2 przypisuje TestFlight i Play closed testing flavorowi `beta`, a
sklepy flavorowi `prod`. Dziś **wszystkie ścieżki dystrybucji budują prod**:
`codemagic.yaml` (`ios-testflight-internal`, `android-play-internal`) i
`fastlane/Fastfile` (`internal_ios`, `internal_android`) używają
`-t lib/main.dart --dart-define-from-file=config/prod.json` (na Androidzie
`--flavor prod`). Ścieżka beta nie istnieje w żadnym pipeline.

Skutek: testerzy z TestFlight i ścieżki testów Play dostają build prod, w
którym ukryty ekran „Funkcje eksperymentalne” jest wyłączony, a nadpisania
flag ignorowane (`AppFlavor.allowsFlagOverrides`). Przepływ beta z §19.6
(włączanie flag u testerów) jest więc dostępny tylko dla zespołu z buildem
dev/beta zainstalowanym ręcznie. Ścieżki „internal” testują przy tym
dokładnie ten build, który potem idzie do produkcji, co jest ich celem.

Dlaczego jeszcze nie ma ścieżki beta:

1. **Android:** flavor `beta` istnieje (`applicationId` z sufiksem
   `.beta`, `lib/main_beta.dart`, `config/beta.json`), ale Play traktuje
   `pl.gihome.gi_home.beta` jako **osobną aplikację z własną kartą** w Play
   Console (osobne zgłoszenie, polityka prywatności, ankieta danych, przy
   koncie osobistym osobne 14 dni z ≥ 12 testerami, D4). To zależy od D4 i
   D5.
2. **iOS:** schematy Xcode i osobne bundle ID per flavor wymagają pracy na
   macOS (README, sekcja flavorów); do tego czasu iOS buduje tylko prod.

Do decyzji właściciela: czy closed testing ma dostać osobną aplikację beta
(wtedy dochodzą ścieżki `--flavor beta -t lib/main_beta.dart
--dart-define-from-file=config/beta.json` w Codemagic i fastlane, i schemat
`beta` na iOS), czy testerzy zostają na buildzie prod, a flagi włącza się
tylko w buildach dla zespołu. Runbook wydań opisuje stan obecny
([release-runbook.md](../release-runbook.md), sekcja 3).

## Co nie jest tu decydowane

Pozostałe pozycje §23 (D9–D11, D14–D20) mają w planie wartości domyślne, z
których kod korzysta; nie są warunkiem Exit M0. D19 (hosting polityki i
wsparcia na GitHub Pages) ma szkic treści w `site/`, bez publikacji.
