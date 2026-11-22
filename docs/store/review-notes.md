# Notatki dla recenzentów (App Review, Play)

Teksty do wklejenia w „App Review Information → Notes” (App Store Connect, także
Beta App Review) oraz do pól „App access” i deklaracji w Play Console. Treść dla
recenzentów jest po angielsku; polskie akapity to komentarz dla zespołu. Przy
każdym wydaniu trzeba sprawdzić, czy tekst nadal zgadza się z aplikacją (żadnych
ukrytych funkcji). Decyzje o wysłaniu i wypełnieniu konsol należą do
właściciela projektu.

## 1. Tryb demo

Ten sam tekst co w [runbooku wydań](../release-runbook.md#31-notatka-dla-recenzentów-tryb-demo-app-review-play);
runbook jest źródłem, tu kopia do wklejenia.

> GI Home controls a GI Home appliance on the user's home network (LAN). The
> appliance is a physical device that reviewers cannot reach, so the app has a
> built-in demo mode that needs no account, no network and no hardware.
>
> How to use it: on the first screen ("Connect to GI Home") tap the visible
> button "Try the demo". The app opens a sample home, signed in as its owner. A
> permanent "DEMO" banner is shown on every screen while the demo runs; "Exit
> demo" in that banner returns to the first screen and erases all demo data.
>
> What can be tried: home overview, device details, switching a non-heating
> output (the confirmation arrives a few seconds later, like with real
> hardware), holding the button to suspend heating, resuming it with the
> consequence sheet, and editing the heating setting.
>
> The demo data is bundled with the app and kept only in memory. In demo mode
> the app opens no network connection, stores no credentials and does not
> change a connected appliance. No login credentials are needed.

## 2. The app does not create accounts

Dotyczy Apple 5.1.1(v) i polityki Google dotyczącej usuwania kont.

> GI Home does not create accounts. The app signs in to accounts that already
> exist on the user's own appliance; there is no account in the cloud and the
> app has no registration screen. Accounts exist only on the appliance and are
> managed by its owner in the appliance's web panel (Users). A user who wants
> their account removed asks the owner, who deletes it there; after that the
> person is signed out of every phone. Data kept by the app on the phone is
> removed by signing out (Settings, Sign out) or by uninstalling the app.
> Instructions for users: the account help page of the app's support site.

Fakty: rdzeń ma `POST /users` i `DELETE /users/:userId` tylko dla ról OWNER i
ADMIN; nie ma samodzielnego usunięcia własnego konta. Opis dla użytkowników:
[account-help.md](../../site/account-help.md).

**Luka do świadomej decyzji właściciela:** aplikacja nie ma przycisku „Usuń
konto”. Recenzent Apple może o niego zapytać mimo powyższej noty. Odpowiedź
opiera się na tym, że aplikacja nie tworzy kont (wytyczna 5.1.1(v) dotyczy
aplikacji, które pozwalają je założyć).

## 3. Cleartext HTTP i `NSAllowsLocalNetworking`

> The GI Home appliance is a device in the user's home network that serves
> plain HTTP on the local network (for example http://gi-home.local or
> http://192.168.1.20), because it has no public name from which a certificate
> could be issued. The iOS app therefore sets NSAllowsLocalNetworking only; it
> does not set NSAllowsArbitraryLoads. On Android, cleartext is allowed through
> the network security config, because Android cannot limit it to address
> ranges. The app enforces the real limit itself: plain http:// is accepted
> only for private (RFC 1918), loopback, link-local and unique-local addresses
> and for *.local names; any other address must use https://. The user is told
> on first connection that the connection to the appliance is not encrypted.
> The app contacts no other server.

Gdzie to jest w kodzie: ADR [0004](../decisions/0004-lan-transport-policy.md),
`packages/gi_core_api/lib/src/http/transport_policy.dart` (pokrycie 100%),
`app/ios/Runner/Info.plist`, `network_security_config.xml`.

## 4. Sieć lokalna i `NEARBY_WIFI_DEVICES`

> iOS: the app shows the system "Local Network" prompt the first time it
> contacts the appliance (NSLocalNetworkUsageDescription: it connects to the
> user's GI Home appliance on the home network to show the state of the home).
> No Bonjour services are declared; the .local name is resolved by the system.
>
> Android: INTERNET and ACCESS_NETWORK_STATE are used to reach the appliance and
> to notice a lost or changed network. NEARBY_WIFI_DEVICES is declared with the
> neverForLocation flag for Android's local network protection; the app does
> not derive location from it, and asks for it at runtime only when the
> corresponding option is enabled (off by default in the released build).
> CHANGE_WIFI_MULTICAST_STATE is declared for an optional fallback that finds
> the appliance by multicast DNS when the system cannot resolve the .local
> name; that fallback is off by default. The app does not request location,
> camera, microphone, contacts or notifications.

Flagi: `androidLocalNetworkPermissionRequest` i `mdnsFallback`
([ADR 0008](../decisions/0008-feature-flags.md),
[ADR 0015](../decisions/0015-network-change-no-write-replay.md)). Wynik spike'ów
S2 i S3 (telefony, Android 16 i iPhone) jest otwarty, więc nota opisuje stan
domyślny (flagi wyłączone). Jeśli flagi zostaną włączone domyślnie, trzeba
zaktualizować tę sekcję, [data-safety.md](data-safety.md) i test manifestu.

## 5. Dane logowania recenzenta (do uzupełnienia przez właściciela)

Recenzent nie ma dostępu do urządzenia GI Home, więc loguje się w trybie demo
(sekcja 1) i nie potrzebuje konta.

| Pole | Wartość |
|---|---|
| Konto demo / login | niepotrzebne: tryb demo działa bez logowania |
| Konto testowe na prawdziwym urządzeniu (opcjonalnie) | [[DANE_KONTA_RECENZENTA]] |
| Kontakt dla recenzenta (imię, telefon, e-mail) | [[KONTAKT_DLA_RECENZENTA]] |

Zastępniki w tej tabeli uzupełnia właściciel. Nie wpisujemy do repozytorium
prawdziwych haseł.
