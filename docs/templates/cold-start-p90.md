# Zimny start: raport p90 z 20 uruchomień

Szablon wyniku pomiaru czasu od uruchomienia aplikacji do widocznej listy
urządzeń na Home, z zapisanym urządzeniem i sesją, na telefonie w tej samej
sieci co Raspberry Pi. Cel: p90 nie większe niż 5 s przy co najmniej 20
uruchomieniach. Szkielet pomiaru i polecenia:
[development.md](../development.md), sekcja „Zimny start”.

## Konfiguracja

| Pole | Wartość |
|---|---|
| Data i osoba wykonująca | |
| Telefon (model, system, klasa wydajności) | |
| Wersja aplikacji i rodzaj kompilacji (wydaniowa albo profile) | |
| Raspberry Pi i wersja GI Core | |
| Sieć (Wi-Fi lub Ethernet, odległość od routera) | |
| Liczba urządzeń i kart ogrzewania na Home | |
| Sposób pomiaru (`adb shell am start -W` `TotalTime`, test integracyjny, nagranie ekranu) | |

## Przebieg

Przed każdym uruchomieniem zamknij aplikację całkiem (`adb shell am force-stop`)
i poczekaj kilka sekund. Telefon bez ładowania i bez trybu oszczędzania
baterii. Nie wliczaj pierwszego uruchomienia po instalacji.

Surowe wyniki w milisekundach, po jednym w wierszu, zapisz do `runs.txt` i
policz:

```sh
dart run tools/load/cold_start_p90.dart runs.txt
```

## Wynik

Wklej tabelę z narzędzia:

| Runs | Min | Median | Mean | p90 | Max | Limit (p90) | Verdict |
|---|---|---|---|---|---|---|---|
| | | | | | | 5000 ms | |

Surowe wyniki:

```text
```

## Wniosek

- [ ] p90 nie większe niż 5 s przy co najmniej 20 uruchomieniach.
- [ ] Niezaliczone. Co dominuje w czasie (silnik, odtwarzanie sesji, pierwsze
      żądanie, malowanie) i co poprawić:
