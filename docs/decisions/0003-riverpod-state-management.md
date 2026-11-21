# 0003. Stan aplikacji w Riverpod z generatorem, routing w go_router

- **Status:** Przyjęta (M0).
- **Data:** 2026-11-19
- **Plan:** §0 (Stan, Routing), §5.1, §5.2, §11, §18.1

## Kontekst

Aplikacja ma kilka źródeł stanu o różnym cyklu życia: profil urządzenia
(trwały, `shared_preferences`), sesję (jeden właściciel w `gi_core_api`),
klienta API (przebudowywanego tylko przy zmianie urządzenia, adresu lub
odcisku), dane odpytywane tylko na pierwszym planie (§11) i flagi funkcji
(ADR [0008](0008-feature-flags.md)). Potrzebny jest mechanizm, który:

- daje zależności wyliczane z innych zależności i ich automatyczne
  odświeżanie;
- pozwala nadpisać dowolną zależność w testach widgetów bez kontenera DI;
- nie wymaga `BuildContext` w warstwie aplikacji.

## Decyzja

- `flutter_riverpod` + `riverpod_generator` (`@riverpod`, `@Riverpod(keepAlive: true)`),
  kod generowany przez `build_runner` (`*.g.dart`).
- Warstwy per funkcja: `app/lib/src/features/<f>/{application,data,domain,presentation}`;
  wspólne rzeczy w `app/lib/src/core`, powłoka i router w `app/lib/src/app`.
  `domain/` to czysty Dart (np. `HomeCondition`, `FreshnessPolicy`), testowany
  jednostkowo.
- Przykłady w kodzie: `giCoreClientProvider`
  (`features/appliance/application/core_client_providers.dart`, keepAlive,
  zależny tylko od `ApplianceConnection`, więc nigdy nie powstają dwa
  menedżery sesji z tym samym ciasteczkiem); `FeatureFlagsNotifier`
  (`core/config/config_providers.dart`); polling przez
  `core/polling/foreground_poller.dart` i `ref_polling.dart`.
- Routing: `go_router` z guardami w kolejności profil → status setupu →
  sesja → `mustChangePassword` → zakładki według roli
  (`app/router/route_guard.dart`, `app_router.dart`).

## Konsekwencje

- Pozytywne: testy widgetów nadpisują providery (`ProviderScope(overrides:)`);
  przebudowa klienta jest jawnie powiązana z wybranym fragmentem profilu
  (`select`), a nie z każdą zmianą.
- Negatywne: zależność od generatora i wersji Riverpod 3 (zmiany API między
  wersjami głównymi); obowiązkowy krok `dart run build_runner build -d` przed
  analizą. CI sprawdza, że wygenerowany kod jest aktualny (§17.2).
