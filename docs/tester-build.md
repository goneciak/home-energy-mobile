# Build dla testera (Android, flavor beta)

Jedna komenda buduje podpisany kluczem debug APK flavoru `beta` i sprawdza go.
Wynik trafia do `dist/tester/` (katalog jest w `.gitignore`).

```powershell
pwsh tools/build_tester_apk.ps1
```

Wynik:

- `dist/tester/GI-Home-beta-<wersja>+<build>.apk`
- `dist/tester/BUILD-INFO.txt` (commit, wersja, SHA-256, rozmiar, czas)

## Parametry

| Parametr | Znaczenie |
| --- | --- |
| `-BuildName` | wersja widoczna dla testera; domyślnie z `app/pubspec.yaml` |
| `-BuildNumber` | numer budowy; domyślnie minuty od 2025-01-01, więc każdy kolejny build jest wyższy i może zaktualizować poprzedni |
| `-SplitAbi` | tylko arm64-v8a (ok. 20 MB zamiast ok. 57 MB); wystarczy dla nowych telefonów |
| `-AllowDirty` | pozwala budować z niezatwierdzonymi zmianami (domyślnie skrypt odmawia) |

Nową wersję ustawia się w `app/pubspec.yaml` (`version: 0.1.0+1`) albo parametrami
powyżej.

## Weryfikacja

`tools/verify_tester_apk.ps1` uruchamia się automatycznie po budowie. Używa
`aapt2` i `apksigner` z najnowszych build-tools w Android SDK i sprawdza:
pakiet `pl.gihome.gi_home.beta`, wersję i numer budowy, minSdk 26, targetSdk 36,
nazwę „GI Home Beta”, listę uprawnień (każde spoza listy to błąd), brak
`debuggable`, konfigurację ruchu sieciowego, podpis (`apksigner verify`, wypisuje
certyfikat) oraz zawartość `config/beta.json` (flavor beta, `FF_MOCK_CORE=false`,
pozostałe flagi). Przy błędzie kończy się kodem różnym od zera.

## Podpis

Bez `app/android/key.properties` i zmiennych `GI_UPLOAD_*` gradle podpisuje kluczem
debug z tego komputera (`~/.android/debug.keystore`). Taki APK instaluje się
ręcznie, ale nie nadaje się do Google Play. Aktualizacja zainstalowanej wersji
działa tylko przy tym samym kluczu, więc po zmianie komputera tester musi najpierw
odinstalować aplikację.

Build z własnym kluczem: ustaw `GI_UPLOAD_KEYSTORE_PATH`,
`GI_UPLOAD_KEYSTORE_PASSWORD`, `GI_UPLOAD_KEY_ALIAS`, `GI_UPLOAD_KEY_PASSWORD`
(albo `key.properties`, patrz `app/android/app/build.gradle.kts`) i uruchom ten
sam skrypt. Weryfikacja wypisze wtedy inny certyfikat.

## Instalacja u testera

Na telefonie trzeba zezwolić na instalację z nieznanych źródeł dla aplikacji, z
której otwieramy plik. Play Protect może ostrzec o nierozpoznanej aplikacji.

## Co wysłać testerowi

1. Plik `dist/tester/GI-Home-beta-<wersja>+<build>.apk`.
2. [Przewodnik testera](tester-guide.md).
3. Adres GI Home (IP z portem) i hasło pierwszego logowania, osobnym kanałem niż
   plik. Nie wysyłaj ich razem z APK ani w repozytorium.
