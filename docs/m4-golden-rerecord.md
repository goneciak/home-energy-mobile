# Ponowne nagranie zrzutów golden na Linuksie

Zrzuty w `app/test/golden/goldens/ci/` powinny pochodzić z Linuksa, jak w CI.
Poniższe pliki dodano lub zmieniono na Windowsie (poza Linuksem porównanie
dopuszcza 0,3% pikseli różnicy, CI na Linuksie jest ścisłe), więc do pierwszego
czerwonego przebiegu CI trzeba je nagrać ponownie.

Repozytorium nie ma osobnego workflow do aktualizacji zrzutów. Na Linuksie (lub
w kontenerze z tym samym SDK co CI), w katalogu `app/`:

```sh
flutter test --update-goldens --tags golden
```

Potem sprawdź diff PNG i zatwierdź tylko zrzuty z listy poniżej. Zrzuty
`goldens/windows/` są w `.gitignore` i nie wchodzą do repozytorium.

## Testy, których dotyczy zmiana

- `test/golden/app_screens_golden_test.dart` (nowy): ustawienia, przywracanie
  sesji, zmiana hasła, ekran wymaganej konfiguracji, funkcje eksperymentalne,
  stany ładowania i błędu sesji.
- `test/golden/account_golden_test.dart` (zmieniony): sesje w stanie ładowania
  i błędu.
- `test/golden/schedules_golden_test.dart` (zmieniony): harmonogramy offline.
- Zrzuty ekranu Domu i harmonogramów: zmiana wspólnych komponentów stanów.

## Pliki

- `home_attention_large_phone.png` (zmieniony)
- `home_attention_tablet_landscape.png` (zmieniony)
- `home_healthy_large_phone.png` (zmieniony)
- `home_healthy_small_phone.png` (zmieniony)
- `home_healthy_tablet_landscape.png` (zmieniony)
- `home_offline_stale_large_phone.png` (zmieniony)
- `home_offline_stale_tablet_landscape.png` (zmieniony)
- `schedules_empty_large_phone.png` (zmieniony)
- `schedules_empty_small_phone.png` (zmieniony)
- `schedules_owner_large_phone.png` (zmieniony)
- `schedules_owner_small_phone.png` (zmieniony)
- `schedules_owner_tablet_landscape.png` (zmieniony)
- `account_sessions_error_large_phone.png` (dodany)
- `account_sessions_error_small_phone.png` (dodany)
- `account_sessions_error_tablet_landscape.png` (dodany)
- `account_sessions_loading_large_phone.png` (dodany)
- `account_sessions_loading_small_phone.png` (dodany)
- `account_sessions_loading_tablet_landscape.png` (dodany)
- `change_password_error_large_phone.png` (dodany)
- `change_password_error_small_phone.png` (dodany)
- `change_password_error_tablet_landscape.png` (dodany)
- `change_password_form_large_phone.png` (dodany)
- `change_password_form_small_phone.png` (dodany)
- `change_password_form_tablet_landscape.png` (dodany)
- `experimental_features_large_phone.png` (dodany)
- `experimental_features_small_phone.png` (dodany)
- `experimental_features_tablet_landscape.png` (dodany)
- `schedules_offline_large_phone.png` (dodany)
- `schedules_offline_small_phone.png` (dodany)
- `session_restore_connecting_large_phone.png` (dodany)
- `session_restore_connecting_small_phone.png` (dodany)
- `session_restore_connecting_tablet_landscape.png` (dodany)
- `session_restore_unreachable_large_phone.png` (dodany)
- `session_restore_unreachable_small_phone.png` (dodany)
- `session_restore_unreachable_tablet_landscape.png` (dodany)
- `session_restore_vault_large_phone.png` (dodany)
- `session_restore_vault_small_phone.png` (dodany)
- `session_restore_vault_tablet_landscape.png` (dodany)
- `settings_owner_large_phone.png` (dodany)
- `settings_owner_small_phone.png` (dodany)
- `settings_owner_tablet_landscape.png` (dodany)
- `setup_required_dev_large_phone.png` (dodany)
- `setup_required_dev_small_phone.png` (dodany)
- `setup_required_dev_tablet_landscape.png` (dodany)
- `setup_required_prod_large_phone.png` (dodany)
- `setup_required_prod_small_phone.png` (dodany)
- `setup_required_prod_tablet_landscape.png` (dodany)
