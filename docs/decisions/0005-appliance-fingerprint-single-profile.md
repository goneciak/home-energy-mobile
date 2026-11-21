# 0005. Odcisk urządzenia `initializedAt` i jeden profil w v1

- **Status:** Przyjęta (M0), z odnotowanym doprecyzowaniem planu (zmiana
  `deviceName` to zmiana nazwy). D1 = A jest wartością proponowaną i czeka na
  potwierdzenie właściciela ([decyzje](store-and-product-decisions.md)).
- **Data:** 2026-11-19
- **Plan:** §7.1, §7.8, §9.2, §9.3, §21 (L13), D1, spike S5

## Kontekst

GI Core nie ma stabilnego identyfikatora dostępnego bez logowania (L13),
a `gi-home.local` nie jest unikalne. Ciasteczko refresh i access token nie
mogą trafić do innego urządzenia, które odpowie pod zapamiętanym adresem
(np. po wymianie Pi albo w sieci z dwoma urządzeniami). Publiczny
`GET /setup/status` zwraca `initialized`, `initializedAt`, `deviceName`,
`locale` i `timezone`.

## Decyzja

- **Odcisk** to `initializedAt` z `/setup/status`. Plan mówi o
  `initializedAt + deviceName`; w kodzie o tożsamości decyduje tylko
  `initializedAt` (`ApplianceProfile.isSameAppliance`), a `deviceName` jest
  etykietą.
- **Zmiana `deviceName` przy tym samym `initializedAt` to zmiana nazwy, nie
  inne urządzenie.** `AuthSessionManager` kontynuuje refresh i woła
  `onApplianceRenamed`, a profil przyjmuje nową nazwę
  (`ApplianceProfileNotifier.applyRename`, `ApplianceProfile.renamedTo`).
  Brak nazwy nie jest zmianą. Uzasadnienie: właściciel może zmienić nazwę w
  `PATCH /settings/system`, a S5 zmierzył, że `initializedAt` pozostaje wtedy
  bez zmian ([S5](../spikes/s5-fixtures-quirks.md)); traktowanie tego jako
  innego urządzenia wylogowywałoby wszystkie telefony po zmianie nazwy.
- Sprawdzenie przed każdym refreshem (cache 60 s) i przed użyciem zapisanego
  access tokenu: inne `initializedAt` → `ApiFailure.differentAppliance`,
  `initialized:false` → `ApiFailure.applianceReset`. W obu przypadkach
  ciasteczko nie jest wysyłane, a zapisany access token jest usuwany.
- **Jeden profil w v1 (D1 = A):** `ApplianceProfile` w `shared_preferences`
  (bez sekretów), jeden aktywny użytkownik na profil. Wybór innego urządzenia
  na ekranie łączenia zastępuje profil dopiero po potwierdzeniu
  (`change_appliance_dialog.dart`); `AuthSessionNotifier.replaceAppliance`
  czyści wtedy ciasteczko i token, język sesji, diagnostykę i czekające
  raporty.
  Zmiana IP przy zgodnym odcisku zachowuje sesję (`ApplianceProfile.movedTo`).

## Konsekwencje

- Pozytywne: test kontraktowy §9.3
  (`test/contract/appliance_fingerprint_contract_test.dart`, z `GI_CORE_URL_B`)
  sprawdza, że Core B nie dostaje ani ciasteczka, ani tokenu Core A (wymaga
  drugiego Core; w przebiegu spike'ów z 2026-11-19 był pominięty, bo
  `GI_CORE_URL_B` nie było ustawione). Jednostkowo to samo pokrywają testy
  `restore` w `auth_session_manager_test.dart`.
- Negatywne: odcisk służy poprawności, nie bezpieczeństwu (L13): wrogie
  urządzenie w LAN może podać cudzy `initializedAt`. Dwa urządzenia GI Home
  w jednym domu wymagają przełączania profilu z ponownym logowaniem, dopóki
  właściciel nie wybierze D1 = B.
