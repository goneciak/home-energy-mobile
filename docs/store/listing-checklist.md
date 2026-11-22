# Karta sklepowa: lista kontrolna

Co trzeba przygotować do kart aplikacji w Google Play i App Store. To lista
przygotowawcza: decyzje w konsolach (identyfikatory D4/D5, ceny, kraje,
wypełnienie formularzy) należą do właściciela projektu i nie są tu podejmowane.
Otwarte decyzje o identyfikatorach pakietów:
[store-and-product-decisions.md](../decisions/store-and-product-decisions.md).

## Zrzuty ekranu

Mapa zrzutów na scenariusze golden:
[screenshot-matrix.md](screenshot-matrix.md).

| Platforma | Wymagane | Uwagi |
|---|---|---|
| iPhone (App Store) | Zestaw dla największego wyświetlacza (6,9") i, gdy sklep go żąda, 6,5" | Aplikacja jest tylko na iPhone, portret (`TARGETED_DEVICE_FAMILY = 1`), więc zrzutów iPad nie potrzeba |
| Telefon Android (Play) | 2 do 8 zrzutów | Ten sam zestaw scenariuszy co iPhone |
| Tablet Android 7" i 10" (Play) | Zalecane, bo ekrany od 600 dp ignorują blokadę orientacji | Scenariusze mają golden 840 × 600 (poziom) |
| Zrzuty w obu językach | Polski i angielski | Golden dla każdego scenariusza istnieje w pl i en |

Zrzuty do sklepu robi się z trybu demo (dane przykładowe, baner DEMO jest w
kadrze albo się go kadruje). Goldeny nie są zrzutami do sklepu: pokazują układ,
nie ostateczną grafikę.

## Teksty (do uzupełnienia przez właściciela)

| Pole | Limit | Wartość |
|---|---|---|
| Nazwa aplikacji | Play 30, App Store 30 | GI Home |
| Krótki opis (Play) | 80 znaków | [[KROTKI_OPIS]] |
| Pełny opis (Play) / opis (App Store) | 4000 znaków | [[PELNY_OPIS]] |
| Co nowego | 500 znaków (Play) / 4000 (App Store) | [[CO_NOWEGO]] |
| Słowa kluczowe (App Store) | 100 znaków | [[SLOWA_KLUCZOWE]] |
| Adres polityki prywatności | – | adres strony `site/privacy.md` po publikacji |
| Adres wsparcia | – | adres strony `site/support.md` po publikacji |
| Kontakt | – | [[EMAIL_KONTAKTOWY]] |

Opis musi mówić, że aplikacja działa tylko z urządzeniem GI Home w sieci
domowej i że ma tryb demonstracyjny. Nie obiecuje dostępu zdalnego, bo go
nie ma.

## Ankieta oceny wiekowej: szkic odpowiedzi

Dotyczy IARC (Play) i ankiety wieku Apple. Odpowiedzi wynikają z funkcji
aplikacji; wypełnia i zatwierdza właściciel.

| Pytanie | Szkic odpowiedzi |
|---|---|
| Przemoc, treści seksualne, wulgaryzmy, narkotyki, hazard | Nie |
| Treści generowane przez użytkowników, czat, udostępnianie treści | Nie |
| Udostępnianie lokalizacji | Nie |
| Zakupy w aplikacji, reklamy | Nie |
| Dostęp do internetu | Nie jako usługi internetowej: aplikacja łączy się z urządzeniem w sieci domowej |
| Sterowanie urządzeniami fizycznymi | Tak (ogrzewanie, przekaźniki) |
| Kierowana do dzieci | Nie |

## Poziom API i 16 KB

- Android: `compileSdk` i `targetSdk` 36, `minSdk` 26
  (`app/android/app/build.gradle.kts`). Play wymaga od aplikacji
  kierowanych na Androida 15 i nowszy bibliotek natywnych wyrównanych do
  16 KB.
- Kontrola wyrównania: `tools/ci/check-16kb-alignment.sh` na AAB w
  `.github/workflows/build.yml` (krok „16 KB page alignment”). Lokalny wynik
  na APK z Windows i wymagania narzędzi: [development.md](../development.md),
  sekcja o kontroli 16 KB.
- iOS: tylko iPhone, portret.

## Zanim wyślesz do sklepu

- [ ] Zastępniki `[[…]]` w `site/` uzupełnione, strony opublikowane
      (GitHub Pages, D19, jeszcze nie włączone), adresy wpisane w obu sklepach.
- [ ] Data safety i etykieta prywatności wypełnione zgodnie z
      [data-safety.md](data-safety.md) i
      [apple-privacy-labels.md](apple-privacy-labels.md).
- [ ] Notatki dla recenzentów wklejone ([review-notes.md](review-notes.md)),
      w tym dane recenzenta.
- [ ] Xcode „Generate Privacy Report” na archiwum (macOS) bez nowych pozycji.
- [ ] Ref backendu zapisany w tabeli wydań
      ([compatibility.md](../compatibility.md)).
- [ ] Decyzje D4 i D5 (identyfikatory pakietów) podjęte.
