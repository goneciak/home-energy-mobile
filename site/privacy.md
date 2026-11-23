---
title: Polityka prywatności aplikacji GI Home
---

> **SZKIC (DRAFT). Nie publikować.** Treść czeka na zatwierdzenie przez
> operatora i weryfikację prawną. Zastępniki `[[…]]` trzeba uzupełnić.

# Polityka prywatności aplikacji GI Home

Obowiązuje od: [[DATA_WEJSCIA_W_ZYCIE]]

Aplikację GI Home („aplikacja”) wydaje [[NAZWA_OPERATORA]],
[[ADRES_OPERATORA]] („my”). W sprawach prywatności pisz na
[[EMAIL_KONTAKTOWY]].

## W skrócie

- Aplikacja łączy się **wyłącznie z Twoim urządzeniem GI Home w Twojej
  sieci domowej (LAN)**. Nie łączy się z chmurą, z naszymi serwerami ani z
  usługami innych firm.
- **Nie zbieramy danych.** Aplikacja nie zawiera analityki, reklam,
  śledzenia ani automatycznego raportowania awarii.
- **Dane logowania zostają na telefonie** w bezpiecznym magazynie systemu
  (Pęk kluczy w iOS, Android Keystore). Hasło nie jest zapisywane.
- **Diagnostyka trafia do kogokolwiek tylko wtedy, gdy sam wyślesz raport**
  przyciskiem w aplikacji.
- Połączenie z urządzeniem w sieci domowej **nie jest szyfrowane** (HTTP).
  Używaj aplikacji tylko w zaufanej sieci Wi-Fi.

## Z kim łączy się aplikacja

Aplikacja wysyła żądania tylko pod adres urządzenia GI Home, który
potwierdzisz na ekranie łączenia: nazwę `gi-home.local` (i kolejne
`gi-home-2.local` … `gi-home-5.local`), adres zapamiętany wcześniej albo
adres wpisany ręcznie. Połączenia bez szyfrowania (`http://`) są możliwe
wyłącznie z adresami sieci lokalnej (adresy prywatne, nazwy `.local`); każdy
inny adres wymaga `https://`. W tej wersji nie ma dostępu zdalnego spoza
domu.

Urządzenie GI Home należy do Ciebie (albo do właściciela domu). Konta
użytkowników, sesje logowania, ustawienia i dane domu są przechowywane **na
tym urządzeniu**, a nie u nas. Zarządza nimi właściciel urządzenia (zob.
[Pomoc dotycząca kont](account-help.md)).

## Co aplikacja wysyła do Twojego urządzenia GI Home

- e-mail i hasło przy logowaniu oraz polecenia, które wydajesz w aplikacji
  (np. zmiana temperatury, wstrzymanie ogrzewania);
- nagłówek identyfikujący aplikację: wersję aplikacji, system i jego wersję
  oraz model telefonu (np. `GIHome-Mobile/1.0.0 (Linux; Android 15; Pixel 8)`).
  Urządzenie pokazuje go na liście zalogowanych sesji, żeby można było
  rozpoznać ten telefon;
- techniczny identyfikator każdego żądania (losowy), pomocny przy
  diagnozowaniu błędów.

## Co aplikacja przechowuje na telefonie

| Dane | Gdzie | Kiedy są usuwane |
|---|---|---|
| Dane sesji (token odświeżania i token dostępu) | Bezpieczny magazyn systemu; w iOS dostępny po pierwszym odblokowaniu, bez synchronizacji z iCloud; wyłączony z kopii zapasowych | Przy wylogowaniu, zmianie użytkownika, zmianie urządzenia GI Home, wygaśnięciu sesji (najpóźniej po 30 dniach) albo po ponownej instalacji aplikacji |
| Adres i nazwa urządzenia GI Home oraz czas jego konfiguracji (do rozpoznania, że to to samo urządzenie) | Ustawienia aplikacji | Przy zmianie urządzenia albo odinstalowaniu |
| E-mail ostatnio zalogowanej osoby (do podpowiedzi przy logowaniu) i jej identyfikator | Ustawienia aplikacji | Po wybraniu „Zmień użytkownika”, przy zmianie urządzenia albo odinstalowaniu |
| Język aplikacji | Ustawienia aplikacji | Przy wylogowaniu lub odinstalowaniu |
| Dziennik diagnostyczny: liczniki i opisy błędów, techniczny dziennik połączeń | Pliki aplikacji wyłączone z kopii zapasowych | Przy wylogowaniu, zmianie użytkownika lub urządzenia, odinstalowaniu |

