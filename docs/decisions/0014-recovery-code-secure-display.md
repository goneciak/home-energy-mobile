# 0014. Bezpieczne wyświetlanie kodu odzyskiwania

- **Status:** Przyjęta (M3), z odstępstwem dla formularza resetu
- **Data:** 2026-11-22
- **Plan:** §7.7, §20 M3 pkt 5, L25

## Kontekst

`POST /auth/recovery/regenerate` zwraca 200 `{recoveryCode}` (32 znaki hex w
8 grupach) tylko raz i unieważnia poprzedni kod. Kod daje pełne przejęcie
konta. `POST /auth/recovery/reset` (204) nie zużywa i nie rotuje kodu, ale
unieważnia wszystkie sesje użytkownika.

## Decyzja

- `features/account/presentation/recovery_code_screen.dart`: potwierdzenie
  przed regeneracją, kod pokazany raz, nigdy zapisywany ani logowany; wyjście
  dopiero po potwierdzeniu, że kod został zapisany.
- `SecureContent` (`core/widgets/secure_content.dart`) i kanał
  `gi_home/secure` (`core/platform/secure_display.dart`): Android ustawia
  `FLAG_SECURE`, dopóki widget jest zamontowany; iOS zgłasza nagrywanie i
  mirroring ekranu. Kod zastępuje zasłona, gdy aplikacja nie jest na
  pierwszym planie (migawka przełącznika aplikacji) albo ekran jest nagrywany.
- Kopiowanie przez `copySensitive`: Android `EXTRA_IS_SENSITIVE`, iOS
  pasteboard `localOnly` z wygaśnięciem; schowek czyszczony po 60 s.
- Po resecie kodem aplikacja proponuje regenerację (`AccountPromptHost`).
- Sekrety nie trafiają do logów, raportu diagnostycznego ani zrzutów w testach
  i goldenach.

## Konsekwencje

- Pozytywne: kod nie wycieka przez zrzuty, przełącznik aplikacji ani schowek.
- iOS nie blokuje zrzutu ekranu, tylko zasłania treść.
- Formularz resetu (`recovery_reset_screen.dart`) jest owinięty w
  `SecureContent` jak ekran kodu (plan §7.7): FLAG_SECURE, gdy jest
  widoczny, a w tle i podczas nagrywania ekranu zastępuje go komunikat.
  Wpisany tekst zostaje w kontrolerach; ukrycie anuluje kontekst
  autouzupełniania, żeby nie proponować zapisu niedokończonego hasła.
