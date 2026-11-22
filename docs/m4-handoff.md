# M4: przekazanie do przeglądu właściciela

Stan na 2026-11-22, gałąź `feat/m4`. Prace M4 leżą w drzewie roboczym bez
commitów (gałąź jest na `main`), więc właściciel decyduje o podziale na commity.
Nic nie wypchnięto, nie otagowano i nie zgłoszono do sklepów.

## Zrobione i zweryfikowane

| Sprawdzenie | Wynik |
|---|---|
| `build_runner build -d` (app, gi_core_api), `flutter gen-l10n` | bez zmian względem drzewa |
| `flutter analyze` (app) | bez uwag |
| `dart analyze --fatal-infos` (gi_core_api, tools) | bez uwag |
| `flutter test --coverage --branch-coverage` (app) | 1287 testów, wszystkie zielone |
| `dart test -x contract` (gi_core_api) | 451 testów, zielone |
| `dart test` (tools) | 115 testów, zielone |
| `dart run tools/check_coverage.dart` | bramki przechodzą; ConfirmationPolicy, SafetyPolicy i TransportPolicy mają 100% |
| `dart format --output=none --set-exit-if-changed app packages tools` | czysto |
| Stos kontraktowy (`-RunId m4final -Seed`) i `dart test -t contract -j 1` | zielone, stos usunięty |
| `tools/spec_diff.dart` względem `core-8be59cd.json` | 33 endpointy, 0 błędów, 0 ostrzeżeń |
| `flutter build apk --release --flavor prod` | zbudowany (podpis kluczem debug, bo brak klucza uploadu) |
| `tools/ci/check-16kb-alignment.sh` na tym APK | 8 bibliotek natywnych wyrównanych do 16 KB |
| Parytet ARB pl i en | te same klucze |
| Flagi `androidLocalNetworkPermissionRequest` i `mdnsFallback` | domyślnie wyłączone w dev, beta i prod |

Zakres funkcjonalny: odświeżenie i ponowne powiązanie po zmianie sieci bez
powtarzania zapisów ([ADR 0015](decisions/0015-network-change-no-write-replay.md)),
budżet żądań ([load-budget.md](load-budget.md), [ADR 0016](decisions/0016-home-card-cadence-request-budget.md)),
dostępność i audyt stanów ([state-audit.md](state-audit.md), [ADR 0017](decisions/0017-accessibility-verification-strategy.md)),
manifesty i dokumenty sklepowe ([docs/store](store/review-notes.md),
[compatibility.md](compatibility.md)), program bety
([ADR 0018](decisions/0018-beta-programme-and-metrics.md)), lista wydania
([release-checklist.md](release-checklist.md)), szablony w
[docs/templates](templates/m4-exit-checklist.md).

Zrzuty golden z Windowsa: [m4-golden-rerecord.md](m4-golden-rerecord.md).

## Zablokowane (nie zmierzone)

- Beta z domownikami na prawdziwym Pi i 14-dniowy pomiar sesji bez awarii.
- Zgłoszenia i review w App Store i Google Play.
- Ludzkie przejścia VoiceOver i TalkBack (pl).
- Zimny start p90 na telefonie, obciążenie gi-core na prawdziwym Pi.
- Spike S2 i S3 (urządzenia fizyczne), więc `mdnsFallback` zostaje wyłączony.
- Raport prywatności Xcode (macOS) i budowa iOS.
- Ponowne nagranie zrzutów golden na Linuksie.

## Decyzje właściciela

- Dane operatora i treść prawna w `site/` (pola `[[...]]`).
- Identyfikatory pakietów (D4, D5) oraz kanał testowy beta.
- Włączenie GitHub Pages (D19).
- Domyślna wartość flagi mDNS po wyniku S3.
- Podział prac na commity i scalenie gałęzi.
