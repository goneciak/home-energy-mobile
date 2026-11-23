# GI Home Beta – przewodnik testera

Android 8+, telefon w tej samej sieci Wi-Fi co urządzenie GI Home. Aplikacja
jest z założenia tylko dla sieci domowej (LAN): poza nią się nie połączy.

## Instalacja

1. Otwórz `GI-Home-beta-<wersja>.apk` z przeglądarki lub menedżera plików i zezwól
   tej aplikacji na instalację z nieznanych źródeł (nazwa ustawienia zależy od
   producenta).
2. Play Protect może ostrzec o nierozpoznanej aplikacji: „Zainstaluj mimo to”.
3. Aktualizacja: wystarczy otworzyć nowszy plik. APK jest podpisany kluczem debug
   komputera, na którym powstał, więc przy APK z innego komputera Android odmówi
   aktualizacji i trzeba najpierw odinstalować aplikację.

## Połączenie i logowanie

Ekran „Połącz z GI Home” sam szuka urządzenia w sieci. Jeśli go nie znajdzie, wpisz
adres w polu „Adres GI Home”, potem „Sprawdź” i „Tak, połącz”. Akceptowane formaty:

- `192.168.1.20:3000` (IP i port, najpewniejsze),
- `gi-home.local` (zależy od telefonu i routera),
- zwykły HTTP na porcie 3000; HTTPS z certyfikatem samopodpisanym (Pi) nie jest
  jeszcze obsługiwany.

Pierwsze logowanie: hasło od właściciela, potem wymuszona zmiana hasła („Zmień
hasło”) i kod odzyskiwania, pokazywany tylko raz. Zapisz go i potwierdź
„Zapisałem kod w bezpiecznym miejscu”. Haseł i kodów nie wysyłaj w wiadomościach.

Język aplikacji możesz zmienić jeszcze przed logowaniem: przycisk „Język” na
ekranach połączenia i logowania (Automatycznie / Polski / English) działa tak samo
jak Ustawienia → Język. Po zalogowaniu aplikacja używa języka z profilu, chyba
że wybrano język ręcznie.

## Lista kontrolna

- [ ] Połączenie z urządzeniem i logowanie.
- [ ] Ekran „Dom”: urządzenia, temperatury, stan ogrzewania.
- [ ] Szczegóły urządzenia (dotknięcie urządzenia).
- [ ] Przełącznik: dotknięcie, okno „Wyślij polecenie”, potem oczekiwanie na raport
      sterownika („czeka na raport sterownika”).
- [ ] Ogrzewanie: „Przytrzymaj, aby wstrzymać ogrzewanie” (zwykłe dotknięcie nic nie
      robi), potem „Wznów ogrzewanie”.
- [ ] Historia: w szczegółach urządzenia wiersz „Co działo się w nocy?” albo
      dotknięcie odczytu.
- [ ] Offline: wyłącz Wi-Fi w telefonie lub odłącz zasilanie urządzenia. Oczekiwane:
      baner „Brak połączenia z GI Home”, ostatnie dane, brak sterowania.
- [ ] Zakładka „Ustawienia”, „Wyloguj” i ponowne logowanie.
- [ ] Bez urządzenia: „Wypróbuj wersję demonstracyjną” na dole ekranu połączenia
      (dane przykładowe, nic nie jest sterowane).

## Co jest najcenniejsze dla autora backendu

Zachowanie potwierdzeń GI Edge na prawdziwym sterowniku:

- co aplikacja pokazuje między poleceniem a następnym raportem sterownika
  (przełącznik: „czeka na raport sterownika”; wstrzymanie i wznowienie: „czekamy,
  aż GI Home potwierdzi”, limit 30 s, a po wstrzymaniu 45 s na raport stanu
  wyjść),
- czy po raporcie komunikat zgadza się ze stanem fizycznym przekaźników,
- przejścia „Brak świeżych danych” i „Brak łączności” (dane uznawane za nieświeże
  po dwukrotności interwału raportów) oraz powrót do normy,
- rozjazdy między aplikacją a panelem web.

Opisz: co zrobiłeś, co aplikacja pokazała, czego się spodziewałeś i mniej więcej o
której godzinie (żeby dopasować do logów gi-core).

## Raport diagnostyczny

Zakładka „Ustawienia”, na dole „Wyślij raport diagnostyczny”, potwierdź w oknie i
„Udostępnij”, a potem wybierz aplikację. Nic nie jest wysyłane samo. To plik JSON:
wersja aplikacji i systemu, język, liczniki (przyczyny wylogowań, błędy połączenia,
czas uruchamiania) i ostatnie błędy aplikacji. Przed zapisem usuwane są hasła,
tokeny, ciasteczka, kody odzyskiwania, e-maile, adresy IP i nazwy hostów (w tym
`.local`); identyfikatory żądań i ścieżki zostają. Nie ma w nim danych z urządzeń.

## Znane ograniczenia

- Tylko LAN; HTTPS z certyfikatem samopodpisanym (Pi) jeszcze nie działa.
- Brak buildu na iOS.
- APK podpisany kluczem debug, niedostępny w Google Play.
