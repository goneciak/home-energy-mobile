# Google Play: formularz Data safety (arkusz odpowiedzi)

Szkic odpowiedzi do wklejenia w Play Console (Zasady aplikacji → Bezpieczeństwo
danych). Odpowiedzi wynikają z kodu i manifestu (`app/android/app/src/main/`),
z [polityki prywatności](../../site/privacy.md) i z faktu, że aplikacja łączy
się wyłącznie z urządzeniem GI Home użytkownika w jego sieci domowej. Test
`app/test/tooling/store_manifests_test.dart` pilnuje manifestu, do którego ten
arkusz się odwołuje. Wypełnienie formularza i ostateczne decyzje należą do
właściciela projektu.

Zakres: wersja 1.0, bez analityki, reklam, raportowania awarii i SDK innych
firm (zależności w `app/pubspec.yaml`).

## Co aplikacja robi z danymi

| Dane | Dokąd trafiają | Kto je widzi |
|---|---|---|
| E-mail i hasło przy logowaniu | Tylko do urządzenia GI Home użytkownika (LAN). Hasła aplikacja nie zapisuje. | Właściciel urządzenia |
| Tokeny sesji | Bezpieczny magazyn telefonu (Android Keystore), wyłączony z kopii zapasowych | Tylko telefon |
| Etykieta telefonu w nagłówku `User-Agent` (wersja aplikacji, system, model) | Urządzenie GI Home, na listę sesji | Właściciel urządzenia |
| Raport diagnostyczny | Nigdzie, dopóki użytkownik sam go nie wyśle systemowym oknem udostępniania | Odbiorca wybrany przez użytkownika |

Operator aplikacji nie ma serwera, który odbiera dane z aplikacji.

## Odpowiedzi

### 1. Data collection and security: „Does your app collect or share any of the required user data types?”

Proponowana odpowiedź: **Tak, zbiera; nie udostępnia.**

Uzasadnienie. Google liczy jako „collect” każde przesłanie danych poza telefon.
Logowanie wysyła e-mail do urządzenia GI Home, więc ostrożna wykładnia każe to
zadeklarować, choć odbiorcą jest sprzęt użytkownika, a nie operator. Plan
projektu zakłada tę wykładnię („brak udostępniania danych; dane logowania
trafiają tylko do własnego urządzenia”).

**Decyzja właściciela:** wariant alternatywny to „No data collected”, z
argumentem, że operator nigdy nie ma dostępu do danych. Jest ryzykowniejszy
przy weryfikacji formularza, bo aplikacja faktycznie wysyła e-mail przez sieć.
Obie odpowiedzi muszą pozostać zgodne z Apple (zob.
[apple-privacy-labels.md](apple-privacy-labels.md)), z polityką prywatności i z
tym arkuszem.

### 2. Is all of the user data collected by your app encrypted in transit?

Odpowiedź: **No.**

Uzasadnienie. Urządzenie GI Home w sieci domowej domyślnie wystawia zwykłe HTTP
(`http://gi-home.local`, adresy prywatne). Aplikacja dopuszcza `http://` tylko
dla adresów sieci lokalnej (zasada `TransportPolicy`, ADR
[0004](../decisions/0004-lan-transport-policy.md)), a każdy inny adres wymaga
`https://`. Użytkownik, który skonfiguruje HTTPS na urządzeniu, ma szyfrowanie,
ale formularz pyta o dane „w ogóle”, a nie o najlepszy przypadek. Uczciwa
odpowiedź to „No”, i tak mówi też polityka prywatności.

### 3. Do you provide a way for users to request that their data be deleted?

Odpowiedź: **Tak.** Dane w aplikacji użytkownik usuwa sam (wylogowanie, zmiana
urządzenia, odinstalowanie). Dane konta istnieją tylko na urządzeniu GI Home;
usuwa je jego właściciel w panelu web (Użytkownicy). Opis dla użytkownika:
[account-help.md](../../site/account-help.md). Adres URL do pola „Delete
account URL”: strona pomocy po publikacji (hosting nie jest włączony, zob.
[site/README.md](../../site/README.md)).

**Decyzja właściciela:** czy takie samoobsługowe usunięcie konta „przez
właściciela urządzenia” wystarcza w polu „Data deletion”; w razie wątpliwości
zob. także [review-notes.md](review-notes.md), sekcja o kontach.

### 4. Typy danych (jeśli odpowiedź w pkt 1 brzmi „Tak”)

| Kategoria → typ | Zbierane | Udostępniane | Przetwarzane tylko ulotnie | Wymagane | Cel |
|---|---|---|---|---|---|
| Personal info → Email address | Tak | Nie | Nie (przechowuje je urządzenie GI Home) | Tak | App functionality; Account management |
| Personal info → User IDs | Tak (identyfikator konta na urządzeniu) | Nie | Nie | Tak | App functionality; Account management |
| App info and performance → Crash logs, Diagnostics | **Nie**: raport powstaje lokalnie i nie jest wysyłany przez aplikację | – | – | – | – |
| Location, Financial info, Health, Messages, Photos, Audio, Files, Calendar, Contacts, Web browsing | Nie | – | – | – | – |
| Device or other IDs | Nie (model telefonu w `User-Agent` nie jest identyfikatorem reklamowym ani trwałym ID urządzenia) | – | – | – | – |

Hasło nie ma osobnej kategorii w formularzu; jest wysyłane tylko do
urządzenia użytkownika przy logowaniu i nigdzie zapisywane. Jeśli właściciel
uzna, że model telefonu w nagłówku trzeba zadeklarować, dodaje „Device or other
IDs” z celem „App functionality”.

### 5. Security practices

- Dane w tranzycie szyfrowane: **No** (pkt 2).
- Użytkownik może poprosić o usunięcie danych: **Tak** (pkt 3).
- Commitment to Play Families Policy: **nie dotyczy** (aplikacja nie jest
  skierowana do dzieci).
- Independent security review: **nie** (nie wykonano).

## Uprawnienia Androida zadeklarowane w manifeście

Lista musi się zgadzać z `AndroidManifest.xml` (pilnuje tego test).

| Uprawnienie | Po co | Dane osobowe |
|---|---|---|
| `INTERNET` | Połączenie z urządzeniem GI Home w sieci domowej | Nie |
| `ACCESS_NETWORK_STATE` | Wykrycie braku sieci i zmiany sieci (odświeżenie po zmianie Wi-Fi) | Nie |
| `NEARBY_WIFI_DEVICES` z `neverForLocation` | Ochrona sieci lokalnej w nowszych Androidach; prośba o zgodę pojawia się tylko przy włączonej fladze `androidLocalNetworkPermissionRequest` (domyślnie wyłączona). Nie służy do ustalania lokalizacji | Nie |
| `CHANGE_WIFI_MULTICAST_STATE` | Blokada multicastu na czas jednego zapytania w zapasowym wyszukiwaniu `.local` (flaga `mdnsFallback`, domyślnie wyłączona) | Nie |

Aplikacja nie prosi o lokalizację, aparat, mikrofon, kontakty ani
powiadomienia. Kopie zapasowe są wyłączone (`allowBackup="false"`).

## Pozostałe deklaracje w Play Console, które wynikają z kodu

- **App access:** tryb demo (tekst w [review-notes.md](review-notes.md)).
- **Ads:** nie zawiera reklam.
- **Target audience:** dorośli; nie dla dzieci.
- **Financial features, Health, Government apps, News:** nie dotyczy.
- **Target API level:** 36 (`app/android/app/build.gradle.kts`); 16 KB, zob.
  [listing-checklist.md](listing-checklist.md).
