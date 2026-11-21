// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'GI Home';

  @override
  String get actionRetry => 'Spróbuj ponownie';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionClose => 'Zamknij';

  @override
  String get actionChangeAppliance => 'Zmień urządzenie';

  @override
  String get actionOpenSettings => 'Otwórz ustawienia';

  @override
  String get actionFindAppliance => 'Znajdź GI Home';

  @override
  String get commonLoading => 'Ładowanie…';

  @override
  String get commonNoData => 'Brak danych';

  @override
  String get commonNoDataValue => '—';

  @override
  String get navHome => 'Dom';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get connectTitle => 'Połącz z GI Home';

  @override
  String get connectIntro =>
      'Telefon musi być w tej samej sieci Wi-Fi co GI Home. Wybierz znalezione urządzenie albo wpisz jego adres.';

  @override
  String get connectAddressLabel => 'Adres GI Home';

  @override
  String get connectAddressHint => 'np. gi-home.local lub 192.168.1.20';

  @override
  String get connectAddressRequired => 'Wpisz adres GI Home';

  @override
  String get connectSearchTitle => 'Znajdź GI Home';

  @override
  String get connectSearching => 'Szukam GI Home…';

  @override
  String get connectSearchNoneFound =>
      'Nie znaleziono GI Home w tej sieci. Wpisz jego adres poniżej.';

  @override
  String get connectSearchAgain => 'Szukaj ponownie';

  @override
  String get connectCandidateCurrent => 'Obecne urządzenie';

  @override
  String get connectCandidateNotSetUp => 'Nieskonfigurowane';

  @override
  String get connectManualTitle => 'Albo wpisz adres';

  @override
  String get connectHintsTitle => 'Podpowiedzi';

  @override
  String get connectHintAndroidEmulator => 'Emulator Androida';

  @override
  String get connectHintIosSimulator => 'Symulator iOS';

  @override
  String get connectHintAndroidUsb => 'Android przez USB';

  @override
  String get connectHintLanPhone => 'Telefon w LAN';

  @override
  String get connectHintLanProxy => 'Przez dev_lan_proxy';

  @override
  String get connectHintComputerIp => 'IP-komputera';

  @override
  String connectHintUsbNote(String command) {
    return 'Android przez USB: najpierw uruchom na komputerze $command, a potem połącz się z localhost:3000.';
  }

  @override
  String get connectHintProxyNote =>
      'Przez dev_lan_proxy: gdy GI Core zostaje na loopbacku, forwarder na komputerze przekazuje port 8080 do 127.0.0.1:3000. Wpisz IP komputera przed :8080.';

  @override
  String get connectHintLan =>
      'Telefon w sieci Wi-Fi: wpisz adres IP komputera w sieci LAN przed :3000. Backend musi działać z GI_CORE_BIND_ADDRESS=0.0.0.0 (dev-up -Lan), a port 3000 musi być otwarty w zaporze.';

  @override
  String get connectSubmit => 'Sprawdź';

  @override
  String get connectProbing => 'Sprawdzam adres…';

  @override
  String get connectConfirmTitle => 'Czy to Twój GI Home?';

  @override
  String connectConfirmSubtitle(String deviceName, String host) {
    return '$deviceName · $host';
  }

  @override
  String get connectNotInitializedNote =>
      'To urządzenie nie jest jeszcze skonfigurowane.';

  @override
  String get connectCleartextNote =>
      'Połączenie w sieci domowej nie jest szyfrowane. Używaj tylko w zaufanej sieci Wi-Fi.';

  @override
  String get connectConfirmYes => 'Tak, połącz';

  @override
  String get connectConfirmNo => 'Nie, wpisz inny adres';

  @override
  String get connectErrorInvalidAddress =>
      'To nie wygląda na poprawny adres. Wpisz nazwę, adres IP lub URL GI Home.';

  @override
  String get connectErrorNotGiHome =>
      'Pod tym adresem odpowiada inne urządzenie, nie GI Home.';

  @override
  String get errorUnreachable =>
      'Nie można połączyć się z GI Home. Sprawdź, czy telefon jest w tej samej sieci Wi-Fi.';

  @override
  String get errorTimeout =>
      'GI Home nie odpowiedział na czas. Spróbuj ponownie.';

  @override
  String get errorTlsUntrusted =>
      'Certyfikat serwera nie jest zaufany – użyj http:// w sieci domowej lub certyfikatu z publicznego CA.';

  @override
  String get errorLocalNetworkDenied =>
      'GI Home nie ma dostępu do sieci lokalnej. Zezwól na dostęp w Ustawieniach telefonu.';

  @override
  String get errorInsecureTransport =>
      'Połączenie nieszyfrowane (http://) jest dozwolone tylko w sieci domowej. Dla innych adresów użyj https://.';

  @override
  String get errorForbidden => 'Nie masz uprawnień do tej operacji.';

  @override
  String get errorNotFound => 'Element został usunięty lub zmieniony.';

  @override
  String get errorRouteAbsent => 'Funkcja niedostępna w tej wersji GI Home.';

  @override
  String get errorValidation => 'Sprawdź wprowadzone dane.';

  @override
  String get errorRateLimited => 'Zbyt wiele prób. Spróbuj ponownie za chwilę.';

  @override
  String get errorServer =>
      'Wystąpił błąd po stronie GI Home. Spróbuj ponownie.';

  @override
  String get errorUnexpectedResponse =>
      'GI Home zwrócił nieoczekiwaną odpowiedź. Sprawdź adres urządzenia.';

  @override
  String get errorUnexpectedShape =>
      'Nie udało się odczytać odpowiedzi GI Home. Aplikacja może wymagać aktualizacji.';

  @override
  String get errorUnauthorized => 'GI Home odrzucił żądanie. Spróbuj ponownie.';

  @override
  String get errorRefreshCookieMissing =>
      'GI Home nie przekazał danych sesji. Spróbuj zalogować się ponownie.';

  @override
  String get errorVaultUnavailable =>
      'Nie można odczytać danych logowania – spróbuj ponownie.';

  @override
  String get errorDifferentAppliance =>
      'Pod zapamiętanym adresem działa inny GI Home. Połącz się ponownie z właściwym urządzeniem.';

  @override
  String get errorApplianceReset =>
      'GI Home został zresetowany. Dokończ jego konfigurację, a potem zaloguj się ponownie.';

  @override
  String get errorCancelled => 'Operacja została przerwana.';

  @override
  String get errorGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get errorDeviceEntityNotFound =>
      'Ten element nie należy już do urządzenia. Odśwież widok.';

  @override
  String get errorDeviceNotFound =>
      'Urządzenie zostało usunięte lub zmienione. Odśwież widok.';

  @override
  String get errorHeatingSuspended =>
      'Ogrzewanie jest wstrzymane, więc nie można niczego włączyć. Najpierw wznów ogrzewanie.';

  @override
  String get errorEntityDisabled =>
      'Ten element jest wyłączony w konfiguracji urządzenia.';

  @override
  String get errorEntityNotWritable =>
      'Tym elementem nie można sterować z aplikacji.';

  @override
  String get errorDeviceOffline =>
      'Urządzenie jest offline. Polecenie nie zostało wysłane.';

  @override
  String get errorDeviceUnreachable =>
      'GI Home nie zna adresu sterownika. Polecenie nie zostało wysłane.';

  @override
  String get errorCommandUnconfirmed =>
      'Sterownik nie potwierdził polecenia. Stan jest nieznany – odśwież widok i sprawdź go przed kolejną próbą.';

  @override
  String get errorCommandTimeout =>
      'Sterownik nie odpowiedział na czas. Nie wiadomo, czy polecenie zostało wykonane – odśwież widok przed kolejną próbą.';

  @override
  String get errorDeviceHostForbidden =>
      'Adres sterownika jest poza siecią domową, więc GI Home go zablokował. Sprawdź konfigurację urządzenia w panelu GI Home.';

  @override
  String errorRequestId(String requestId) {
    return 'Identyfikator zgłoszenia: $requestId';
  }

  @override
  String get setupRequiredTitle => 'Dokończ konfigurację';

  @override
  String setupRequiredBody(String host) {
    return 'GI Home pod adresem $host nie jest jeszcze skonfigurowany. Dokończ konfigurację w przeglądarce, w panelu GI Home, a potem wróć do aplikacji.';
  }

  @override
  String get setupRequiredOpenPanel => 'Dokończ konfigurację w przeglądarce';

  @override
  String get setupRequiredOpenFailed => 'Nie udało się otworzyć przeglądarki.';

  @override
  String get setupRequiredCheckAgain => 'Sprawdź ponownie';

  @override
  String get setupRequiredStillNotInitialized =>
      'GI Home nadal nie jest skonfigurowany.';

  @override
  String setupRequiredDevHint(String command) {
    return 'Tryb deweloperski: panel web nie działa ze stosem dev. Zainicjalizuj backend poleceniem $command.';
  }

  @override
  String get restoreConnecting => 'Łączenie z GI Home…';

  @override
  String get restoreFailedTitle => 'Nie udało się połączyć z GI Home';

  @override
  String get restoreVaultUnavailableTitle =>
      'Dane logowania są chwilowo niedostępne';

  @override
  String get restoreVaultUnavailableHint =>
      'Spróbujemy ponownie, gdy wrócisz do aplikacji.';

  @override
  String get loginTitle => 'Zaloguj się';

  @override
  String loginSubtitle(String deviceName) {
    return 'do $deviceName';
  }

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginEmailInvalid => 'Wpisz poprawny adres e-mail.';

  @override
  String get loginPasswordLabel => 'Hasło';

  @override
  String get loginPasswordRequired => 'Wpisz hasło.';

  @override
  String get loginShowPassword => 'Pokaż hasło';

  @override
  String get loginHidePassword => 'Ukryj hasło';

  @override
  String get loginSubmit => 'Zaloguj';

  @override
  String get loginErrorInvalidCredentials => 'Nieprawidłowy e-mail lub hasło.';

  @override
  String get loginErrorUserDisabled =>
      'To konto jest wyłączone. Skontaktuj się z właścicielem GI Home.';

  @override
  String get loginErrorRateLimited => 'Zbyt wiele prób logowania.';

  @override
  String loginRetryCountdown(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Spróbuj ponownie za $seconds sekundy.',
      many: 'Spróbuj ponownie za $seconds sekund.',
      few: 'Spróbuj ponownie za $seconds sekundy.',
      one: 'Spróbuj ponownie za 1 sekundę.',
    );
    return '$_temp0';
  }

  @override
  String get sessionLostRevoked =>
      'Sesja wygasła lub została zakończona na innym urządzeniu (np. limit 10 zalogowanych urządzeń).';

  @override
  String get sessionLostExpired =>
      'Sesja wygasła po 30 dniach. Zaloguj się ponownie.';

  @override
  String get sessionLostUserDisabled => 'To konto zostało wyłączone.';

  @override
  String get sessionLostProtocol =>
      'Sesja została przerwana. Zaloguj się ponownie.';

  @override
  String get sessionLostVaultWiped =>
      'Nie udało się odczytać zapisanych danych logowania, więc zostały usunięte. Zaloguj się ponownie.';

  @override
  String get changePasswordTitle => 'Zmień hasło';

  @override
  String get changePasswordIntro =>
      'Ze względów bezpieczeństwa ustaw nowe hasło, zanim zaczniesz korzystać z aplikacji.';

  @override
  String get changePasswordCurrentLabel => 'Obecne hasło';

  @override
  String get changePasswordNewLabel => 'Nowe hasło';

  @override
  String get changePasswordRepeatLabel => 'Powtórz nowe hasło';

  @override
  String get changePasswordRules =>
      'Od 8 do 256 znaków, w tym mała i wielka litera oraz cyfra.';

  @override
  String get changePasswordSubmit => 'Zmień hasło i kontynuuj';

  @override
  String get changePasswordCurrentInvalid => 'Obecne hasło jest nieprawidłowe.';

  @override
  String get changePasswordSameAsCurrent =>
      'Nowe hasło musi różnić się od obecnego.';

  @override
  String changePasswordOtherSessionsEnded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hasło zostało zmienione. Wylogowano $count innego urządzenia.',
      many: 'Hasło zostało zmienione. Wylogowano $count innych urządzeń.',
      few: 'Hasło zostało zmienione. Wylogowano $count inne urządzenia.',
      one: 'Hasło zostało zmienione. Wylogowano 1 inne urządzenie.',
      zero: 'Hasło zostało zmienione.',
    );
    return '$_temp0';
  }

  @override
  String get passwordRequired => 'Wpisz hasło.';

  @override
  String get passwordTooShort => 'Hasło musi mieć co najmniej 8 znaków.';

  @override
  String get passwordTooLong => 'Hasło może mieć najwyżej 256 znaków.';

  @override
  String get passwordNeedsLowercase => 'Hasło musi zawierać małą literę.';

  @override
  String get passwordNeedsUppercase => 'Hasło musi zawierać wielką literę.';

  @override
  String get passwordNeedsDigit => 'Hasło musi zawierać cyfrę.';

  @override
  String get passwordMismatch => 'Hasła nie są takie same.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsApplianceSection => 'Urządzenie GI Home';

  @override
  String get settingsApplianceName => 'Nazwa';

  @override
  String get settingsApplianceAddress => 'Adres';

  @override
  String get settingsCleartext =>
      'HTTP – połączenie nieszyfrowane w sieci lokalnej';

  @override
  String get settingsEncrypted => 'HTTPS – połączenie szyfrowane';

  @override
  String get settingsLanOnly => 'Dostęp tylko w sieci domowej';

  @override
  String get settingsAccountSection => 'Konto';

  @override
  String get settingsUserName => 'Użytkownik';

  @override
  String get settingsUserEmail => 'E-mail';

  @override
  String get settingsUserRole => 'Rola';

  @override
  String settingsSessionValidUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Sesja ważna do $dateString';
  }

  @override
  String get settingsLogout => 'Wyloguj';

  @override
  String get settingsLogoutLocalOnly =>
      'Wylogowano z telefonu. Sesja na urządzeniu wygaśnie w ciągu 30 dni lub możesz ją usunąć w panelu web GI Home (Profil → Sesje).';

  @override
  String get settingsSwitchUser => 'Zmień użytkownika';

  @override
  String get settingsSwitchUserSubtitle =>
      'Wyloguj się i zaloguj na inne konto';

  @override
  String get settingsSwitchUserConfirmTitle => 'Zmienić użytkownika?';

  @override
  String settingsSwitchUserConfirmBody(String email) {
    return 'Konto $email zostanie wylogowane, a jego dane usunięte z tego telefonu. Potem zalogujesz się na inne konto.';
  }

  @override
  String get settingsChangeAppliance => 'Zmień urządzenie';

  @override
  String get settingsChangeApplianceConfirmTitle => 'Zmienić urządzenie?';

  @override
  String settingsChangeApplianceConfirmBody(String name) {
    return 'Spowoduje wylogowanie i usunięcie danych GI Home „$name” z tego telefonu.';
  }

  @override
  String settingsChangeApplianceConfirmBodyNoLogout(String name) {
    return 'Dane GI Home „$name” zostaną usunięte z tego telefonu. Teraz nie da się wylogować na urządzeniu, więc sesja pozostanie tam aktywna, dopóki nie wygaśnie (najpóźniej po 30 dniach).';
  }

  @override
  String get settingsLicenses => 'Licencje open source';

  @override
  String get settingsLicensesSubtitle => 'Biblioteki i fonty użyte w aplikacji';

  @override
  String get settingsDiagnosticReport => 'Wyślij raport diagnostyczny';

  @override
  String get settingsDiagnosticReportSubtitle =>
      'Błędy i liczniki techniczne, bez danych logowania';

  @override
  String get diagnosticReportTitle => 'Raport diagnostyczny';

  @override
  String get diagnosticReportIntro =>
      'Raport to plik JSON, który sam wysyłasz wybraną aplikacją. Nic nie jest wysyłane automatycznie.';

  @override
  String get diagnosticReportContains =>
      'Zawiera wersję aplikacji i systemu, język, liczniki (przyczyny wylogowań, błędy połączenia i odpowiedzi GI Home, czas uruchamiania) oraz ostatnie błędy aplikacji.';

  @override
  String get diagnosticReportExcludes =>
      'Hasła, tokeny, ciasteczka, adresy e-mail, kody odzyskiwania i adresy IP są usuwane przed zapisem. Raport nie zawiera danych z Twoich urządzeń.';

  @override
  String get diagnosticReportShare => 'Udostępnij';

  @override
  String get diagnosticReportSubject => 'Raport diagnostyczny GI Home';

  @override
  String get diagnosticReportFailed =>
      'Nie udało się przygotować raportu. Spróbuj ponownie.';

  @override
  String get settingsAppSection => 'Aplikacja';

  @override
  String get settingsAppVersion => 'Wersja aplikacji';

  @override
  String settingsAppVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get roleOwner => 'Właściciel';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleUser => 'Domownik';

  @override
  String get roleService => 'Serwis';

  @override
  String get roleUnknown => 'Nieznana rola';

  @override
  String get homeTitle => 'Dom';

  @override
  String get homeNoRoom => 'Bez pokoju';

  @override
  String get homeEmptyTitle => 'Brak urządzeń';

  @override
  String get homeEmptyBody =>
      'Dodaj urządzenia w panelu web GI Home, a pojawią się tutaj.';

  @override
  String get homeConditionGood => 'Wszystko w porządku';

  @override
  String get homeConditionNeedsAttention => 'Wymaga uwagi';

  @override
  String get homeConditionActionRequired => 'Wymaga działania';

  @override
  String get homeConditionLimitedData => 'Ograniczone dane';

  @override
  String get homeDevicesSection => 'Urządzenia';

  @override
  String staleDataBanner(String time) {
    return 'Dane mogą być nieaktualne (ostatnia aktualizacja $time)';
  }

  @override
  String lastSeen(String time) {
    return 'Ostatnio widziane $time';
  }

  @override
  String get lastSeenNever => 'Jeszcze nie połączone';

  @override
  String faultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usterki',
      many: '$count usterek',
      few: '$count usterki',
      one: '1 usterka',
      zero: 'Brak usterek',
    );
    return '$_temp0';
  }

  @override
  String get badgeHeatingSuspended => 'Ogrzewanie wstrzymane';

  @override
  String get badgeDryRun => 'Tryb testowy';

  @override
  String get dryRunBanner =>
      'Tryb testowy: przekaźniki nie przełączają się fizycznie';

  @override
  String get heatingSuspendedBanner => 'Ogrzewanie jest wstrzymane.';

  @override
  String get connectivityLostLocalControl =>
      'Brak łączności – lokalne sterowanie działa nadal';

  @override
  String get productStatusOnline => 'Działa';

  @override
  String get productStatusOffline => 'Offline';

  @override
  String get productStatusConnecting => 'Łączenie…';

  @override
  String get productStatusNeedsConfiguration => 'Wymaga konfiguracji';

  @override
  String get productStatusError => 'Błąd';

  @override
  String get productStatusUnknown => 'Nieznany stan';

  @override
  String get connectivityOnline => 'Połączone';

  @override
  String get connectivityStale => 'Brak świeżych danych';

  @override
  String get connectivityOffline => 'Brak łączności';

  @override
  String get connectivityProvisioning => 'Konfigurowanie';

  @override
  String get connectivityError => 'Błąd połączenia';

  @override
  String get connectivityUnknown => 'Nieznany stan łączności';

  @override
  String get deviceDetailsTitle => 'Szczegóły urządzenia';

  @override
  String get deviceNotFound => 'Urządzenie zostało usunięte lub zmienione.';

  @override
  String get deviceEntitiesSection => 'Elementy';

  @override
  String get deviceEntitiesEmpty => 'To urządzenie nie ma jeszcze elementów.';

  @override
  String get deviceDiagnosticsSection => 'Diagnostyka';

  @override
  String get deviceControllerState => 'Stan sterownika';

  @override
  String deviceValueFromList(String time) {
    return 'Z listy urządzeń · $time';
  }

  @override
  String get entityValueOn => 'Wł.';

  @override
  String get entityValueOff => 'Wył.';

  @override
  String get entityUnavailable => 'Niedostępny';

  @override
  String get entityDisabled => 'Wyłączony';

  @override
  String get entityDomainSensor => 'Czujnik';

  @override
  String get entityDomainSwitch => 'Przełącznik';

  @override
  String get entityDomainBinarySensor => 'Czujnik dwustanowy';

  @override
  String get entityDomainNumber => 'Wartość liczbowa';

  @override
  String get entityDomainSelect => 'Wybór';

  @override
  String get entityDomainClimate => 'Termostat';

  @override
  String get entityDomainTextSensor => 'Czujnik tekstowy';

  @override
  String get entityDomainButton => 'Przycisk';

  @override
  String get entityDomainUnknown => 'Inny element';

  @override
  String get timeJustNow => 'przed chwilą';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes min temu';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours godz. temu';
  }

  @override
  String get commonYes => 'Tak';

  @override
  String get commonNo => 'Nie';

  @override
  String get homeConditionGoodBody =>
      'Wszystkie urządzenia działają prawidłowo.';

  @override
  String homeConditionUpdated(String time) {
    return 'Aktualizacja: $time';
  }

  @override
  String get homeLimitedRefreshFailed =>
      'Nie udało się pobrać aktualnych danych.';

  @override
  String get homeLimitedOutdated => 'Dane są starsze niż 2 minuty.';

  @override
  String get homeLimitedNoDevices =>
      'GI Home nie ma jeszcze włączonych urządzeń.';

  @override
  String get homeAttentionSection => 'Wymaga sprawdzenia';

  @override
  String homeAttentionMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i $count innej sprawy',
      many: 'i $count innych spraw',
      few: 'i $count inne sprawy',
      one: 'i 1 inna sprawa',
    );
    return '$_temp0';
  }

  @override
  String get attentionFirmwareFault => 'Sterownik zgłasza awarię';

  @override
  String get attentionConnectivityError => 'Błąd połączenia z urządzeniem';

  @override
  String attentionHeatingFaults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usterki ogrzewania',
      many: '$count usterek ogrzewania',
      few: '$count usterki ogrzewania',
      one: '1 usterka ogrzewania',
    );
    return '$_temp0';
  }

  @override
  String get attentionStale => 'Brak świeżych danych z urządzenia';

  @override
  String get attentionNoData => 'Urządzenie nie przesłało jeszcze danych';

  @override
  String get homeHeatingDevice => 'Urządzenie grzewcze';

  @override
  String get homeDeviceDisabled => 'Wyłączone w panelu';

  @override
  String offlineBannerSince(String time) {
    return 'Brak połączenia z GI Home · dane z $time';
  }

  @override
  String refreshFailedBanner(String time) {
    return 'Nie udało się odświeżyć · dane z $time';
  }

  @override
  String get roomsUnavailableBanner =>
      'Nie udało się pobrać pokoi – urządzenia pokazujemy razem.';

  @override
  String get deviceInfoSection => 'Informacje';

  @override
  String get deviceStatusSection => 'Stan';

  @override
  String get deviceConnectivity => 'Łączność';

  @override
  String get deviceProductStatus => 'Stan urządzenia';

  @override
  String get deviceManufacturer => 'Producent';

  @override
  String get deviceModel => 'Model';

  @override
  String get deviceFirmware => 'Wersja oprogramowania';

  @override
  String get deviceRoom => 'Pokój';

  @override
  String get deviceFaults => 'Aktywne usterki';

  @override
  String get deviceNeedsAttention =>
      'Wymaga uwagi – sprawdź urządzenie w panelu web.';

  @override
  String deviceValueFromDiagnostics(String time) {
    return 'Z diagnostyki urządzenia · $time';
  }

  @override
  String get deviceFlagsSection => 'Tryby pracy';

  @override
  String get deviceFlagHeatingSuspended => 'Ogrzewanie wstrzymane';

  @override
  String get deviceFlagDryRun => 'Tryb testowy (bez przełączania przekaźników)';

  @override
  String get deviceFlagPvBoost => 'Dogrzewanie z nadwyżki PV';

  @override
  String get deviceDisabledBanner =>
      'To urządzenie jest wyłączone w panelu GI Home.';

  @override
  String get deviceDiagnosticsEmpty =>
      'Urządzenie nie przesłało jeszcze diagnostyki.';

  @override
  String get deviceDiagUptime => 'Czas pracy od uruchomienia';

  @override
  String get deviceDiagWifiRssi => 'Sygnał Wi-Fi';

  @override
  String get deviceDiagBootCount => 'Liczba uruchomień';

  @override
  String get deviceDiagRebootLoop => 'Wykryto pętlę restartów';

  @override
  String get deviceDiagSafetyInterlock => 'Blokada bezpieczeństwa aktywna';

  @override
  String get deviceDiagActiveFaults => 'Usterki w diagnostyce';

  @override
  String signalDbm(int value) {
    return '$value dBm';
  }

  @override
  String durationDaysHours(int days, int hours) {
    return '$days d $hours godz.';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours godz. $minutes min';
  }

  @override
  String get entityRoleHeatingRelay => 'Przekaźnik kotła';

  @override
  String get entityRolePumpRelay => 'Przekaźnik pompy';

  @override
  String get entityRoleControlTemperature => 'Temperatura sterująca';

  @override
  String get firmwareStateBoot => 'Uruchamianie';

  @override
  String get firmwareStateSelfTest => 'Autotest';

  @override
  String get firmwareStateReady => 'Gotowy';

  @override
  String get firmwareStateIdle => 'Czuwanie';

  @override
  String get firmwareStateHeatingRequested => 'Żądanie grzania';

  @override
  String get firmwareStateHeatingVerifying => 'Weryfikacja grzania';

  @override
  String get firmwareStateHeating => 'Grzanie';

  @override
  String get firmwareStateStopping => 'Zatrzymywanie';

  @override
  String get firmwareStateFault => 'Awaria';

  @override
  String get firmwareStateSafeMode => 'Tryb awaryjny';

  @override
  String get firmwareStateUnknown => 'Nieznany stan';

  @override
  String heatingCardSubtitle(String room) {
    return 'Urządzenie grzewcze · $room';
  }

  @override
  String get heatingCardBoiler => 'Kocioł';

  @override
  String get heatingCardBoilerOn => 'Grzeje';

  @override
  String get heatingCardBoilerOff => 'Nie grzeje';

  @override
  String get heatingCardPump => 'Pompa';

  @override
  String get heatingCardPumpOn => 'Pracuje';

  @override
  String get heatingCardPumpOff => 'Zatrzymana';

  @override
  String get heatingCardRelayNote =>
      'Stan przekaźników według polecenia sterownika';

  @override
  String get heatingCardControllerUnknown => 'Sterownik: brak danych';

  @override
  String get heatingCardLoading => 'Pobieranie szczegółów…';

  @override
  String heatingCardDataFrom(String time) {
    return 'Dane z $time';
  }

  @override
  String heatingCardFailedSince(String time) {
    return 'Nie udało się pobrać szczegółów · dane z $time';
  }

  @override
  String get heatingCardFailed => 'Nie udało się pobrać szczegółów ogrzewania';

  @override
  String get attentionNeedsConfiguration =>
      'Wymaga konfiguracji w panelu web GI Home';

  @override
  String get homeLimitedHeatingDetailsFailed =>
      'Nie udało się pobrać szczegółów ogrzewania.';

  @override
  String get experimentalTitle => 'Funkcje eksperymentalne';

  @override
  String get experimentalIntro =>
      'Dla testerów. Zmienione flagi zostają na tym telefonie, dopóki nie przywrócisz wartości domyślnych.';

  @override
  String get experimentalFlagsSection => 'Flagi funkcji';

  @override
  String get experimentalConfigSection => 'Konfiguracja';

  @override
  String get experimentalFlavor => 'Wariant aplikacji';

  @override
  String get experimentalNoDefines =>
      'Zbudowano bez pliku konfiguracji: wszystkie flagi są domyślnie wyłączone.';

  @override
  String get experimentalReset => 'Przywróć domyślne';

  @override
  String get experimentalResetDone => 'Przywrócono domyślne wartości flag.';

  @override
  String get experimentalChanged => 'Zmieniono na tym telefonie';

  @override
  String get experimentalDevOnly => 'Dostępne tylko w wariancie dev';

  @override
  String get flagMockCoreTitle => 'Atrapa GI Core';

  @override
  String get flagMockCoreDescription =>
      'Aplikacja rozmawia z wbudowaną atrapą zamiast z GI Core w sieci. Przełączenie tworzy połączenie od nowa.';

  @override
  String get flagScheduleClockConversionTitle =>
      'Przeliczanie godzin harmonogramów';

  @override
  String get flagScheduleClockConversionDescription =>
      'Godziny harmonogramów można edytować w czasie domu; aplikacja przelicza je na zegar GI Core.';

  @override
  String get flagSwitchControlByIntegrationTitle =>
      'Sterowanie przełącznikami według integracji';

  @override
  String get flagSwitchControlByIntegrationDescription =>
      'Przełącznikami można sterować zależnie od typu integracji urządzenia.';

  @override
  String get flagAndroidLocalNetworkPermissionRequestTitle =>
      'Prośba o dostęp do sieci lokalnej (Android)';

  @override
  String get flagAndroidLocalNetworkPermissionRequestDescription =>
      'Przed połączeniem aplikacja prosi o uprawnienie do urządzeń w pobliżu (ochrona sieci lokalnej).';

  @override
  String get permissionDeniedTitle => 'Brak dostępu';

  @override
  String get permissionDeniedBody =>
      'Twoja rola w GI Home nie pozwala oglądać tych danych. Jeśli to pomyłka, poproś właściciela lub administratora o zmianę roli.';

  @override
  String freshnessUpdated(String time) {
    return 'Zaktualizowano $time';
  }

  @override
  String freshnessUpdatedStale(String time) {
    return 'Zaktualizowano $time, dane mogą być nieaktualne';
  }

  @override
  String get staleAppTitle => 'Zaktualizuj aplikację';

  @override
  String get staleAppBody =>
      'Ta wersja aplikacji nie rozumie części odpowiedzi GI Home. Zainstaluj najnowszą wersję.';

  @override
  String get staleAppOpenStore => 'Otwórz sklep';

  @override
  String get staleAppDismiss => 'Ukryj komunikat';

  @override
  String get heatingViewOnlyHint =>
      'Zmiany ogrzewania może wprowadzić właściciel.';

  @override
  String get heatingDryRunBanner =>
      'Tryb testowy: polecenia są zapisywane, ale przekaźniki pozostają wyłączone.';

  @override
  String get lockNotOwnerAdmin =>
      'Zmiany ogrzewania może wprowadzić właściciel lub administrator. Poproś go o zmianę.';

  @override
  String get lockHeatingOrPumpRelay =>
      'Przekaźnikiem kotła i pompy steruje sterownik. W aplikacji jest tylko podgląd.';

  @override
  String get lockEntityMissing =>
      'Tego elementu nie ma już w urządzeniu. Odśwież widok.';

  @override
  String get lockNotWritableSwitch =>
      'Tego elementu nie da się przełączać z aplikacji.';

  @override
  String get lockEntityDisabled =>
      'Element jest wyłączony. Włącz go w panelu GI Home, aby nim sterować.';

  @override
  String get lockEntityUnavailable =>
      'Element jest niedostępny. Sprawdź połączenie urządzenia i spróbuj ponownie.';

  @override
  String get lockStaleData =>
      'Dane są nieaktualne, więc sterowanie jest zablokowane. Poczekaj na odświeżenie. Wstrzymanie ogrzewania działa nadal.';

  @override
  String get lockSuspendedOnRequest =>
      'Ogrzewanie jest wstrzymane. Wznów je, aby móc włączać przełączniki.';

  @override
  String get lockFaultLatched =>
      'Sterownik zgłasza usterkę lub tryb bezpieczny. Wymaga to autoryzowanego, ręcznego resetu na urządzeniu – w razie zagrożenia wezwij serwis.';

  @override
  String get consequenceStopsHeating =>
      'GI Home wyłączy ogrzewanie. Możesz je później wznowić.';

  @override
  String get consequenceBoilerMayStartSoon =>
      'Kocioł może się włączyć w ciągu ~30 s.';

  @override
  String get consequenceRestoresBaseOrSchedule =>
      'Wróci ustawienie domyślne lub aktywny harmonogram.';

  @override
  String get consequenceCommandNotPhysicallyVerified =>
      'Polecenie zostanie wysłane, ale aplikacja nie potwierdza fizycznego przełączenia przekaźnika.';

  @override
  String get consequenceLargeTargetRaise =>
      'Temperatura docelowa wzrośnie o ponad 10 °C.';

  @override
  String get consequenceLeavesOffMode =>
      'GI Home znów zacznie sterować kotłem i może go włączyć.';

  @override
  String get consequenceAboveSafeMax =>
      'Temperatura docelowa przekracza bezpieczne maksimum ustawione dla nadwyżki PV.';

  @override
  String get consequenceDryRunOutputsStayOff =>
      'Tryb testowy: polecenie zostanie zapisane, ale przekaźniki pozostaną wyłączone.';

  @override
  String get switchCommandSending => 'Wysyłanie…';

  @override
  String switchCommandLegacyConfirmed(String state, String time) {
    return 'Urządzenie potwierdziło polecenie: $state, $time. Fizyczny stan przekaźnika nie jest weryfikowany.';
  }

  @override
  String get switchCommandAwaitingHeartbeat =>
      'Zlecono · czeka na raport sterownika';

  @override
  String switchCommandHeartbeatObserved(String commanded, String output) {
    return 'Po poleceniu sterownik zgłosił: polecenie $commanded, wyjście $output – to nie potwierdza fizycznego stanu przekaźnika.';
  }

  @override
  String switchCommandDryRunRecorded(String commanded) {
    return 'Zapisano w trybie testowym: polecenie $commanded, wyjście pozostaje wyłączone.';
  }

  @override
  String get switchCommandTimedOut =>
      'Sterownik nie zgłosił się w ciągu 45 s – stan jest nieznany. Odśwież widok przed kolejną próbą.';

  @override
  String get entitySwitchAwaitingReport => 'czeka na raport sterownika';

  @override
  String switchControllerCommanded(String state) {
    return 'Polecenie sterownika: $state';
  }

  @override
  String switchDryRunWouldSet(String state) {
    return 'Sterownik chciałby: $state';
  }

  @override
  String get switchCommandNotReported => 'nie zgłoszono';

  @override
  String switchConfirmOnTitle(String name) {
    return 'Wysłać polecenie włączenia: $name?';
  }

  @override
  String get switchConfirmSend => 'Wyślij polecenie';

  @override
  String get actionRefresh => 'Odśwież';

  @override
  String heatingStrategyTarget(String temperature, String hysteresis) {
    return 'Cel $temperature °C, histereza $hysteresis °C';
  }

  @override
  String get heatingStrategyModeAuto => 'GI Home steruje kotłem';

  @override
  String get heatingStrategyModeOff =>
      'Sterowanie wyłączone – GI Home nie będzie włączać kotła';

  @override
  String get heatingStrategyModeManual => 'GI Home nie steruje automatycznie';

  @override
  String get heatingStrategyModeUnknown => 'Nieznany tryb sterowania';

  @override
  String get heatingStrategyNone =>
      'Brak ustawień sterowania – skonfiguruj je w panelu web GI Home';

  @override
  String get heatingScheduleActive => 'Harmonogram aktywny';

  @override
  String heatingStrategyDefault(String temperature, String hysteresis) {
    return 'Ustawienie domyślne: $temperature °C, histereza $hysteresis °C';
  }

  @override
  String get heatingSuspendedTitle => 'Ogrzewanie wstrzymane';

  @override
  String get heatingSuspendedEffect =>
      'GI Home nie włączy kotła, dopóki ogrzewanie nie zostanie wznowione.';

  @override
  String get heatingSuspendedResumeHint =>
      'Aby wznowić ogrzewanie, otwórz szczegóły urządzenia.';

  @override
  String get heatingSuspendedAskOwner =>
      'Wznowić ogrzewanie może właściciel lub administrator.';

  @override
  String get heatingResumeAction => 'Wznów ogrzewanie';

  @override
  String heatingPvBoost(String temperature) {
    return 'PV boost: grzanie do $temperature °C';
  }

  @override
  String get heatingPvBoostDerived =>
      'Cel wyliczony z limitu bezpieczeństwa PV';

  @override
  String get heatingPvBoostUnknownTarget => 'PV boost aktywny – cel nieznany';

  @override
  String heatingStrategySource(String time) {
    return 'Według GI Core · dane z $time';
  }

  @override
  String get heatingControlSection => 'Sterowanie ogrzewaniem';

  @override
  String get strategyEditAction => 'Zmień ustawienia sterowania';

  @override
  String get strategyEditorTitle => 'Ustawienia sterowania';

  @override
  String get strategyEditorIntro =>
      'Zmieniasz ustawienie domyślne. Aktywny harmonogram może je czasowo zastąpić.';

  @override
  String get strategyTargetLabel => 'Temperatura docelowa (°C)';

  @override
  String get strategyHysteresisLabel => 'Histereza (°C)';

  @override
  String get strategyModeLabel => 'Tryb sterowania';

  @override
  String get strategyModeAutoShort => 'Auto';

  @override
  String get strategyModeOffShort => 'Wył.';

  @override
  String get strategyModeManualShort => 'Ręczny';

  @override
  String get strategyErrorNotANumber => 'Wpisz liczbę';

  @override
  String strategyErrorRange(String min, String max) {
    return 'Dozwolony zakres: $min–$max °C';
  }

  @override
  String strategyErrorStep(String step) {
    return 'Podaj wartość co $step °C';
  }

  @override
  String strategyAboveSafeMaxWarning(String temperature) {
    return 'To więcej niż bezpieczne maksimum dla nadwyżki PV ($temperature °C).';
  }

  @override
  String get strategySuspendedNote =>
      'Ogrzewanie jest wstrzymane. Zapisane ustawienie zacznie obowiązywać po wznowieniu – do tego czasu tryb efektywny to Wył.';

  @override
  String get strategySave => 'Zapisz';

  @override
  String get strategyChecking => 'Sprawdzanie aktualnych ustawień…';

  @override
  String get strategySaving => 'Zapisywanie…';

  @override
  String get strategyConflictTitle => 'Ktoś zmienił ustawienia w międzyczasie';

  @override
  String get strategyConflictBody =>
      'Nic nie zostało zapisane. Sprawdź, co się zmieniło, i zdecyduj, co dalej.';

  @override
  String strategyConflictRow(String field, String before, String after) {
    return '$field: $before → $after';
  }

  @override
  String get strategyFieldTarget => 'Temperatura docelowa';

  @override
  String get strategyFieldHysteresis => 'Histereza';

  @override
  String get strategyFieldMode => 'Tryb';

  @override
  String get strategyFieldSuspended => 'Ogrzewanie';

  @override
  String get strategyValueNone => 'brak';

  @override
  String get strategyValueSuspended => 'wstrzymane';

  @override
  String get strategyValueActive => 'aktywne';

  @override
  String get strategyConflictReapply => 'Zapisz moje zmiany mimo to';

  @override
  String get strategyConflictDiscard => 'Odrzuć moje zmiany';

  @override
  String get strategySavedTitle => 'Zapisano w GI Core';

  @override
  String strategySavedBase(String value) {
    return 'Ustawienie domyślne: $value';
  }

  @override
  String strategySavedEffective(String value) {
    return 'Obowiązuje teraz: $value';
  }

  @override
  String get strategySavedSuspended =>
      'Ogrzewanie jest wstrzymane, więc tryb efektywny pozostaje Wył. do czasu wznowienia.';

  @override
  String strategyValue(String target, String hysteresis, String mode) {
    return '$target °C, histereza $hysteresis °C, $mode';
  }

  @override
  String get strategyConfirmTitle => 'Potwierdź zmianę ustawień';

  @override
  String get strategyConfirmSave => 'Zapisz zmiany';

  @override
  String get suspendHoldAction => 'Przytrzymaj, aby wstrzymać ogrzewanie';

  @override
  String get suspendHoldHint =>
      'Przytrzymaj przycisk – zwykłe dotknięcie niczego nie zmienia.';

  @override
  String get suspendA11yHint => 'otwiera potwierdzenie wstrzymania';

  @override
  String get suspendConfirmTitle => 'Wstrzymać ogrzewanie?';

  @override
  String get suspendConfirmAction => 'Wstrzymaj ogrzewanie';

  @override
  String get suspendAwaiting =>
      'Wysłano · czekamy, aż GI Core potwierdzi wstrzymanie';

  @override
  String get resumeAwaiting =>
      'Wysłano · czekamy, aż GI Core potwierdzi wznowienie';

  @override
  String get suspendAppliedAwaitingHeartbeat =>
      'Ogrzewanie wstrzymane. Zlecono wyłączenie przekaźników · czeka na raport sterownika';

  @override
  String suspendAppliedOutputsOff(String time) {
    return 'Ogrzewanie wstrzymane. Raport sterownika z $time: wyjścia przekaźników wyłączone. To nie potwierdza fizycznego stanu przekaźników.';
  }

  @override
  String suspendAppliedOutputOn(String time) {
    return 'Ogrzewanie wstrzymane, ale raport sterownika z $time wciąż pokazuje włączone wyjście. Odśwież za chwilę, a w razie zagrożenia wyłącz kocioł ręcznie.';
  }

  @override
  String get suspendAppliedNotReported =>
      'Ogrzewanie wstrzymane. Zlecono wyłączenie przekaźników, ale sterownik nie raportuje stanu wyjść.';

  @override
  String get suspendAppliedNoHeartbeat =>
      'Ogrzewanie wstrzymane. Zlecono wyłączenie przekaźników, ale sterownik nie zgłosił się w ciągu 45 s – stan przekaźników jest nieznany.';

  @override
  String get suspendAppliedLegacy =>
      'Ogrzewanie wstrzymane w GI Core. To urządzenie ESPHome nie dostaje poleceń wyłączenia przekaźników – GI Home po prostu nie będzie włączać kotła.';

  @override
  String get resumeApplied =>
      'Ogrzewanie wznowione. Znów obowiązuje ustawienie domyślne lub harmonogram.';

  @override
  String get resumeAppliedPending =>
      'Ogrzewanie wznowione. GI Core nie przywrócił jeszcze trybu sterowania – odśwież za chwilę.';

  @override
  String get suspendTimedOut =>
      'GI Core nie potwierdził wstrzymania w ciągu 30 s. Odśwież widok i sprawdź stan.';

  @override
  String get resumeTimedOut =>
      'GI Core nie potwierdził wznowienia w ciągu 30 s. Odśwież widok i sprawdź stan.';

  @override
  String get resumeSheetTitle => 'Wznowić ogrzewanie?';

  @override
  String resumeSheetWillApply(String value) {
    return 'Zacznie obowiązywać: $value';
  }

  @override
  String resumeSheetTemperature(String value, String time) {
    return 'Temperatura sterująca: $value · dane z $time';
  }

  @override
  String get resumeSheetTemperatureMissing =>
      'Brak aktualnego odczytu temperatury sterującej.';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageAutomatic => 'Automatycznie';

  @override
  String get settingsLanguageAutomaticSubtitle =>
      'Język z profilu GI Home, a bez niego język telefonu';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageDialogTitle => 'Język aplikacji';

  @override
  String get settingsCoreVersion => 'Wersja oprogramowania GI Home';

  @override
  String settingsCoreVersionSubtitle(String version) {
    return '$version (według ostatniego sprawdzenia aktualizacji)';
  }

  @override
  String get settingsTimezone => 'Strefa czasowa urządzenia';

  @override
  String settingsSessionRenewSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Za $days dnia trzeba będzie zalogować się ponownie',
      many: 'Za $days dni trzeba będzie zalogować się ponownie',
      few: 'Za $days dni trzeba będzie zalogować się ponownie',
      one: 'Za 1 dzień trzeba będzie zalogować się ponownie',
      zero: 'Sesja wygasła – zaloguj się ponownie',
    );
    return '$_temp0';
  }

  @override
  String get demoEntryTitle => 'Nie masz jeszcze GI Home?';

  @override
  String get demoEntryBody =>
      'Zobacz aplikację na przykładowym domu. Dane są zmyślone i zostają w pamięci telefonu, a polecenia nie trafiają do żadnego urządzenia.';

  @override
  String get demoEnter => 'Wypróbuj wersję demonstracyjną';

  @override
  String get demoStartFailed =>
      'Nie udało się uruchomić wersji demonstracyjnej. Spróbuj ponownie.';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get demoBadgeSemantics => 'Wersja demonstracyjna';

  @override
  String get demoBannerMessage =>
      'Przykładowe dane – nic nie jest naprawdę sterowane.';

  @override
  String get demoExit => 'Zakończ demo';
}