**Hasło nigdy nie jest zapisywane.** Dziennik diagnostyczny jest
oczyszczany przed zapisem: usuwane są tokeny, ciasteczka, hasła, adresy
e-mail, kody odzyskiwania, nazwy hostów i adresy IP.

## Raport diagnostyczny

W Ustawieniach możesz wybrać „Wyślij raport diagnostyczny”. Aplikacja
tworzy wtedy plik z wersją aplikacji, systemem i językiem telefonu,
licznikami błędów i oczyszczonym dziennikiem (bez danych wymienionych
wyżej) i otwiera systemowe okno udostępniania. **To Ty wybierasz, czy i
komu go wysłać** (np. e-mailem). Bez tego kroku raport nigdzie nie trafia.

Jeśli wyślesz raport do nas, użyjemy go wyłącznie do diagnozy problemu i
przechowamy przez [[OKRES_PRZECHOWYWANIA_RAPORTOW]].

## Uprawnienia

- **iOS: Sieć lokalna** – potrzebna, żeby połączyć się z urządzeniem GI
  Home w sieci domowej. Bez niej aplikacja nie zadziała; możesz ją zmienić w
  Ustawieniach systemu.
- **Android: Internet i stan sieci** – połączenie z urządzeniem w sieci
  domowej, wykrywanie braku sieci i zmiany sieci (po zmianie Wi-Fi aplikacja
  odświeża dane i sprawdza, czy urządzenie nie zmieniło adresu).
- **Android: Urządzenia w pobliżu (Wi-Fi)** – zadeklarowane na potrzeby
  ochrony sieci lokalnej w nowszych wersjach Androida, z oznaczeniem, że
  **nie służy do ustalania lokalizacji**. Aplikacja prosi o tę zgodę tylko
  wtedy, gdy odpowiednia opcja jest włączona; w wydaniu domyślnym jest
  wyłączona.
- **Android: Zmiana stanu multicastu Wi-Fi** – zadeklarowane dla opcjonalnego,
  domyślnie wyłączonego zapasowego wyszukiwania urządzenia po nazwie `.local`
  (multicast DNS). Zapytanie trafia tylko do Twojej sieci lokalnej i służy
  wyłącznie do znalezienia adresu urządzenia GI Home; nie wysyła danych poza
  sieć domową.

Aplikacja nie używa lokalizacji, aparatu, mikrofonu, kontaktów ani
powiadomień push.

## Bezpieczeństwo połączenia

Urządzenie GI Home w sieci domowej udostępnia połączenie bez szyfrowania
(HTTP). Osoba z dostępem do tej samej sieci mogłaby podsłuchać dane, w tym
dane logowania. Aplikacja informuje o tym przy pierwszym połączeniu. Korzystaj
z niej wyłącznie w zaufanej sieci Wi-Fi.

## Twoje prawa

Nie otrzymujemy Twoich danych, z wyjątkiem raportu diagnostycznego, który
sam nam wyślesz. W sprawie takiego raportu (dostęp, usunięcie) napisz na
[[EMAIL_KONTAKTOWY]]. Dane przechowywane na urządzeniu GI Home (konto,
sesje) usuwa właściciel urządzenia; dane na telefonie usuniesz, wylogowując
się albo odinstalowując aplikację.

## Zmiany polityki

O zmianach informujemy na tej stronie, z nową datą obowiązywania.
