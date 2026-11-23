# Mapa zrzutów sklepowych na scenariusze golden

Każdy zrzut z karty sklepowej ma scenariusz golden w
`app/test/golden/goldens/ci/<scenariusz>_<urządzenie>.png`, w trzech
rozmiarach: `small_phone` (320 × 568), `large_phone` (430 × 932) i
`tablet_landscape` (840 × 600), w pl i en. Zrzuty tabletowe do Play bierze się
z rozmiaru `tablet_landscape`. Test `app/test/tooling/store_docs_test.dart`
sprawdza, że dla każdego scenariusza z tabeli istnieje plik
`tablet_landscape`, więc dodanie pozycji tu bez golden zatrzymuje testy.

| # | Zrzut w sklepie | Scenariusz golden | Pokazuje |
|---|---|---|---|
| 1 | Łączenie z urządzeniem | `golden/connect_searching` | Wyszukiwanie urządzenia w sieci domowej |
| 2 | Przegląd domu | `golden/home_healthy` | Lista urządzeń, stan świeży |
| 3 | Szczegóły urządzenia | `golden/detail_normal` | Odczyty i sterowanie |
| 4 | Sterowanie ogrzewaniem | `golden/heating_control_screen_owner` | Strategia, wstrzymanie, wznowienie |
| 5 | Harmonogramy | `golden/schedules_owner` | Lista harmonogramów |
| 6 | Historia | `golden/history_temperature_day` | Wykres temperatury z dnia |
| 7 | Pogoda i PV | `golden/weather_available` | Pogoda i prognoza PV |
| 8 | Ustawienia | `golden/settings_owner` | Sesja, język, raport diagnostyczny |

Poza zestawem do sklepu, ale używane w notatkach dla recenzentów:
`golden/demo_banner` (baner trybu demo).

## Czego ta mapa nie rozstrzyga

- Ostateczna grafika (ramki urządzeń, podpisy) jest decyzją właściciela.
- Goldeny nagrane na Windows różnią się o szum podpikselowy od nagranych w CI na
  Linuksie; źródłem prawdy są pliki z `goldens/ci`.
