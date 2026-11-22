# App Store: etykieta prywatności, eksport szyfrowania i manifest prywatności

Szkic odpowiedzi do App Store Connect (App Privacy) oraz opis plików iOS, które
je wspierają. Spójne z [polityką prywatności](../../site/privacy.md) i z
[arkuszem Data safety](data-safety.md). Decyzje i wypełnienie formularzy należą
do właściciela projektu.

## Etykieta „App Privacy”

Proponowana odpowiedź: **Data Not Collected** (dane niezbierane).

Uzasadnienie. Apple liczy dane jako zebrane, gdy są przesyłane poza telefon w
sposób, który daje operatorowi lub partnerom dostęp do nich. E-mail i hasło
trafiają wyłącznie do urządzenia GI Home użytkownika w jego sieci domowej;
operator aplikacji nie ma serwera ani żadnego dostępu do tych danych. Aplikacja
nie zawiera analityki, reklam, śledzenia ani automatycznego raportowania
awarii. Raport diagnostyczny powstaje lokalnie i opuszcza telefon tylko wtedy,
gdy użytkownik sam go wyśle systemowym oknem udostępniania.

**Decyzja właściciela:** jeśli operator zdecyduje, że raporty diagnostyczne
wysłane mu mailem mają być opisane w etykiecie, trzeba dodać „Diagnostics”
(niepowiązane z tożsamością, nie do śledzenia, cel: App Functionality) i
zmienić też odpowiedź w arkuszu Data safety. Zbieranie raportów odbywa się poza
aplikacją, więc domyślnie nie jest deklarowane.

- **Tracking:** nie. Brak `NSUserTrackingUsageDescription`, brak domen
  śledzących.
- **Privacy Policy URL:** adres strony `site/privacy.md` po publikacji
  (hosting nie jest włączony).

## Eksport szyfrowania (`ITSAppUsesNonExemptEncryption`)

`app/ios/Runner/Info.plist` ma `ITSAppUsesNonExemptEncryption = false`.

Uzasadnienie. Aplikacja używa wyłącznie szyfrowania z systemu iOS: HTTPS/TLS
przez stos sieciowy systemu (adres `https://` jest opcjonalny) oraz Pęku kluczy
(`flutter_secure_storage`). Nie ma własnych ani niestandardowych algorytmów
kryptograficznych. Do tego przypadku odnosi się wyłączenie dla szyfrowania
dostarczanego przez system operacyjny. Plan wymagał potwierdzenia „tylko
standardowy TLS systemu”: wykonano przegląd zależności z `pubspec.lock`
(kod aplikacji i pakietu `gi_core_api` nie importuje żadnej biblioteki kryptograficznej).
Odpowiedź w pytaniach o eksport w App Store Connect musi pozostać zgodna z tym
kluczem.

## Manifest prywatności (`app/ios/Runner/PrivacyInfo.xcprivacy`)

| Klucz | Wartość | Uzasadnienie |
|---|---|---|
| `NSPrivacyTracking` | `false` | Brak śledzenia |
| `NSPrivacyTrackingDomains` | puste | Brak domen śledzących |
| `NSPrivacyCollectedDataTypes` | puste | Spójne z etykietą „Data Not Collected” |
| `NSPrivacyAccessedAPITypes` | `UserDefaults`, powód `CA92.1` | `shared_preferences` zapisuje ustawienia aplikacji (adres urządzenia, język, ustawienia sesji, nadpisania flag funkcji i liczniki błędów odczytu skarbca; bez e-maila i haseł) w `UserDefaults`, a dostęp służy wyłącznie samej aplikacji |

Plik jest zarejestrowany w `Runner.xcodeproj/project.pbxproj` (grupa Runner i
faza Resources celu Runner). Test `app/test/tooling/store_manifests_test.dart`
sprawdza jego strukturę i wpisy w projekcie.

### Pozostałe API wymagające podania powodu

| Kategoria | Użycie w aplikacji | Decyzja |
|---|---|---|
| File timestamp | Kod aplikacji (`app/lib`) nie czyta czasów plików (`lastModified`, `stat`); zapisuje tylko pliki dziennika | Nie deklarujemy w manifeście aplikacji. Silnik Fluttera i wtyczki (`path_provider`, `share_plus`) mają własne manifesty |
| System boot time | Nie używane w kodzie aplikacji | Nie deklarujemy |
| Disk space | Nie używane | Nie deklarujemy |
| Active keyboard | Nie używane | Nie deklarujemy |

Wtyczki z natywnym kodem iOS: `shared_preferences`, `flutter_secure_storage`,
`path_provider`, `package_info_plus`, `device_info_plus`, `share_plus`,
`url_launcher`, `connectivity_plus`, `multicast_dns` (czysty Dart, bez kodu
natywnego). Każda dostarcza własny manifest; Xcode scala je w raporcie.

## Co jest zablokowane poza tym komputerem

- **Xcode „Generate Privacy Report”** na archiwum: wymaga macOS (albo CI na
  macOS). Dopóki raport nie powstanie, tabela wyżej opiera się na przeglądzie
  kodu, nie na pomiarze. Jeśli raport pokaże inne kategorie dla samej
  aplikacji, trzeba dopisać je do manifestu i do testu.
- Wypełnienie formularzy w App Store Connect.
