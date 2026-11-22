# 0017. Strategia weryfikacji dostępności

- **Status:** Przyjęta (M4)
- **Data:** 2026-11-22
- **Plan:** M4 (dostępność, Exit M4), audyt stanów ekranów

## Kontekst

Exit M4 wymaga skali tekstu do 200%, rozmiarów dotykowych 48 dp, kontrastu oraz
przejścia kluczowych ścieżek z VoiceOver i TalkBack. Pierwsze trzy da się
sprawdzać maszynowo, ostatnie wymaga człowieka i telefonu. Środowisko
deweloperskie to Windows bez urządzeń z czytnikami ekranu.

## Decyzja

Trzy warstwy, z których każda ma swoje miejsce w wydaniu:

1. **Automatyczne zrzuty i wytyczne.** Każdy ekran w `screenGoldens` jest
   renderowany na trzech rozmiarach, w obu językach i przy skali 1,0, 1,3 i
   2,0; scenariusz kończy się błędem przy przepełnieniu oraz przy naruszeniu
   wytycznych rozmiaru dotykowego, etykiet i kontrastu.
2. **Testy drzewa semantyki.** Etykiety, nagłówki i komunikaty stanów
   głównych ekranów są sprawdzane asercjami, żeby regresje w opisach nie
   przechodziły niezauważone.
3. **Ręczna bramka wydania.** Sześć ścieżek z
   [listy kontrolnej wydania](../release-checklist.md) wykonuje tester z
   TalkBack i VoiceOver po polsku. Wynik jest zapisywany w tej liście i
   warunkuje wydanie produkcyjne.

## Konsekwencje

- Warstwy 1 i 2 chronią przed regresją w każdym PR, ale nie zastępują
  człowieka: nie sprawdzają kolejności fokusu ani naturalności komunikatów.
- Warstwa 3 jest zablokowana do czasu dostępu do urządzeń; dopóki jej nie ma,
  kryterium dostępności w [liście wyjścia M4](../templates/m4-exit-checklist.md)
  pozostaje otwarte.
- Zrzuty nagrane na Windows różnią się od linuksowych szumem; źródłem prawdy
  są zrzuty z CI.
