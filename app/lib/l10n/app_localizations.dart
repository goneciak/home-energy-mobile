import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pl'),
    Locale('en'),
  ];

  /// Application name.
  ///
  /// In pl, this message translates to:
  /// **'GI Home'**
  String get appTitle;

  /// No description provided for @actionRetry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get actionRetry;

  /// No description provided for @actionCancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get actionClose;

  /// No description provided for @actionChangeAppliance.
  ///
  /// In pl, this message translates to:
  /// **'Zmień urządzenie'**
  String get actionChangeAppliance;

  /// Opens this app's page in the phone's system settings, e.g. to allow local network access.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz ustawienia'**
  String get actionOpenSettings;

  /// Opens the connect screen, which searches the home network for GI Home appliances.
  ///
  /// In pl, this message translates to:
  /// **'Znajdź GI Home'**
  String get actionFindAppliance;

  /// No description provided for @commonLoading.
  ///
  /// In pl, this message translates to:
  /// **'Ładowanie…'**
  String get commonLoading;

  /// No description provided for @commonNoData.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych'**
  String get commonNoData;

  /// Shown in place of a missing value; pair it with the commonNoData semantics label.
  ///
  /// In pl, this message translates to:
  /// **'—'**
  String get commonNoDataValue;

  /// No description provided for @navHome.
  ///
  /// In pl, this message translates to:
  /// **'Dom'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get navSettings;

  /// No description provided for @connectTitle.
  ///
  /// In pl, this message translates to:
  /// **'Połącz z GI Home'**
  String get connectTitle;

  /// No description provided for @connectIntro.
  ///
  /// In pl, this message translates to:
  /// **'Telefon musi być w tej samej sieci Wi-Fi co GI Home. Wybierz znalezione urządzenie albo wpisz jego adres.'**
  String get connectIntro;

  /// No description provided for @connectAddressLabel.
  ///
  /// In pl, this message translates to:
  /// **'Adres GI Home'**
  String get connectAddressLabel;

  /// No description provided for @connectAddressHint.
  ///
  /// In pl, this message translates to:
  /// **'np. gi-home.local lub 192.168.1.20'**
  String get connectAddressHint;

  /// No description provided for @connectAddressRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz adres GI Home'**
  String get connectAddressRequired;

  /// No description provided for @connectSearchTitle.
  ///
  /// In pl, this message translates to:
  /// **'Znajdź GI Home'**
  String get connectSearchTitle;

  /// No description provided for @connectSearching.
  ///
  /// In pl, this message translates to:
  /// **'Szukam GI Home…'**
  String get connectSearching;

  /// No description provided for @connectSearchNoneFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono GI Home w tej sieci. Wpisz jego adres poniżej.'**
  String get connectSearchNoneFound;

  /// No description provided for @connectSearchAgain.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj ponownie'**
  String get connectSearchAgain;

  /// Marks the found appliance that is the one already saved on this phone.
  ///
  /// In pl, this message translates to:
  /// **'Obecne urządzenie'**
  String get connectCandidateCurrent;

  /// Marks a found appliance that has not been set up yet.
  ///
  /// In pl, this message translates to:
  /// **'Nieskonfigurowane'**
  String get connectCandidateNotSetUp;

  /// No description provided for @connectManualTitle.
  ///
  /// In pl, this message translates to:
  /// **'Albo wpisz adres'**
  String get connectManualTitle;

  /// No description provided for @connectHintsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podpowiedzi'**
  String get connectHintsTitle;

  /// No description provided for @connectHintAndroidEmulator.
  ///
  /// In pl, this message translates to:
  /// **'Emulator Androida'**
  String get connectHintAndroidEmulator;

  /// No description provided for @connectHintIosSimulator.
  ///
  /// In pl, this message translates to:
  /// **'Symulator iOS'**
  String get connectHintIosSimulator;

  /// No description provided for @connectHintAndroidUsb.
  ///
  /// In pl, this message translates to:
  /// **'Android przez USB'**
  String get connectHintAndroidUsb;

  /// No description provided for @connectHintLanPhone.
  ///
  /// In pl, this message translates to:
  /// **'Telefon w LAN'**
  String get connectHintLanPhone;

  /// No description provided for @connectHintLanProxy.
  ///
  /// In pl, this message translates to:
  /// **'Przez dev_lan_proxy'**
  String get connectHintLanProxy;

  /// Placeholder shown in a dev address preset where the developer types the computer's LAN IP address.
  ///
  /// In pl, this message translates to:
  /// **'IP-komputera'**
  String get connectHintComputerIp;

  /// No description provided for @connectHintUsbNote.
  ///
  /// In pl, this message translates to:
  /// **'Android przez USB: najpierw uruchom na komputerze {command}, a potem połącz się z localhost:3000.'**
  String connectHintUsbNote(String command);

  /// No description provided for @connectHintProxyNote.
  ///
  /// In pl, this message translates to:
  /// **'Przez dev_lan_proxy: gdy GI Core zostaje na loopbacku, forwarder na komputerze przekazuje port 8080 do 127.0.0.1:3000. Wpisz IP komputera przed :8080.'**
  String get connectHintProxyNote;

  /// No description provided for @connectHintLan.
  ///
  /// In pl, this message translates to:
  /// **'Telefon w sieci Wi-Fi: wpisz adres IP komputera w sieci LAN przed :3000. Backend musi działać z GI_CORE_BIND_ADDRESS=0.0.0.0 (dev-up -Lan), a port 3000 musi być otwarty w zaporze.'**
  String get connectHintLan;

  /// No description provided for @connectSubmit.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź'**
  String get connectSubmit;

  /// No description provided for @connectProbing.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdzam adres…'**
  String get connectProbing;

  /// No description provided for @connectConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Czy to Twój GI Home?'**
  String get connectConfirmTitle;

  /// No description provided for @connectConfirmSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'{deviceName} · {host}'**
  String connectConfirmSubtitle(String deviceName, String host);

  /// No description provided for @connectNotInitializedNote.
  ///
  /// In pl, this message translates to:
  /// **'To urządzenie nie jest jeszcze skonfigurowane.'**
  String get connectNotInitializedNote;

  /// No description provided for @connectCleartextNote.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie w sieci domowej nie jest szyfrowane. Używaj tylko w zaufanej sieci Wi-Fi.'**
  String get connectCleartextNote;

  /// No description provided for @connectConfirmYes.
  ///
  /// In pl, this message translates to:
  /// **'Tak, połącz'**
  String get connectConfirmYes;

  /// No description provided for @connectConfirmNo.
  ///
  /// In pl, this message translates to:
  /// **'Nie, wpisz inny adres'**
  String get connectConfirmNo;

  /// No description provided for @connectErrorInvalidAddress.
  ///
  /// In pl, this message translates to:
  /// **'To nie wygląda na poprawny adres. Wpisz nazwę, adres IP lub URL GI Home.'**
  String get connectErrorInvalidAddress;

  /// No description provided for @connectErrorNotGiHome.
  ///
  /// In pl, this message translates to:
  /// **'Pod tym adresem odpowiada inne urządzenie, nie GI Home.'**
  String get connectErrorNotGiHome;

  /// No description provided for @errorUnreachable.
  ///
  /// In pl, this message translates to:
  /// **'Nie można połączyć się z GI Home. Sprawdź, czy telefon jest w tej samej sieci Wi-Fi.'**
  String get errorUnreachable;

  /// No description provided for @errorTimeout.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie odpowiedział na czas. Spróbuj ponownie.'**
  String get errorTimeout;

  /// No description provided for @errorTlsUntrusted.
  ///
  /// In pl, this message translates to:
  /// **'Certyfikat serwera nie jest zaufany – użyj http:// w sieci domowej lub certyfikatu z publicznego CA.'**
  String get errorTlsUntrusted;

  /// No description provided for @errorLocalNetworkDenied.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie ma dostępu do sieci lokalnej. Zezwól na dostęp w Ustawieniach telefonu.'**
  String get errorLocalNetworkDenied;

  /// No description provided for @errorInsecureTransport.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie nieszyfrowane (http://) jest dozwolone tylko w sieci domowej. Dla innych adresów użyj https://.'**
  String get errorInsecureTransport;

  /// No description provided for @errorForbidden.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz uprawnień do tej operacji.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Element został usunięty lub zmieniony.'**
  String get errorNotFound;

  /// No description provided for @errorRouteAbsent.
  ///
  /// In pl, this message translates to:
  /// **'Funkcja niedostępna w tej wersji GI Home.'**
  String get errorRouteAbsent;

  /// No description provided for @errorValidation.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź wprowadzone dane.'**
  String get errorValidation;

  /// No description provided for @errorRateLimited.
  ///
  /// In pl, this message translates to:
  /// **'Zbyt wiele prób. Spróbuj ponownie za chwilę.'**
  String get errorRateLimited;

  /// No description provided for @errorServer.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił błąd po stronie GI Home. Spróbuj ponownie.'**
  String get errorServer;

  /// No description provided for @errorMaintenance.
  ///
  /// In pl, this message translates to:
  /// **'GI Home jest chwilowo niedostępny – uruchamia się lub trwa konserwacja. Spróbuj ponownie za kilka minut.'**
  String get errorMaintenance;

  /// No description provided for @errorUnexpectedResponse.
  ///
  /// In pl, this message translates to:
  /// **'GI Home zwrócił nieoczekiwaną odpowiedź. Sprawdź adres urządzenia.'**
  String get errorUnexpectedResponse;

  /// No description provided for @errorUnexpectedShape.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać odpowiedzi GI Home. Aplikacja może wymagać aktualizacji.'**
  String get errorUnexpectedShape;

  /// No description provided for @errorUnauthorized.
  ///
  /// In pl, this message translates to:
  /// **'GI Home odrzucił żądanie. Spróbuj ponownie.'**
  String get errorUnauthorized;

  /// No description provided for @errorRefreshCookieMissing.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie przekazał danych sesji. Spróbuj zalogować się ponownie.'**
  String get errorRefreshCookieMissing;

  /// No description provided for @errorVaultUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Nie można odczytać danych logowania – spróbuj ponownie.'**
  String get errorVaultUnavailable;

  /// No description provided for @errorDifferentAppliance.
  ///
  /// In pl, this message translates to:
  /// **'Pod zapamiętanym adresem działa inny GI Home. Połącz się ponownie z właściwym urządzeniem.'**
  String get errorDifferentAppliance;

  /// No description provided for @errorApplianceReset.
  ///
  /// In pl, this message translates to:
  /// **'GI Home został zresetowany. Dokończ jego konfigurację, a potem zaloguj się ponownie.'**
  String get errorApplianceReset;

  /// No description provided for @errorCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Operacja została przerwana.'**
  String get errorCancelled;

  /// No description provided for @errorGeneric.
  ///
  /// In pl, this message translates to:
  /// **'Coś poszło nie tak. Spróbuj ponownie.'**
  String get errorGeneric;

  /// No description provided for @errorDeviceEntityNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Ten element nie należy już do urządzenia. Odśwież widok.'**
  String get errorDeviceEntityNotFound;

  /// No description provided for @errorDeviceNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie zostało usunięte lub zmienione. Odśwież widok.'**
  String get errorDeviceNotFound;

  /// No description provided for @errorHeatingSuspended.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie jest wstrzymane, więc nie można niczego włączyć. Najpierw wznów ogrzewanie.'**
  String get errorHeatingSuspended;

  /// No description provided for @errorEntityDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Ten element jest wyłączony w konfiguracji urządzenia.'**
  String get errorEntityDisabled;

  /// No description provided for @errorEntityNotWritable.
  ///
  /// In pl, this message translates to:
  /// **'Tym elementem nie można sterować z aplikacji.'**
  String get errorEntityNotWritable;

  /// No description provided for @errorDeviceOffline.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie jest offline. Polecenie nie zostało wysłane.'**
  String get errorDeviceOffline;

  /// No description provided for @errorDeviceUnreachable.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie zna adresu sterownika. Polecenie nie zostało wysłane.'**
  String get errorDeviceUnreachable;

  /// No description provided for @errorCommandUnconfirmed.
  ///
  /// In pl, this message translates to:
  /// **'Sterownik nie potwierdził polecenia. Stan jest nieznany – odśwież widok i sprawdź go przed kolejną próbą.'**
  String get errorCommandUnconfirmed;

  /// No description provided for @errorCommandTimeout.
  ///
  /// In pl, this message translates to:
  /// **'Sterownik nie odpowiedział na czas. Nie wiadomo, czy polecenie zostało wykonane – odśwież widok przed kolejną próbą.'**
  String get errorCommandTimeout;

  /// No description provided for @errorDeviceHostForbidden.
  ///
  /// In pl, this message translates to:
  /// **'Adres sterownika jest poza siecią domową, więc GI Home go zablokował. Sprawdź konfigurację urządzenia w panelu GI Home.'**
  String get errorDeviceHostForbidden;

  /// No description provided for @errorRequestId.
  ///
  /// In pl, this message translates to:
  /// **'Identyfikator zgłoszenia: {requestId}'**
  String errorRequestId(String requestId);

  /// No description provided for @setupRequiredTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dokończ konfigurację'**
  String get setupRequiredTitle;

  /// No description provided for @setupRequiredBody.
  ///
  /// In pl, this message translates to:
  /// **'GI Home pod adresem {host} nie jest jeszcze skonfigurowany. Dokończ konfigurację w przeglądarce, w panelu GI Home, a potem wróć do aplikacji.'**
  String setupRequiredBody(String host);

  /// No description provided for @setupRequiredOpenPanel.
  ///
  /// In pl, this message translates to:
  /// **'Dokończ konfigurację w przeglądarce'**
  String get setupRequiredOpenPanel;

  /// No description provided for @setupRequiredOpenFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć przeglądarki.'**
  String get setupRequiredOpenFailed;

  /// No description provided for @setupRequiredCheckAgain.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź ponownie'**
  String get setupRequiredCheckAgain;

  /// No description provided for @setupRequiredStillNotInitialized.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nadal nie jest skonfigurowany.'**
  String get setupRequiredStillNotInitialized;

  /// No description provided for @setupRequiredDevHint.
  ///
  /// In pl, this message translates to:
  /// **'Tryb deweloperski: panel web nie działa ze stosem dev. Zainicjalizuj backend poleceniem {command}.'**
  String setupRequiredDevHint(String command);

  /// No description provided for @restoreConnecting.
  ///
  /// In pl, this message translates to:
  /// **'Łączenie z GI Home…'**
  String get restoreConnecting;

  /// No description provided for @restoreFailedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się połączyć z GI Home'**
  String get restoreFailedTitle;

  /// No description provided for @restoreVaultUnavailableTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dane logowania są chwilowo niedostępne'**
  String get restoreVaultUnavailableTitle;

  /// No description provided for @restoreVaultUnavailableHint.
  ///
  /// In pl, this message translates to:
  /// **'Spróbujemy ponownie, gdy wrócisz do aplikacji.'**
  String get restoreVaultUnavailableHint;

  /// No description provided for @loginTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'do {deviceName}'**
  String loginSubtitle(String deviceName);

  /// No description provided for @loginEmailLabel.
  ///
  /// In pl, this message translates to:
  /// **'E-mail'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawny adres e-mail.'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In pl, this message translates to:
  /// **'Hasło'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz hasło.'**
  String get loginPasswordRequired;

  /// No description provided for @loginShowPassword.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż hasło'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In pl, this message translates to:
  /// **'Ukryj hasło'**
  String get loginHidePassword;

  /// No description provided for @loginSubmit.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj'**
  String get loginSubmit;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy e-mail lub hasło.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorUserDisabled.
  ///
  /// In pl, this message translates to:
  /// **'To konto jest wyłączone. Skontaktuj się z właścicielem GI Home.'**
  String get loginErrorUserDisabled;

  /// No description provided for @loginErrorRateLimited.
  ///
  /// In pl, this message translates to:
  /// **'Zbyt wiele prób logowania.'**
  String get loginErrorRateLimited;

  /// No description provided for @loginRetryCountdown.
  ///
  /// In pl, this message translates to:
  /// **'{seconds, plural, one{Spróbuj ponownie za 1 sekundę.} few{Spróbuj ponownie za {seconds} sekundy.} many{Spróbuj ponownie za {seconds} sekund.} other{Spróbuj ponownie za {seconds} sekundy.}}'**
  String loginRetryCountdown(int seconds);

  /// No description provided for @sessionLostRevoked.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła lub została zakończona na innym urządzeniu (np. limit 10 zalogowanych urządzeń).'**
  String get sessionLostRevoked;

  /// No description provided for @sessionLostExpired.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła po 30 dniach. Zaloguj się ponownie.'**
  String get sessionLostExpired;

  /// No description provided for @sessionLostUserDisabled.
  ///
  /// In pl, this message translates to:
  /// **'To konto zostało wyłączone.'**
  String get sessionLostUserDisabled;

  /// No description provided for @sessionLostProtocol.
  ///
  /// In pl, this message translates to:
  /// **'Sesja została przerwana. Zaloguj się ponownie.'**
  String get sessionLostProtocol;

  /// No description provided for @sessionLostVaultWiped.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać zapisanych danych logowania, więc zostały usunięte. Zaloguj się ponownie.'**
  String get sessionLostVaultWiped;

  /// No description provided for @changePasswordTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zmień hasło'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordIntro.
  ///
  /// In pl, this message translates to:
  /// **'Ze względów bezpieczeństwa ustaw nowe hasło, zanim zaczniesz korzystać z aplikacji.'**
  String get changePasswordIntro;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Obecne hasło'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nowe hasło'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordRepeatLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powtórz nowe hasło'**
  String get changePasswordRepeatLabel;

  /// No description provided for @changePasswordRules.
  ///
  /// In pl, this message translates to:
  /// **'Od 8 do 256 znaków, w tym mała i wielka litera oraz cyfra.'**
  String get changePasswordRules;

  /// No description provided for @changePasswordSubmit.
  ///
  /// In pl, this message translates to:
  /// **'Zmień hasło i kontynuuj'**
  String get changePasswordSubmit;

  /// No description provided for @changePasswordCurrentInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Obecne hasło jest nieprawidłowe.'**
  String get changePasswordCurrentInvalid;

  /// No description provided for @changePasswordSameAsCurrent.
  ///
  /// In pl, this message translates to:
  /// **'Nowe hasło musi różnić się od obecnego.'**
  String get changePasswordSameAsCurrent;

  /// No description provided for @changePasswordOtherSessionsEnded.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =0{Hasło zostało zmienione.} one{Hasło zostało zmienione. Wylogowano 1 inne urządzenie.} few{Hasło zostało zmienione. Wylogowano {count} inne urządzenia.} many{Hasło zostało zmienione. Wylogowano {count} innych urządzeń.} other{Hasło zostało zmienione. Wylogowano {count} innego urządzenia.}}'**
  String changePasswordOtherSessionsEnded(int count);

  /// No description provided for @passwordRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz hasło.'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In pl, this message translates to:
  /// **'Hasło musi mieć co najmniej 8 znaków.'**
  String get passwordTooShort;

  /// No description provided for @passwordTooLong.
  ///
  /// In pl, this message translates to:
  /// **'Hasło może mieć najwyżej 256 znaków.'**
  String get passwordTooLong;

  /// No description provided for @passwordNeedsLowercase.
  ///
  /// In pl, this message translates to:
  /// **'Hasło musi zawierać małą literę.'**
  String get passwordNeedsLowercase;

  /// No description provided for @passwordNeedsUppercase.
  ///
  /// In pl, this message translates to:
  /// **'Hasło musi zawierać wielką literę.'**
  String get passwordNeedsUppercase;

  /// No description provided for @passwordNeedsDigit.
  ///
  /// In pl, this message translates to:
  /// **'Hasło musi zawierać cyfrę.'**
  String get passwordNeedsDigit;

  /// No description provided for @passwordMismatch.
  ///
  /// In pl, this message translates to:
  /// **'Hasła nie są takie same.'**
  String get passwordMismatch;

  /// No description provided for @settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTitle;

  /// No description provided for @settingsApplianceSection.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie GI Home'**
  String get settingsApplianceSection;

  /// No description provided for @settingsApplianceName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get settingsApplianceName;

  /// No description provided for @settingsApplianceAddress.
  ///
  /// In pl, this message translates to:
  /// **'Adres'**
  String get settingsApplianceAddress;

  /// No description provided for @settingsCleartext.
  ///
  /// In pl, this message translates to:
  /// **'HTTP – połączenie nieszyfrowane w sieci lokalnej'**
  String get settingsCleartext;

  /// No description provided for @settingsEncrypted.
  ///
  /// In pl, this message translates to:
  /// **'HTTPS – połączenie szyfrowane'**
  String get settingsEncrypted;

  /// No description provided for @settingsLanOnly.
  ///
  /// In pl, this message translates to:
  /// **'Dostęp tylko w sieci domowej'**
  String get settingsLanOnly;

  /// No description provided for @settingsAccountSection.
  ///
  /// In pl, this message translates to:
  /// **'Konto'**
  String get settingsAccountSection;

  /// No description provided for @settingsUserName.
  ///
  /// In pl, this message translates to:
  /// **'Użytkownik'**
  String get settingsUserName;

  /// No description provided for @settingsUserEmail.
  ///
  /// In pl, this message translates to:
  /// **'E-mail'**
  String get settingsUserEmail;

  /// No description provided for @settingsUserRole.
  ///
  /// In pl, this message translates to:
  /// **'Rola'**
  String get settingsUserRole;

  /// No description provided for @settingsSessionValidUntil.
  ///
  /// In pl, this message translates to:
  /// **'Sesja ważna do {date}'**
  String settingsSessionValidUntil(DateTime date);

  /// No description provided for @settingsLogout.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutLocalOnly.
  ///
  /// In pl, this message translates to:
  /// **'Wylogowano z telefonu. Sesja na urządzeniu wygaśnie w ciągu 30 dni lub możesz ją usunąć w panelu web GI Home (Profil → Sesje).'**
  String get settingsLogoutLocalOnly;

  /// No description provided for @settingsSwitchUser.
  ///
  /// In pl, this message translates to:
  /// **'Zmień użytkownika'**
  String get settingsSwitchUser;

  /// No description provided for @settingsSwitchUserSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj się i zaloguj na inne konto'**
  String get settingsSwitchUserSubtitle;

  /// No description provided for @settingsSwitchUserConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zmienić użytkownika?'**
  String get settingsSwitchUserConfirmTitle;

  /// No description provided for @settingsSwitchUserConfirmBody.
  ///
  /// In pl, this message translates to:
  /// **'Konto {email} zostanie wylogowane, a jego dane usunięte z tego telefonu. Potem zalogujesz się na inne konto.'**
  String settingsSwitchUserConfirmBody(String email);

  /// No description provided for @settingsChangeAppliance.
  ///
  /// In pl, this message translates to:
  /// **'Zmień urządzenie'**
  String get settingsChangeAppliance;

  /// No description provided for @settingsChangeApplianceConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zmienić urządzenie?'**
  String get settingsChangeApplianceConfirmTitle;

  /// No description provided for @settingsChangeApplianceConfirmBody.
  ///
  /// In pl, this message translates to:
  /// **'Spowoduje wylogowanie i usunięcie danych GI Home „{name}” z tego telefonu.'**
  String settingsChangeApplianceConfirmBody(String name);

  /// No description provided for @settingsChangeApplianceConfirmBodyNoLogout.
  ///
  /// In pl, this message translates to:
  /// **'Dane GI Home „{name}” zostaną usunięte z tego telefonu. Teraz nie da się wylogować na urządzeniu, więc sesja pozostanie tam aktywna, dopóki nie wygaśnie (najpóźniej po 30 dniach).'**
  String settingsChangeApplianceConfirmBodyNoLogout(String name);

  /// No description provided for @settingsLicenses.
  ///
  /// In pl, this message translates to:
  /// **'Licencje open source'**
  String get settingsLicenses;

  /// No description provided for @settingsLicensesSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Biblioteki i fonty użyte w aplikacji'**
  String get settingsLicensesSubtitle;

  /// No description provided for @settingsDiagnosticReport.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij raport diagnostyczny'**
  String get settingsDiagnosticReport;

  /// No description provided for @settingsDiagnosticReportSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Błędy i liczniki techniczne, bez danych logowania'**
  String get settingsDiagnosticReportSubtitle;

  /// No description provided for @diagnosticReportTitle.
  ///
  /// In pl, this message translates to:
  /// **'Raport diagnostyczny'**
  String get diagnosticReportTitle;

  /// No description provided for @diagnosticReportIntro.
  ///
  /// In pl, this message translates to:
  /// **'Raport to plik JSON, który sam wysyłasz wybraną aplikacją. Nic nie jest wysyłane automatycznie.'**
  String get diagnosticReportIntro;

  /// No description provided for @diagnosticReportContains.
  ///
  /// In pl, this message translates to:
  /// **'Zawiera wersję aplikacji i systemu, język, liczniki (przyczyny wylogowań, błędy połączenia i odpowiedzi GI Home, czas uruchamiania) oraz ostatnie błędy aplikacji.'**
  String get diagnosticReportContains;

  /// No description provided for @diagnosticReportExcludes.
  ///
  /// In pl, this message translates to:
  /// **'Hasła, tokeny, ciasteczka, adresy e-mail, kody odzyskiwania i adresy IP są usuwane przed zapisem. Raport nie zawiera danych z Twoich urządzeń.'**
  String get diagnosticReportExcludes;

  /// No description provided for @diagnosticReportShare.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get diagnosticReportShare;

  /// No description provided for @diagnosticReportSubject.
  ///
  /// In pl, this message translates to:
  /// **'Raport diagnostyczny GI Home'**
  String get diagnosticReportSubject;

  /// No description provided for @diagnosticReportFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się przygotować raportu. Spróbuj ponownie.'**
  String get diagnosticReportFailed;

  /// No description provided for @settingsAppSection.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja'**
  String get settingsAppSection;

  /// No description provided for @settingsAppVersion.
  ///
  /// In pl, this message translates to:
  /// **'Wersja aplikacji'**
  String get settingsAppVersion;

  /// No description provided for @settingsAppVersionValue.
  ///
  /// In pl, this message translates to:
  /// **'{version} ({build})'**
  String settingsAppVersionValue(String version, String build);

  /// No description provided for @roleOwner.
  ///
  /// In pl, this message translates to:
  /// **'Właściciel'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In pl, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleUser.
  ///
  /// In pl, this message translates to:
  /// **'Domownik'**
  String get roleUser;

  /// No description provided for @roleService.
  ///
  /// In pl, this message translates to:
  /// **'Serwis'**
  String get roleService;

  /// No description provided for @roleUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Nieznana rola'**
  String get roleUnknown;

  /// No description provided for @homeTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dom'**
  String get homeTitle;

  /// No description provided for @homeNoRoom.
  ///
  /// In pl, this message translates to:
  /// **'Bez pokoju'**
  String get homeNoRoom;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak urządzeń'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj urządzenia w panelu web GI Home, a pojawią się tutaj.'**
  String get homeEmptyBody;

  /// No description provided for @homeConditionGood.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko w porządku'**
  String get homeConditionGood;

  /// No description provided for @homeConditionNeedsAttention.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga uwagi'**
  String get homeConditionNeedsAttention;

  /// No description provided for @homeConditionActionRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga działania'**
  String get homeConditionActionRequired;

  /// No description provided for @homeConditionLimitedData.
  ///
  /// In pl, this message translates to:
  /// **'Ograniczone dane'**
  String get homeConditionLimitedData;

  /// No description provided for @homeDevicesSection.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenia'**
  String get homeDevicesSection;

  /// No description provided for @staleDataBanner.
  ///
  /// In pl, this message translates to:
  /// **'Dane mogą być nieaktualne (ostatnia aktualizacja {time})'**
  String staleDataBanner(String time);

  /// No description provided for @lastSeen.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnio widziane {time}'**
  String lastSeen(String time);

  /// No description provided for @lastSeenNever.
  ///
  /// In pl, this message translates to:
  /// **'Jeszcze nie połączone'**
  String get lastSeenNever;

  /// No description provided for @faultsCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =0{Brak usterek} one{1 usterka} few{{count} usterki} many{{count} usterek} other{{count} usterki}}'**
  String faultsCount(int count);

  /// No description provided for @badgeHeatingSuspended.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane'**
  String get badgeHeatingSuspended;

  /// No description provided for @badgeDryRun.
  ///
  /// In pl, this message translates to:
  /// **'Tryb testowy'**
  String get badgeDryRun;

  /// No description provided for @dryRunBanner.
  ///
  /// In pl, this message translates to:
  /// **'Tryb testowy: przekaźniki nie przełączają się fizycznie'**
  String get dryRunBanner;

  /// No description provided for @heatingSuspendedBanner.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie jest wstrzymane.'**
  String get heatingSuspendedBanner;

  /// No description provided for @connectivityLostLocalControl.
  ///
  /// In pl, this message translates to:
  /// **'Brak łączności – lokalne sterowanie działa nadal'**
  String get connectivityLostLocalControl;

  /// No description provided for @productStatusOnline.
  ///
  /// In pl, this message translates to:
  /// **'Działa'**
  String get productStatusOnline;

  /// No description provided for @productStatusOffline.
  ///
  /// In pl, this message translates to:
  /// **'Offline'**
  String get productStatusOffline;

  /// No description provided for @productStatusConnecting.
  ///
  /// In pl, this message translates to:
  /// **'Łączenie…'**
  String get productStatusConnecting;

  /// No description provided for @productStatusNeedsConfiguration.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga konfiguracji'**
  String get productStatusNeedsConfiguration;

  /// No description provided for @productStatusError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd'**
  String get productStatusError;

  /// No description provided for @productStatusUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany stan'**
  String get productStatusUnknown;

  /// No description provided for @connectivityOnline.
  ///
  /// In pl, this message translates to:
  /// **'Połączone'**
  String get connectivityOnline;

  /// No description provided for @connectivityStale.
  ///
  /// In pl, this message translates to:
  /// **'Brak świeżych danych'**
  String get connectivityStale;

  /// No description provided for @connectivityOffline.
  ///
  /// In pl, this message translates to:
  /// **'Brak łączności'**
  String get connectivityOffline;

  /// No description provided for @connectivityProvisioning.
  ///
  /// In pl, this message translates to:
  /// **'Konfigurowanie'**
  String get connectivityProvisioning;

  /// No description provided for @connectivityError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd połączenia'**
  String get connectivityError;

  /// No description provided for @connectivityUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany stan łączności'**
  String get connectivityUnknown;

  /// No description provided for @deviceDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły urządzenia'**
  String get deviceDetailsTitle;

  /// No description provided for @deviceNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie zostało usunięte lub zmienione.'**
  String get deviceNotFound;

  /// No description provided for @deviceEntitiesSection.
  ///
  /// In pl, this message translates to:
  /// **'Elementy'**
  String get deviceEntitiesSection;

  /// No description provided for @deviceEntitiesEmpty.
  ///
  /// In pl, this message translates to:
  /// **'To urządzenie nie ma jeszcze elementów.'**
  String get deviceEntitiesEmpty;

  /// No description provided for @deviceDiagnosticsSection.
  ///
  /// In pl, this message translates to:
  /// **'Diagnostyka'**
  String get deviceDiagnosticsSection;

  /// No description provided for @deviceControllerState.
  ///
  /// In pl, this message translates to:
  /// **'Stan sterownika'**
  String get deviceControllerState;

  /// No description provided for @deviceValueFromList.
  ///
  /// In pl, this message translates to:
  /// **'Z listy urządzeń · {time}'**
  String deviceValueFromList(String time);

  /// No description provided for @entityValueOn.
  ///
  /// In pl, this message translates to:
  /// **'Wł.'**
  String get entityValueOn;

  /// No description provided for @entityValueOff.
  ///
  /// In pl, this message translates to:
  /// **'Wył.'**
  String get entityValueOff;

  /// No description provided for @entityUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Niedostępny'**
  String get entityUnavailable;

  /// No description provided for @entityDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Wyłączony'**
  String get entityDisabled;

  /// No description provided for @entityDomainSensor.
  ///
  /// In pl, this message translates to:
  /// **'Czujnik'**
  String get entityDomainSensor;

  /// No description provided for @entityDomainSwitch.
  ///
  /// In pl, this message translates to:
  /// **'Przełącznik'**
  String get entityDomainSwitch;

  /// No description provided for @entityDomainBinarySensor.
  ///
  /// In pl, this message translates to:
  /// **'Czujnik dwustanowy'**
  String get entityDomainBinarySensor;

  /// No description provided for @entityDomainNumber.
  ///
  /// In pl, this message translates to:
  /// **'Wartość liczbowa'**
  String get entityDomainNumber;

  /// No description provided for @entityDomainSelect.
  ///
  /// In pl, this message translates to:
  /// **'Wybór'**
  String get entityDomainSelect;

  /// No description provided for @entityDomainClimate.
  ///
  /// In pl, this message translates to:
  /// **'Termostat'**
  String get entityDomainClimate;

  /// No description provided for @entityDomainTextSensor.
  ///
  /// In pl, this message translates to:
  /// **'Czujnik tekstowy'**
  String get entityDomainTextSensor;

  /// No description provided for @entityDomainButton.
  ///
  /// In pl, this message translates to:
  /// **'Przycisk'**
  String get entityDomainButton;

  /// No description provided for @entityDomainUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Inny element'**
  String get entityDomainUnknown;

  /// No description provided for @timeJustNow.
  ///
  /// In pl, this message translates to:
  /// **'przed chwilą'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In pl, this message translates to:
  /// **'{minutes} min temu'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In pl, this message translates to:
  /// **'{hours} godz. temu'**
  String timeHoursAgo(int hours);

  /// No description provided for @commonYes.
  ///
  /// In pl, this message translates to:
  /// **'Tak'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In pl, this message translates to:
  /// **'Nie'**
  String get commonNo;

  /// No description provided for @homeConditionGoodBody.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie urządzenia działają prawidłowo.'**
  String get homeConditionGoodBody;

  /// No description provided for @homeConditionUpdated.
  ///
  /// In pl, this message translates to:
  /// **'Aktualizacja: {time}'**
  String homeConditionUpdated(String time);

  /// No description provided for @homeLimitedRefreshFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się pobrać aktualnych danych.'**
  String get homeLimitedRefreshFailed;

  /// No description provided for @homeLimitedOutdated.
  ///
  /// In pl, this message translates to:
  /// **'Dane są starsze niż 2 minuty.'**
  String get homeLimitedOutdated;

  /// No description provided for @homeLimitedNoDevices.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie ma jeszcze włączonych urządzeń.'**
  String get homeLimitedNoDevices;

  /// No description provided for @homeAttentionSection.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga sprawdzenia'**
  String get homeAttentionSection;

  /// No description provided for @homeAttentionMore.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{i 1 inna sprawa} few{i {count} inne sprawy} many{i {count} innych spraw} other{i {count} innej sprawy}}'**
  String homeAttentionMore(int count);

  /// No description provided for @attentionFirmwareFault.
  ///
  /// In pl, this message translates to:
  /// **'Sterownik zgłasza awarię'**
  String get attentionFirmwareFault;

  /// No description provided for @attentionConnectivityError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd połączenia z urządzeniem'**
  String get attentionConnectivityError;

  /// No description provided for @attentionHeatingFaults.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{1 usterka ogrzewania} few{{count} usterki ogrzewania} many{{count} usterek ogrzewania} other{{count} usterki ogrzewania}}'**
  String attentionHeatingFaults(int count);

  /// No description provided for @attentionStale.
  ///
  /// In pl, this message translates to:
  /// **'Brak świeżych danych z urządzenia'**
  String get attentionStale;

  /// No description provided for @attentionNoData.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie nie przesłało jeszcze danych'**
  String get attentionNoData;

  /// No description provided for @homeHeatingDevice.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie grzewcze'**
  String get homeHeatingDevice;

  /// No description provided for @homeDeviceDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Wyłączone w panelu'**
  String get homeDeviceDisabled;

  /// No description provided for @offlineBannerSince.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z GI Home · dane z {time}'**
  String offlineBannerSince(String time);

  /// No description provided for @refreshFailedBanner.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odświeżyć · dane z {time}'**
  String refreshFailedBanner(String time);

  /// No description provided for @roomsUnavailableBanner.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się pobrać pokoi – urządzenia pokazujemy razem.'**
  String get roomsUnavailableBanner;

  /// No description provided for @deviceInfoSection.
  ///
  /// In pl, this message translates to:
  /// **'Informacje'**
  String get deviceInfoSection;

  /// No description provided for @deviceStatusSection.
  ///
  /// In pl, this message translates to:
  /// **'Stan'**
  String get deviceStatusSection;

  /// No description provided for @deviceConnectivity.
  ///
  /// In pl, this message translates to:
  /// **'Łączność'**
  String get deviceConnectivity;

  /// No description provided for @deviceProductStatus.
  ///
  /// In pl, this message translates to:
  /// **'Stan urządzenia'**
  String get deviceProductStatus;

  /// No description provided for @deviceManufacturer.
  ///
  /// In pl, this message translates to:
  /// **'Producent'**
  String get deviceManufacturer;

  /// No description provided for @deviceModel.
  ///
  /// In pl, this message translates to:
  /// **'Model'**
  String get deviceModel;

  /// No description provided for @deviceFirmware.
  ///
  /// In pl, this message translates to:
  /// **'Wersja oprogramowania'**
  String get deviceFirmware;

  /// No description provided for @deviceRoom.
  ///
  /// In pl, this message translates to:
  /// **'Pokój'**
  String get deviceRoom;

  /// No description provided for @deviceFaults.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne usterki'**
  String get deviceFaults;

  /// No description provided for @deviceNeedsAttention.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga uwagi – sprawdź urządzenie w panelu web.'**
  String get deviceNeedsAttention;

  /// No description provided for @deviceValueFromDiagnostics.
  ///
  /// In pl, this message translates to:
  /// **'Z diagnostyki urządzenia · {time}'**
  String deviceValueFromDiagnostics(String time);

  /// No description provided for @deviceFlagsSection.
  ///
  /// In pl, this message translates to:
  /// **'Tryby pracy'**
  String get deviceFlagsSection;

  /// No description provided for @deviceFlagHeatingSuspended.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane'**
  String get deviceFlagHeatingSuspended;

  /// No description provided for @deviceFlagDryRun.
  ///
  /// In pl, this message translates to:
  /// **'Tryb testowy (bez przełączania przekaźników)'**
  String get deviceFlagDryRun;

  /// No description provided for @deviceFlagPvBoost.
  ///
  /// In pl, this message translates to:
  /// **'Dogrzewanie z nadwyżki PV'**
  String get deviceFlagPvBoost;

  /// No description provided for @deviceDisabledBanner.
  ///
  /// In pl, this message translates to:
  /// **'To urządzenie jest wyłączone w panelu GI Home.'**
  String get deviceDisabledBanner;

  /// No description provided for @deviceDiagnosticsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie nie przesłało jeszcze diagnostyki.'**
  String get deviceDiagnosticsEmpty;

  /// No description provided for @deviceDiagUptime.
  ///
  /// In pl, this message translates to:
  /// **'Czas pracy od uruchomienia'**
  String get deviceDiagUptime;

  /// No description provided for @deviceDiagWifiRssi.
  ///
  /// In pl, this message translates to:
  /// **'Sygnał Wi-Fi'**
  String get deviceDiagWifiRssi;

  /// No description provided for @deviceDiagBootCount.
  ///
  /// In pl, this message translates to:
  /// **'Liczba uruchomień'**
  String get deviceDiagBootCount;

  /// No description provided for @deviceDiagRebootLoop.
  ///
  /// In pl, this message translates to:
  /// **'Wykryto pętlę restartów'**
  String get deviceDiagRebootLoop;

  /// No description provided for @deviceDiagSafetyInterlock.
  ///
  /// In pl, this message translates to:
  /// **'Blokada bezpieczeństwa aktywna'**
  String get deviceDiagSafetyInterlock;

  /// No description provided for @deviceDiagActiveFaults.
  ///
  /// In pl, this message translates to:
  /// **'Usterki w diagnostyce'**
  String get deviceDiagActiveFaults;

  /// No description provided for @signalDbm.
  ///
  /// In pl, this message translates to:
  /// **'{value} dBm'**
  String signalDbm(int value);

  /// No description provided for @durationDaysHours.
  ///
  /// In pl, this message translates to:
  /// **'{days} d {hours} godz.'**
  String durationDaysHours(int days, int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In pl, this message translates to:
  /// **'{hours} godz. {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @entityRoleHeatingRelay.
  ///
  /// In pl, this message translates to:
  /// **'Przekaźnik kotła'**
  String get entityRoleHeatingRelay;

  /// No description provided for @entityRolePumpRelay.
  ///
  /// In pl, this message translates to:
  /// **'Przekaźnik pompy'**
  String get entityRolePumpRelay;

  /// No description provided for @entityRoleControlTemperature.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura sterująca'**
  String get entityRoleControlTemperature;

  /// No description provided for @firmwareStateBoot.
  ///
  /// In pl, this message translates to:
  /// **'Uruchamianie'**
  String get firmwareStateBoot;

  /// No description provided for @firmwareStateSelfTest.
  ///
  /// In pl, this message translates to:
  /// **'Autotest'**
  String get firmwareStateSelfTest;

  /// No description provided for @firmwareStateReady.
  ///
  /// In pl, this message translates to:
  /// **'Gotowy'**
  String get firmwareStateReady;

  /// No description provided for @firmwareStateIdle.
  ///
  /// In pl, this message translates to:
  /// **'Czuwanie'**
  String get firmwareStateIdle;

  /// No description provided for @firmwareStateHeatingRequested.
  ///
  /// In pl, this message translates to:
  /// **'Żądanie grzania'**
  String get firmwareStateHeatingRequested;

  /// No description provided for @firmwareStateHeatingVerifying.
  ///
  /// In pl, this message translates to:
  /// **'Weryfikacja grzania'**
  String get firmwareStateHeatingVerifying;

  /// No description provided for @firmwareStateHeating.
  ///
  /// In pl, this message translates to:
  /// **'Grzanie'**
  String get firmwareStateHeating;

  /// No description provided for @firmwareStateStopping.
  ///
  /// In pl, this message translates to:
  /// **'Zatrzymywanie'**
  String get firmwareStateStopping;

  /// No description provided for @firmwareStateFault.
  ///
  /// In pl, this message translates to:
  /// **'Awaria'**
  String get firmwareStateFault;

  /// No description provided for @firmwareStateSafeMode.
  ///
  /// In pl, this message translates to:
  /// **'Tryb awaryjny'**
  String get firmwareStateSafeMode;

  /// No description provided for @firmwareStateUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany stan'**
  String get firmwareStateUnknown;

  /// No description provided for @heatingCardSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie grzewcze · {room}'**
  String heatingCardSubtitle(String room);

  /// No description provided for @heatingCardBoiler.
  ///
  /// In pl, this message translates to:
  /// **'Kocioł'**
  String get heatingCardBoiler;

  /// No description provided for @heatingCardBoilerOn.
  ///
  /// In pl, this message translates to:
  /// **'Grzeje'**
  String get heatingCardBoilerOn;

  /// No description provided for @heatingCardBoilerOff.
  ///
  /// In pl, this message translates to:
  /// **'Nie grzeje'**
  String get heatingCardBoilerOff;

  /// No description provided for @heatingCardPump.
  ///
  /// In pl, this message translates to:
  /// **'Pompa'**
  String get heatingCardPump;

  /// No description provided for @heatingCardPumpOn.
  ///
  /// In pl, this message translates to:
  /// **'Pracuje'**
  String get heatingCardPumpOn;

  /// No description provided for @heatingCardPumpOff.
  ///
  /// In pl, this message translates to:
  /// **'Zatrzymana'**
  String get heatingCardPumpOff;

  /// No description provided for @heatingCardRelayNote.
  ///
  /// In pl, this message translates to:
  /// **'Stan przekaźników według polecenia sterownika'**
  String get heatingCardRelayNote;

  /// No description provided for @heatingCardControllerUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Czekamy na dane ze sterownika'**
  String get heatingCardControllerUnknown;

  /// No description provided for @heatingCardLoading.
  ///
  /// In pl, this message translates to:
  /// **'Pobieranie szczegółów…'**
  String get heatingCardLoading;

  /// No description provided for @heatingCardDataFrom.
  ///
  /// In pl, this message translates to:
  /// **'Dane z {time}'**
  String heatingCardDataFrom(String time);

  /// No description provided for @heatingCardFailedSince.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się pobrać szczegółów · dane z {time}'**
  String heatingCardFailedSince(String time);

  /// No description provided for @heatingCardFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się pobrać szczegółów ogrzewania'**
  String get heatingCardFailed;

  /// No description provided for @attentionNeedsConfiguration.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga konfiguracji w panelu web GI Home'**
  String get attentionNeedsConfiguration;

  /// No description provided for @homeLimitedHeatingDetailsFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się pobrać szczegółów ogrzewania.'**
  String get homeLimitedHeatingDetailsFailed;

  /// No description provided for @experimentalTitle.
  ///
  /// In pl, this message translates to:
  /// **'Funkcje eksperymentalne'**
  String get experimentalTitle;

  /// No description provided for @experimentalIntro.
  ///
  /// In pl, this message translates to:
  /// **'Dla testerów. Zmienione flagi zostają na tym telefonie, dopóki nie przywrócisz wartości domyślnych.'**
  String get experimentalIntro;

  /// No description provided for @experimentalFlagsSection.
  ///
  /// In pl, this message translates to:
  /// **'Flagi funkcji'**
  String get experimentalFlagsSection;

  /// No description provided for @experimentalConfigSection.
  ///
  /// In pl, this message translates to:
  /// **'Konfiguracja'**
  String get experimentalConfigSection;

  /// No description provided for @experimentalFlavor.
  ///
  /// In pl, this message translates to:
  /// **'Wariant aplikacji'**
  String get experimentalFlavor;

  /// No description provided for @experimentalNoDefines.
  ///
  /// In pl, this message translates to:
  /// **'Zbudowano bez pliku konfiguracji: wszystkie flagi są domyślnie wyłączone.'**
  String get experimentalNoDefines;

  /// No description provided for @experimentalReset.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć domyślne'**
  String get experimentalReset;

  /// No description provided for @experimentalResetDone.
  ///
  /// In pl, this message translates to:
  /// **'Przywrócono domyślne wartości flag.'**
  String get experimentalResetDone;

  /// No description provided for @experimentalChanged.
  ///
  /// In pl, this message translates to:
  /// **'Zmieniono na tym telefonie'**
  String get experimentalChanged;

  /// No description provided for @experimentalDevOnly.
  ///
  /// In pl, this message translates to:
  /// **'Dostępne tylko w wariancie dev'**
  String get experimentalDevOnly;

  /// No description provided for @flagMockCoreTitle.
  ///
  /// In pl, this message translates to:
  /// **'Atrapa GI Core'**
  String get flagMockCoreTitle;

  /// No description provided for @flagMockCoreDescription.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja rozmawia z wbudowaną atrapą zamiast z GI Core w sieci. Przełączenie tworzy połączenie od nowa.'**
  String get flagMockCoreDescription;

  /// No description provided for @flagScheduleClockConversionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przeliczanie godzin harmonogramów'**
  String get flagScheduleClockConversionTitle;

  /// No description provided for @flagScheduleClockConversionDescription.
  ///
  /// In pl, this message translates to:
  /// **'Godziny harmonogramów można edytować w czasie domu; aplikacja przelicza je na zegar GI Core.'**
  String get flagScheduleClockConversionDescription;

  /// No description provided for @flagSwitchControlByIntegrationTitle.
  ///
  /// In pl, this message translates to:
  /// **'Sterowanie przełącznikami według integracji'**
  String get flagSwitchControlByIntegrationTitle;

  /// No description provided for @flagSwitchControlByIntegrationDescription.
  ///
  /// In pl, this message translates to:
  /// **'Przełącznikami można sterować zależnie od typu integracji urządzenia.'**
  String get flagSwitchControlByIntegrationDescription;

  /// No description provided for @flagAndroidLocalNetworkPermissionRequestTitle.
  ///
  /// In pl, this message translates to:
  /// **'Prośba o dostęp do sieci lokalnej (Android)'**
  String get flagAndroidLocalNetworkPermissionRequestTitle;

  /// No description provided for @flagAndroidLocalNetworkPermissionRequestDescription.
  ///
  /// In pl, this message translates to:
  /// **'Przed połączeniem aplikacja prosi o uprawnienie do urządzeń w pobliżu (ochrona sieci lokalnej).'**
  String get flagAndroidLocalNetworkPermissionRequestDescription;

  /// PermissionState: GI Core answered HTTP 403 for data the screen shows (plan §7.5).
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępu'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedBody.
  ///
  /// In pl, this message translates to:
  /// **'Twoja rola w GI Home nie pozwala oglądać tych danych. Jeśli to pomyłka, poproś właściciela lub administratora o zmianę roli.'**
  String get permissionDeniedBody;

  /// Screen-reader label of a FreshnessLabel; time is a relative time such as '2 min temu'.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano {time}'**
  String freshnessUpdated(String time);

  /// No description provided for @freshnessUpdatedStale.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano {time}, dane mogą być nieaktualne'**
  String freshnessUpdatedStale(String time);

  /// No description provided for @freshnessWaitingForReading.
  ///
  /// In pl, this message translates to:
  /// **'Czekamy na pierwszy odczyt'**
  String get freshnessWaitingForReading;

  /// No description provided for @schedulesOfflineBanner.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z GI Home. Widzisz ostatnio pobraną listę – możesz ją odświeżyć.'**
  String get schedulesOfflineBanner;

  /// No description provided for @schedulesRefreshFailedBanner.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odświeżyć harmonogramów. Widzisz ostatnio pobraną listę – możesz spróbować ponownie.'**
  String get schedulesRefreshFailedBanner;

  /// Non-blocking banner shown when GI Core keeps sending responses this app version cannot read (plan §16 point 4).
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizuj aplikację'**
  String get staleAppTitle;

  /// No description provided for @staleAppBody.
  ///
  /// In pl, this message translates to:
  /// **'Ta wersja aplikacji nie rozumie części odpowiedzi GI Home. Zainstaluj najnowszą wersję.'**
  String get staleAppBody;

  /// No description provided for @staleAppOpenStore.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz sklep'**
  String get staleAppOpenStore;

  /// No description provided for @staleAppDismiss.
  ///
  /// In pl, this message translates to:
  /// **'Ukryj komunikat'**
  String get staleAppDismiss;

  /// Shown instead of heating controls to USER/SERVICE roles (plan §12.8).
  ///
  /// In pl, this message translates to:
  /// **'Zmiany ogrzewania może wprowadzić właściciel.'**
  String get heatingViewOnlyHint;

  /// Amber banner while the device is in dry-run (plan §12.3).
  ///
  /// In pl, this message translates to:
  /// **'Tryb testowy: polecenia są zapisywane, ale przekaźniki pozostają wyłączone.'**
  String get heatingDryRunBanner;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Zmiany ogrzewania może wprowadzić właściciel lub administrator. Poproś go o zmianę.'**
  String get lockNotOwnerAdmin;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Przekaźnikiem kotła i pompy steruje sterownik. W aplikacji jest tylko podgląd.'**
  String get lockHeatingOrPumpRelay;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Tego elementu nie ma już w urządzeniu. Odśwież widok.'**
  String get lockEntityMissing;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Tego elementu nie da się przełączać z aplikacji.'**
  String get lockNotWritableSwitch;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Element jest wyłączony. Włącz go w panelu GI Home, aby nim sterować.'**
  String get lockEntityDisabled;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Element jest niedostępny. Sprawdź połączenie urządzenia i spróbuj ponownie.'**
  String get lockEntityUnavailable;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Dane są nieaktualne, więc sterowanie jest zablokowane. Poczekaj na odświeżenie. Wstrzymanie ogrzewania działa nadal.'**
  String get lockStaleData;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie jest wstrzymane. Wznów je, aby móc włączać przełączniki.'**
  String get lockSuspendedOnRequest;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Sterownik zgłasza usterkę lub tryb bezpieczny. Wymaga to autoryzowanego, ręcznego resetu na urządzeniu – w razie zagrożenia wezwij serwis.'**
  String get lockFaultLatched;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'GI Home wyłączy ogrzewanie. Możesz je później wznowić.'**
  String get consequenceStopsHeating;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Kocioł może się włączyć w ciągu ~30 s.'**
  String get consequenceBoilerMayStartSoon;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Wróci ustawienie domyślne lub aktywny harmonogram.'**
  String get consequenceRestoresBaseOrSchedule;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Polecenie zostanie wysłane, ale aplikacja nie potwierdza fizycznego przełączenia przekaźnika.'**
  String get consequenceCommandNotPhysicallyVerified;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Temperatura docelowa wzrośnie o ponad 10 °C.'**
  String get consequenceLargeTargetRaise;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'GI Home znów zacznie sterować kotłem i może go włączyć.'**
  String get consequenceLeavesOffMode;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Temperatura docelowa przekracza bezpieczne maksimum ustawione dla nadwyżki PV.'**
  String get consequenceAboveSafeMax;

  /// Heating SafetyPolicy/ConfirmationPolicy text (plan §12, PRD §8.6).
  ///
  /// In pl, this message translates to:
  /// **'Tryb testowy: polecenie zostanie zapisane, ale przekaźniki pozostaną wyłączone.'**
  String get consequenceDryRunOutputsStayOff;

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłanie…'**
  String get switchCommandSending;

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie potwierdziło polecenie: {state}, {time}. Fizyczny stan przekaźnika nie jest weryfikowany.'**
  String switchCommandLegacyConfirmed(String state, String time);

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Zlecono · czeka na raport sterownika'**
  String get switchCommandAwaitingHeartbeat;

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Po poleceniu sterownik zgłosił: polecenie {commanded}, wyjście {output} – to nie potwierdza fizycznego stanu przekaźnika.'**
  String switchCommandHeartbeatObserved(String commanded, String output);

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano w trybie testowym: polecenie {commanded}, wyjście pozostaje wyłączone.'**
  String switchCommandDryRunRecorded(String commanded);

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Sterownik nie zgłosił się w ciągu 45 s – stan jest nieznany. Odśwież widok przed kolejną próbą.'**
  String get switchCommandTimedOut;

  /// GI Edge switch value written by GI Core on enqueue, not yet reported by a heartbeat (plan §12.2). Never shows the requested state.
  ///
  /// In pl, this message translates to:
  /// **'czeka na raport sterownika'**
  String get entitySwitchAwaitingReport;

  /// Read-only commanded state of a boiler/pump relay from diagnostics.relayN.commanded (plan §12.4).
  ///
  /// In pl, this message translates to:
  /// **'Polecenie sterownika: {state}'**
  String switchControllerCommanded(String state);

  /// Dry-run hint from diagnostics.relayN.commanded (plan §12.3); the output does not switch.
  ///
  /// In pl, this message translates to:
  /// **'Sterownik chciałby: {state}'**
  String switchDryRunWouldSet(String state);

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'czeka na raport'**
  String get switchValueAwaitingReport;

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Wysłać polecenie włączenia: {name}?'**
  String switchConfirmOnTitle(String name);

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij polecenie'**
  String get switchConfirmSend;

  /// Switch command (plan §12.2). Never claims the relay physically switched.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież'**
  String get actionRefresh;

  /// Effective control strategy (controlStrategy, what the firmware gets), plan §12.5.
  ///
  /// In pl, this message translates to:
  /// **'Cel {temperature} °C, histereza {hysteresis} °C'**
  String heatingStrategyTarget(String temperature, String hysteresis);

  /// No description provided for @heatingStrategyModeAuto.
  ///
  /// In pl, this message translates to:
  /// **'GI Home steruje kotłem'**
  String get heatingStrategyModeAuto;

  /// No description provided for @heatingStrategyModeOff.
  ///
  /// In pl, this message translates to:
  /// **'Sterowanie wyłączone – GI Home nie będzie włączać kotła'**
  String get heatingStrategyModeOff;

  /// No description provided for @heatingStrategyModeManual.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie steruje automatycznie'**
  String get heatingStrategyModeManual;

  /// No description provided for @heatingStrategyModeUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany tryb sterowania'**
  String get heatingStrategyModeUnknown;

  /// Both controlStrategy and baseControlStrategy are null.
  ///
  /// In pl, this message translates to:
  /// **'Brak ustawień sterowania – skonfiguruj je w panelu web GI Home'**
  String get heatingStrategyNone;

  /// Effective target or hysteresis differs from the base one. The API does not say which schedule (plan §12.5 M2).
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram aktywny'**
  String get heatingScheduleActive;

  /// baseControlStrategy, shown next to the schedule-active hint.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienie domyślne: {temperature} °C, histereza {hysteresis} °C'**
  String heatingStrategyDefault(String temperature, String hysteresis);

  /// No description provided for @heatingSuspendedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane'**
  String get heatingSuspendedTitle;

  /// No description provided for @heatingSuspendedEffect.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie włączy kotła, dopóki ogrzewanie nie zostanie wznowione.'**
  String get heatingSuspendedEffect;

  /// Next action for OWNER/ADMIN when no resume action is wired.
  ///
  /// In pl, this message translates to:
  /// **'Aby wznowić ogrzewanie, otwórz szczegóły urządzenia.'**
  String get heatingSuspendedResumeHint;

  /// Next action for USER/SERVICE.
  ///
  /// In pl, this message translates to:
  /// **'Wznowić ogrzewanie może właściciel lub administrator.'**
  String get heatingSuspendedAskOwner;

  /// No description provided for @heatingResumeAction.
  ///
  /// In pl, this message translates to:
  /// **'Wznów ogrzewanie'**
  String get heatingResumeAction;

  /// pvBoostActive; the target is pvHeatingConfig.safeMaxTemperatureCelsius, not exposed directly.
  ///
  /// In pl, this message translates to:
  /// **'PV boost: grzanie do {temperature} °C'**
  String heatingPvBoost(String temperature);

  /// No description provided for @heatingPvBoostDerived.
  ///
  /// In pl, this message translates to:
  /// **'Cel wyliczony z limitu bezpieczeństwa PV'**
  String get heatingPvBoostDerived;

  /// pvBoostActive without pvHeatingConfig.
  ///
  /// In pl, this message translates to:
  /// **'PV boost aktywny – cel nieznany'**
  String get heatingPvBoostUnknownTarget;

  /// Source and freshness of the strategy values.
  ///
  /// In pl, this message translates to:
  /// **'Według GI Core · dane z {time}'**
  String heatingStrategySource(String time);

  /// No description provided for @heatingControlSection.
  ///
  /// In pl, this message translates to:
  /// **'Sterowanie ogrzewaniem'**
  String get heatingControlSection;

  /// No description provided for @strategyEditAction.
  ///
  /// In pl, this message translates to:
  /// **'Zmień ustawienia sterowania'**
  String get strategyEditAction;

  /// No description provided for @strategyEditorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia sterowania'**
  String get strategyEditorTitle;

  /// No description provided for @strategyEditorIntro.
  ///
  /// In pl, this message translates to:
  /// **'Zmieniasz ustawienie domyślne. Aktywny harmonogram może je czasowo zastąpić.'**
  String get strategyEditorIntro;

  /// No description provided for @strategyTargetLabel.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura docelowa (°C)'**
  String get strategyTargetLabel;

  /// No description provided for @strategyHysteresisLabel.
  ///
  /// In pl, this message translates to:
  /// **'Histereza (°C)'**
  String get strategyHysteresisLabel;

  /// No description provided for @strategyModeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tryb sterowania'**
  String get strategyModeLabel;

  /// No description provided for @strategyModeAutoShort.
  ///
  /// In pl, this message translates to:
  /// **'Auto'**
  String get strategyModeAutoShort;

  /// No description provided for @strategyModeOffShort.
  ///
  /// In pl, this message translates to:
  /// **'Wył.'**
  String get strategyModeOffShort;

  /// No description provided for @strategyModeManualShort.
  ///
  /// In pl, this message translates to:
  /// **'Ręczny'**
  String get strategyModeManualShort;

  /// No description provided for @strategyErrorNotANumber.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz liczbę'**
  String get strategyErrorNotANumber;

  /// No description provided for @strategyErrorRange.
  ///
  /// In pl, this message translates to:
  /// **'Dozwolony zakres: {min}–{max} °C'**
  String strategyErrorRange(String min, String max);

  /// No description provided for @strategyErrorStep.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wartość co {step} °C'**
  String strategyErrorStep(String step);

  /// No description provided for @strategyAboveSafeMaxWarning.
  ///
  /// In pl, this message translates to:
  /// **'To więcej niż bezpieczne maksimum dla nadwyżki PV ({temperature} °C).'**
  String strategyAboveSafeMaxWarning(String temperature);

  /// No description provided for @strategySuspendedNote.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie jest wstrzymane. Zapisane ustawienie zacznie obowiązywać po wznowieniu – do tego czasu tryb efektywny to Wył.'**
  String get strategySuspendedNote;

  /// No description provided for @strategySave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get strategySave;

  /// No description provided for @strategyChecking.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdzanie aktualnych ustawień…'**
  String get strategyChecking;

  /// No description provided for @strategySaving.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie…'**
  String get strategySaving;

  /// No description provided for @strategyConflictTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ktoś zmienił ustawienia w międzyczasie'**
  String get strategyConflictTitle;

  /// No description provided for @strategyConflictBody.
  ///
  /// In pl, this message translates to:
  /// **'Nic nie zostało zapisane. Sprawdź, co się zmieniło, i zdecyduj, co dalej.'**
  String get strategyConflictBody;

  /// No description provided for @strategyConflictRow.
  ///
  /// In pl, this message translates to:
  /// **'{field}: {before} → {after}'**
  String strategyConflictRow(String field, String before, String after);

  /// No description provided for @strategyFieldTarget.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura docelowa'**
  String get strategyFieldTarget;

  /// No description provided for @strategyFieldHysteresis.
  ///
  /// In pl, this message translates to:
  /// **'Histereza'**
  String get strategyFieldHysteresis;

  /// No description provided for @strategyFieldMode.
  ///
  /// In pl, this message translates to:
  /// **'Tryb'**
  String get strategyFieldMode;

  /// No description provided for @strategyFieldSuspended.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie'**
  String get strategyFieldSuspended;

  /// No description provided for @strategyValueNone.
  ///
  /// In pl, this message translates to:
  /// **'brak'**
  String get strategyValueNone;

  /// No description provided for @strategyValueSuspended.
  ///
  /// In pl, this message translates to:
  /// **'wstrzymane'**
  String get strategyValueSuspended;

  /// No description provided for @strategyValueActive.
  ///
  /// In pl, this message translates to:
  /// **'aktywne'**
  String get strategyValueActive;

  /// No description provided for @strategyConflictReapply.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz moje zmiany mimo to'**
  String get strategyConflictReapply;

  /// No description provided for @strategyConflictDiscard.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć moje zmiany'**
  String get strategyConflictDiscard;

  /// No description provided for @strategySavedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano w GI Core'**
  String get strategySavedTitle;

  /// No description provided for @strategySavedBase.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienie domyślne: {value}'**
  String strategySavedBase(String value);

  /// No description provided for @strategySavedEffective.
  ///
  /// In pl, this message translates to:
  /// **'Obowiązuje teraz: {value}'**
  String strategySavedEffective(String value);

  /// No description provided for @strategySavedSuspended.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie jest wstrzymane, więc tryb efektywny pozostaje Wył. do czasu wznowienia.'**
  String get strategySavedSuspended;

  /// No description provided for @strategyValue.
  ///
  /// In pl, this message translates to:
  /// **'{target} °C, histereza {hysteresis} °C, {mode}'**
  String strategyValue(String target, String hysteresis, String mode);

  /// No description provided for @strategyConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź zmianę ustawień'**
  String get strategyConfirmTitle;

  /// No description provided for @strategyConfirmSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get strategyConfirmSave;

  /// No description provided for @suspendHoldAction.
  ///
  /// In pl, this message translates to:
  /// **'Przytrzymaj, aby wstrzymać ogrzewanie'**
  String get suspendHoldAction;

  /// No description provided for @suspendHoldHint.
  ///
  /// In pl, this message translates to:
  /// **'Przytrzymaj przycisk – zwykłe dotknięcie niczego nie zmienia.'**
  String get suspendHoldHint;

  /// No description provided for @suspendA11yHint.
  ///
  /// In pl, this message translates to:
  /// **'otwiera potwierdzenie wstrzymania'**
  String get suspendA11yHint;

  /// No description provided for @suspendConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wstrzymać ogrzewanie?'**
  String get suspendConfirmTitle;

  /// No description provided for @suspendConfirmAction.
  ///
  /// In pl, this message translates to:
  /// **'Wstrzymaj ogrzewanie'**
  String get suspendConfirmAction;

  /// No description provided for @suspendAwaiting.
  ///
  /// In pl, this message translates to:
  /// **'Wysłano · czekamy, aż GI Core potwierdzi wstrzymanie'**
  String get suspendAwaiting;

  /// No description provided for @resumeAwaiting.
  ///
  /// In pl, this message translates to:
  /// **'Wysłano · czekamy, aż GI Core potwierdzi wznowienie'**
  String get resumeAwaiting;

  /// No description provided for @suspendAppliedAwaitingHeartbeat.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane. Zlecono wyłączenie przekaźników · czeka na raport sterownika'**
  String get suspendAppliedAwaitingHeartbeat;

  /// No description provided for @suspendAppliedOutputsOff.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane. Raport sterownika z {time}: wyjścia przekaźników wyłączone. To nie potwierdza fizycznego stanu przekaźników.'**
  String suspendAppliedOutputsOff(String time);

  /// No description provided for @suspendAppliedOutputOn.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane, ale raport sterownika z {time} wciąż pokazuje włączone wyjście. Odśwież za chwilę, a w razie zagrożenia wyłącz kocioł ręcznie.'**
  String suspendAppliedOutputOn(String time);

  /// No description provided for @suspendAppliedNotReported.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane. Zlecono wyłączenie przekaźników, ale sterownik nie raportuje stanu wyjść.'**
  String get suspendAppliedNotReported;

  /// No description provided for @suspendAppliedNoHeartbeat.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane. Zlecono wyłączenie przekaźników, ale sterownik nie zgłosił się w ciągu 45 s – stan przekaźników jest nieznany.'**
  String get suspendAppliedNoHeartbeat;

  /// No description provided for @suspendAppliedLegacy.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wstrzymane w GI Core. To urządzenie ESPHome nie dostaje poleceń wyłączenia przekaźników – GI Home po prostu nie będzie włączać kotła.'**
  String get suspendAppliedLegacy;

  /// No description provided for @resumeApplied.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wznowione. Znów obowiązuje ustawienie domyślne lub harmonogram.'**
  String get resumeApplied;

  /// No description provided for @resumeAppliedPending.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie wznowione. GI Core nie przywrócił jeszcze trybu sterowania – odśwież za chwilę.'**
  String get resumeAppliedPending;

  /// No description provided for @suspendTimedOut.
  ///
  /// In pl, this message translates to:
  /// **'GI Core nie potwierdził wstrzymania w ciągu 30 s. Odśwież widok i sprawdź stan.'**
  String get suspendTimedOut;

  /// No description provided for @resumeTimedOut.
  ///
  /// In pl, this message translates to:
  /// **'GI Core nie potwierdził wznowienia w ciągu 30 s. Odśwież widok i sprawdź stan.'**
  String get resumeTimedOut;

  /// No description provided for @resumeSheetTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wznowić ogrzewanie?'**
  String get resumeSheetTitle;

  /// No description provided for @resumeSheetWillApply.
  ///
  /// In pl, this message translates to:
  /// **'Zacznie obowiązywać: {value}'**
  String resumeSheetWillApply(String value);

  /// No description provided for @resumeSheetTemperature.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura sterująca: {value} · dane z {time}'**
  String resumeSheetTemperature(String value, String time);

  /// No description provided for @resumeSheetTemperatureMissing.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktualnego odczytu temperatury sterującej.'**
  String get resumeSheetTemperatureMissing;

  /// No description provided for @settingsLanguage.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageAutomatic.
  ///
  /// In pl, this message translates to:
  /// **'Automatycznie'**
  String get settingsLanguageAutomatic;

  /// No description provided for @settingsLanguageAutomaticSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Język z profilu GI Home, a bez niego język telefonu'**
  String get settingsLanguageAutomaticSubtitle;

  /// Language name in its own language; same in every locale.
  ///
  /// In pl, this message translates to:
  /// **'Polski'**
  String get settingsLanguagePolish;

  /// Language name in its own language; same in every locale.
  ///
  /// In pl, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'Język aplikacji'**
  String get settingsLanguageDialogTitle;

  /// No description provided for @settingsCoreVersion.
  ///
  /// In pl, this message translates to:
  /// **'Wersja oprogramowania GI Home'**
  String get settingsCoreVersion;

  /// Best-effort running GI Core version (plan §16).
  ///
  /// In pl, this message translates to:
  /// **'{version} (według ostatniego sprawdzenia aktualizacji)'**
  String settingsCoreVersionSubtitle(String version);

  /// No description provided for @settingsTimezone.
  ///
  /// In pl, this message translates to:
  /// **'Strefa czasowa urządzenia'**
  String get settingsTimezone;

  /// Shown from 3 days before the 30-day session ends (plan §7.6).
  ///
  /// In pl, this message translates to:
  /// **'{days, plural, =0{Sesja wygasła – zaloguj się ponownie} =1{Za 1 dzień trzeba będzie zalogować się ponownie} few{Za {days} dni trzeba będzie zalogować się ponownie} many{Za {days} dni trzeba będzie zalogować się ponownie} other{Za {days} dnia trzeba będzie zalogować się ponownie}}'**
  String settingsSessionRenewSoon(int days);

  /// Connect screen: heading of the demo mode entry (plan §19.5).
  ///
  /// In pl, this message translates to:
  /// **'Nie masz jeszcze GI Home?'**
  String get demoEntryTitle;

  /// Connect screen: what demo mode is.
  ///
  /// In pl, this message translates to:
  /// **'Zobacz aplikację na przykładowym domu. Dane są zmyślone i zostają w pamięci telefonu, a polecenia nie trafiają do żadnego urządzenia.'**
  String get demoEntryBody;

  /// Visible demo mode entry button on the connect screen (plan §19.5, Guideline 2.3.1).
  ///
  /// In pl, this message translates to:
  /// **'Wypróbuj wersję demonstracyjną'**
  String get demoEnter;

  /// Snackbar when the demo fixtures could not be loaded.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się uruchomić wersji demonstracyjnej. Spróbuj ponownie.'**
  String get demoStartFailed;

  /// Badge of the permanent demo banner.
  ///
  /// In pl, this message translates to:
  /// **'DEMO'**
  String get demoBadge;

  /// Screen reader label of the DEMO badge.
  ///
  /// In pl, this message translates to:
  /// **'Wersja demonstracyjna'**
  String get demoBadgeSemantics;

  /// Permanent demo banner text; never claims a device acted.
  ///
  /// In pl, this message translates to:
  /// **'Przykładowe dane – nic nie jest naprawdę sterowane.'**
  String get demoBannerMessage;

  /// Demo banner button: leaves demo mode and wipes its state.
  ///
  /// In pl, this message translates to:
  /// **'Zakończ demo'**
  String get demoExit;

  /// Title of the heating schedule list (plan §20 M3).
  ///
  /// In pl, this message translates to:
  /// **'Harmonogramy'**
  String get schedulesTitle;

  /// Device details: row that opens the schedule list.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogramy ogrzewania'**
  String get schedulesEntryTitle;

  /// Device details: subtitle of the schedule list row.
  ///
  /// In pl, this message translates to:
  /// **'Godziny i dni z inną temperaturą docelową'**
  String get schedulesEntrySubtitle;

  /// Schedule list without schedules.
  ///
  /// In pl, this message translates to:
  /// **'Brak harmonogramów'**
  String get schedulesEmptyTitle;

  /// Schedule list without schedules: what that means.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie przez cały czas działa według strategii bazowej.'**
  String get schedulesEmptyBody;

  /// Button that opens the editor for a new schedule.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj harmonogram'**
  String get schedulesAdd;

  /// Chip on the schedule that GI Core applies now (inferred on the phone).
  ///
  /// In pl, this message translates to:
  /// **'Aktywny teraz'**
  String get scheduleActiveNow;

  /// Chip on a disabled schedule.
  ///
  /// In pl, this message translates to:
  /// **'Wyłączony'**
  String get scheduleDisabledChip;

  /// Schedule whose start equals its end: the whole day.
  ///
  /// In pl, this message translates to:
  /// **'Cała doba'**
  String get scheduleWholeDay;

  /// Time window of a schedule, e.g. 06:00–08:00.
  ///
  /// In pl, this message translates to:
  /// **'{start}–{end}'**
  String scheduleTimeRange(String start, String end);

  /// Time window that ends after midnight.
  ///
  /// In pl, this message translates to:
  /// **'{start}–{end} (następnego dnia)'**
  String scheduleTimeRangeNextDay(String start, String end);

  /// Target and hysteresis of a schedule.
  ///
  /// In pl, this message translates to:
  /// **'{target} °C, histereza {hysteresis} °C'**
  String scheduleTargetLine(String target, String hysteresis);

  /// Schedule clock label without any other zone.
  ///
  /// In pl, this message translates to:
  /// **'Godziny według zegara GI Home (UTC).'**
  String get scheduleClockCoreOnly;

  /// Schedule clock label with the home time today (plan §13.4).
  ///
  /// In pl, this message translates to:
  /// **'Godziny według zegara GI Home (UTC). Dziś {core} UTC to {local} czasu domu.'**
  String scheduleClockDualHome(String core, String local);

  /// Schedule clock label with the phone time today, for roles that cannot read the home zone.
  ///
  /// In pl, this message translates to:
  /// **'Godziny według zegara GI Home (UTC). Dziś {core} UTC to {local} na tym telefonie.'**
  String scheduleClockDualPhone(String core, String local);

  /// Schedule clock label when editing in home time (feature flag, D8).
  ///
  /// In pl, this message translates to:
  /// **'Godziny w czasie domu ({zone}). Przeliczamy je na zegar GI Home (UTC) z dzisiejszym przesunięciem.'**
  String scheduleClockConverting(String zone);

  /// Banner before a DST change when editing in home time.
  ///
  /// In pl, this message translates to:
  /// **'Wkrótce zmiana czasu. Harmonogramy zostaną przy tej samej godzinie UTC, więc w czasie domu przesuną się o godzinę. Nic nie zmieniamy samodzielnie.'**
  String get scheduleDstAhead;

  /// Schedule list: how GI Core picks a schedule.
  ///
  /// In pl, this message translates to:
  /// **'Gdy okna się nakładają, obowiązuje harmonogram dodany wcześniej. Wstrzymanie ogrzewania ma pierwszeństwo przed harmonogramami.'**
  String get scheduleOrderHint;

  /// HEATING_SCHEDULE_NOT_FOUND after a change or delete.
  ///
  /// In pl, this message translates to:
  /// **'Tego harmonogramu już nie ma. Lista została odświeżona.'**
  String get scheduleGone;

  /// Snackbar after a schedule was created or changed.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram zapisany.'**
  String get scheduleSaved;

  /// Snackbar after a schedule was deleted.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram usunięty.'**
  String get scheduleDeleted;

  /// Editor opened for a schedule that is not in the list.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono harmonogramu.'**
  String get scheduleNotFound;

  /// Editor title for a new schedule.
  ///
  /// In pl, this message translates to:
  /// **'Nowy harmonogram'**
  String get scheduleEditorNewTitle;

  /// Editor title for an existing schedule.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj harmonogram'**
  String get scheduleEditorEditTitle;

  /// Editor field: schedule name.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get scheduleFieldName;

  /// Editor field: days of the week.
  ///
  /// In pl, this message translates to:
  /// **'Dni'**
  String get scheduleFieldDays;

  /// Editor field: start time.
  ///
  /// In pl, this message translates to:
  /// **'Od'**
  String get scheduleFieldStart;

  /// Editor field: end time.
  ///
  /// In pl, this message translates to:
  /// **'Do'**
  String get scheduleFieldEnd;

  /// Editor field: target temperature.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura docelowa (°C)'**
  String get scheduleFieldTarget;

  /// Editor field: hysteresis.
  ///
  /// In pl, this message translates to:
  /// **'Histereza (°C)'**
  String get scheduleFieldHysteresis;

  /// Editor switch: schedule enabled.
  ///
  /// In pl, this message translates to:
  /// **'Włączony'**
  String get scheduleFieldEnabled;

  /// Editor validation: name.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę, najwyżej 120 znaków.'**
  String get scheduleErrorName;

  /// Editor validation: days.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz co najmniej jeden dzień.'**
  String get scheduleErrorDays;

  /// Editor validation: target temperature.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wartość od 0 do 100 °C.'**
  String get scheduleErrorTarget;

  /// Editor validation: hysteresis.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wartość od 1 do 20 °C.'**
  String get scheduleErrorHysteresis;

  /// Editor warning: start equals end.
  ///
  /// In pl, this message translates to:
  /// **'Początek i koniec są takie same, więc harmonogram obowiązuje przez całą dobę w wybrane dni.'**
  String get scheduleWarnWholeDay;

  /// Editor note: the window runs past midnight.
  ///
  /// In pl, this message translates to:
  /// **'Okno kończy się następnego dnia o {end}.'**
  String scheduleWarnWraps(String end);

  /// Editor warning: overlapping schedules (GI Core does not reject them).
  ///
  /// In pl, this message translates to:
  /// **'Nakłada się na: {names}. Obowiązuje harmonogram dodany wcześniej.'**
  String scheduleWarnOverlap(String names);

  /// Editor button: save the schedule.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get scheduleSave;

  /// Editor button: delete the schedule.
  ///
  /// In pl, this message translates to:
  /// **'Usuń harmonogram'**
  String get scheduleDelete;

  /// Delete confirmation title.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć harmonogram?'**
  String get scheduleDeleteConfirmTitle;

  /// Delete confirmation body.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram „{name}” zostanie usunięty. Jeśli był aktywny, ogrzewanie wróci do strategii bazowej.'**
  String scheduleDeleteConfirmBody(String name);

  /// Delete confirmation button.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get scheduleDeleteConfirm;

  /// Home: entry to the weather screen (plan §4.2).
  ///
  /// In pl, this message translates to:
  /// **'Pogoda i słońce'**
  String get weatherEntryTitle;

  /// Home: subtitle of the weather screen entry.
  ///
  /// In pl, this message translates to:
  /// **'Prognoza, wschód i zachód słońca, produkcja PV'**
  String get weatherEntrySubtitle;

  /// Weather screen title.
  ///
  /// In pl, this message translates to:
  /// **'Pogoda i słońce'**
  String get weatherTitle;

  /// Weather screen: title of the weather card (now, hours, days).
  ///
  /// In pl, this message translates to:
  /// **'Pogoda'**
  String get weatherSection;

  /// Weather screen: hourly forecast strip.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe godziny'**
  String get weatherHourlySection;

  /// Weather screen: daily forecast list.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe dni'**
  String get weatherDailySection;

  /// Weather 503: the appliance has no weather data (G3: no internet in the appliance).
  ///
  /// In pl, this message translates to:
  /// **'Brak danych pogodowych'**
  String get weatherNoDataTitle;

  /// Weather 503 explanation; distinct from 'GI Home unreachable' and 'device offline' (G3).
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie ma teraz dostępu do internetu albo jeszcze nie pobrał prognozy. Aplikacja działa – sprawdź połączenie urządzenia z internetem.'**
  String get weatherNoDataBody;

  /// Weather envelope stale:true; the detail line holds the server's lastError.
  ///
  /// In pl, this message translates to:
  /// **'Prognoza może być nieaktualna – GI Home nie mógł jej odświeżyć, bo nie ma dostępu do internetu.'**
  String get weatherStaleBanner;

  /// No description provided for @weatherHumidity.
  ///
  /// In pl, this message translates to:
  /// **'Wilgotność {value}%'**
  String weatherHumidity(String value);

  /// No description provided for @weatherWind.
  ///
  /// In pl, this message translates to:
  /// **'Wiatr {speed} m/s'**
  String weatherWind(String speed);

  /// No description provided for @weatherPressure.
  ///
  /// In pl, this message translates to:
  /// **'Ciśnienie {value} hPa'**
  String weatherPressure(String value);

  /// No description provided for @weatherPrecipitation.
  ///
  /// In pl, this message translates to:
  /// **'Opady {value} mm'**
  String weatherPrecipitation(String value);

  /// A weather temperature with its unit.
  ///
  /// In pl, this message translates to:
  /// **'{value} °C'**
  String weatherTemperature(String value);

  /// Screen reader label of one hour of the forecast strip.
  ///
  /// In pl, this message translates to:
  /// **'{time}: {temperature}, {condition}'**
  String weatherHourSemantics(
    String time,
    String temperature,
    String condition,
  );

  /// Screen reader label of one day of the forecast.
  ///
  /// In pl, this message translates to:
  /// **'{day}: od {min} do {max}, opady {precipitation} mm, {condition}'**
  String weatherDaySemantics(
    String day,
    String min,
    String max,
    String precipitation,
    String condition,
  );

  /// Weather hours (UTC from the API) are shown in the home time zone.
  ///
  /// In pl, this message translates to:
  /// **'Godziny w strefie czasowej domu ({zone})'**
  String weatherTimesHouseZone(String zone);

  /// Weather hours are shown in the phone's zone (the home zone is not readable for this role).
  ///
  /// In pl, this message translates to:
  /// **'Godziny w strefie czasowej telefonu'**
  String get weatherTimesPhoneZone;

  /// Daily weather rows are UTC days (plan §13.4).
  ///
  /// In pl, this message translates to:
  /// **'Doby liczone według czasu UTC'**
  String get weatherDaysUtc;

  /// Weather condition (met.no clearsky).
  ///
  /// In pl, this message translates to:
  /// **'Bezchmurnie'**
  String get weatherGlyphClearSky;

  /// Weather condition (met.no fair).
  ///
  /// In pl, this message translates to:
  /// **'Pogodnie'**
  String get weatherGlyphFair;

  /// Weather condition (met.no partlycloudy).
  ///
  /// In pl, this message translates to:
  /// **'Częściowe zachmurzenie'**
  String get weatherGlyphPartlyCloudy;

  /// Weather condition (met.no cloudy, partly cloudy at night).
  ///
  /// In pl, this message translates to:
  /// **'Pochmurno'**
  String get weatherGlyphCloudy;

  /// Weather condition (met.no fog).
  ///
  /// In pl, this message translates to:
  /// **'Mgła'**
  String get weatherGlyphFog;

  /// Weather condition (light rain, rain showers).
  ///
  /// In pl, this message translates to:
  /// **'Przelotny deszcz'**
  String get weatherGlyphShowers;

  /// Weather condition (rain, heavy showers).
  ///
  /// In pl, this message translates to:
  /// **'Deszcz'**
  String get weatherGlyphRain;

  /// Weather condition (anything with thunder).
  ///
  /// In pl, this message translates to:
  /// **'Burza'**
  String get weatherGlyphThunder;

  /// Weather condition (sleet, snow showers, light snow).
  ///
  /// In pl, this message translates to:
  /// **'Deszcz ze śniegiem lub przelotny śnieg'**
  String get weatherGlyphSleetOrSnowShowers;

  /// Weather condition (snow, heavy snow).
  ///
  /// In pl, this message translates to:
  /// **'Śnieg'**
  String get weatherGlyphSnow;

  /// Weather condition (clear or fair at night).
  ///
  /// In pl, this message translates to:
  /// **'Pogodna noc'**
  String get weatherGlyphClearNight;

  /// Weather condition the app does not know.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany stan pogody'**
  String get weatherGlyphUnknown;

  /// Weather screen: sun card.
  ///
  /// In pl, this message translates to:
  /// **'Słońce'**
  String get solarSection;

  /// Sun card: sunrise time.
  ///
  /// In pl, this message translates to:
  /// **'Wschód'**
  String get solarSunrise;

  /// Sun card: sunset time.
  ///
  /// In pl, this message translates to:
  /// **'Zachód'**
  String get solarSunset;

  /// Sun card: day length.
  ///
  /// In pl, this message translates to:
  /// **'Długość dnia'**
  String get solarDayLength;

  /// No description provided for @solarAboveHorizon.
  ///
  /// In pl, this message translates to:
  /// **'Słońce nad horyzontem ({elevation}°)'**
  String solarAboveHorizon(String elevation);

  /// Sun card: the sun is below the horizon.
  ///
  /// In pl, this message translates to:
  /// **'Słońce pod horyzontem'**
  String get solarBelowHorizon;

  /// Solar 400: the appliance has no house coordinates.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw lokalizację domu w panelu GI Home, aby zobaczyć wschód i zachód słońca.'**
  String get solarNotConfigured;

  /// Solar: no data right now.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych o słońcu.'**
  String get solarNoData;

  /// Weather screen: PV forecast card (hidden when PV is not configured).
  ///
  /// In pl, this message translates to:
  /// **'Prognoza produkcji PV'**
  String get pvForecastSection;

  /// No description provided for @pvForecastPeakPower.
  ///
  /// In pl, this message translates to:
  /// **'Moc instalacji {power} kWp'**
  String pvForecastPeakPower(String power);

  /// PV forecast: estimated production of one day.
  ///
  /// In pl, this message translates to:
  /// **'{energy} kWh'**
  String pvForecastDayEnergy(String energy);

  /// PV forecast: the day's highest hourly production and its house-local time.
  ///
  /// In pl, this message translates to:
  /// **'szczyt {power} kW o {time}'**
  String pvForecastDayPeak(String power, String time);

  /// PV forecast 500: the appliance could not get a forecast.
  ///
  /// In pl, this message translates to:
  /// **'Brak prognozy PV'**
  String get pvForecastNoDataTitle;

  /// PV forecast 500 explanation (G3: no internet in the appliance).
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie mógł pobrać prognozy produkcji – możliwe, że nie ma dostępu do internetu.'**
  String get pvForecastNoDataBody;

  /// PV times are house-local wall times, shown as they come (plan §13.4).
  ///
  /// In pl, this message translates to:
  /// **'Godziny w czasie lokalnym domu'**
  String get pvHouseTimeNote;

  /// Device details: the PV heating plan.
  ///
  /// In pl, this message translates to:
  /// **'Plan grzania PV'**
  String get pvPlanSection;

  /// PV heating plan mode DISABLED.
  ///
  /// In pl, this message translates to:
  /// **'Plan PV wyłączony'**
  String get pvPlanDisabled;

  /// PV heating plan mode DISABLED explanation.
  ///
  /// In pl, this message translates to:
  /// **'Ogrzewanie nie korzysta z prognozy produkcji PV.'**
  String get pvPlanDisabledBody;

  /// PV heating plan enabled but without hours (no forecast).
  ///
  /// In pl, this message translates to:
  /// **'Plan PV bez prognozy'**
  String get pvPlanNoHours;

  /// PV heating plan enabled but without hours.
  ///
  /// In pl, this message translates to:
  /// **'GI Home nie ma teraz prognozy produkcji, więc nie planuje dogrzewania z PV.'**
  String get pvPlanNoHoursBody;

  /// No description provided for @pvPlanMode.
  ///
  /// In pl, this message translates to:
  /// **'Tryb: {mode}'**
  String pvPlanMode(String mode);

  /// PV control mode FORECAST_ONLY.
  ///
  /// In pl, this message translates to:
  /// **'tylko prognoza'**
  String get pvModeForecastOnly;

  /// PV control mode LIVE_INVERTER_ONLY.
  ///
  /// In pl, this message translates to:
  /// **'tylko odczyt z falownika'**
  String get pvModeLiveInverterOnly;

  /// PV control mode HYBRID.
  ///
  /// In pl, this message translates to:
  /// **'hybrydowy (prognoza i falownik)'**
  String get pvModeHybrid;

  /// PV control mode the app does not know.
  ///
  /// In pl, this message translates to:
  /// **'nieznany'**
  String get pvModeUnknown;

  /// No description provided for @pvPlanBaseTarget.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura bazowa {temperature} °C'**
  String pvPlanBaseTarget(String temperature);

  /// No description provided for @pvPlanSafeMax.
  ///
  /// In pl, this message translates to:
  /// **'Bezpieczne maksimum {temperature} °C'**
  String pvPlanSafeMax(String temperature);

  /// A plan hour with a predicted boost (favourable forecast).
  ///
  /// In pl, this message translates to:
  /// **'Dogrzewanie do {temperature} °C'**
  String pvPlanBoost(String temperature);

  /// A plan hour without a boost; the predicted target.
  ///
  /// In pl, this message translates to:
  /// **'Bez dogrzewania, {temperature} °C'**
  String pvPlanNoBoost(String temperature);

  /// No description provided for @pvPlanProduction.
  ///
  /// In pl, this message translates to:
  /// **'{power} kW'**
  String pvPlanProduction(String power);

  /// Screen reader label of one plan hour.
  ///
  /// In pl, this message translates to:
  /// **'{time}: produkcja {production}, {state}'**
  String pvPlanHourSemantics(String time, String production, String state);

  /// No description provided for @pvPlanShowAll.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż wszystkie godziny ({count})'**
  String pvPlanShowAll(int count);

  /// Collapse the PV plan hours.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż mniej'**
  String get pvPlanShowLess;

  /// The PV heating plan request failed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać planu PV'**
  String get pvPlanLoadFailed;

  /// Entity history screen title.
  ///
  /// In pl, this message translates to:
  /// **'Historia'**
  String get historyTitle;

  /// Device details: opens the history of the control temperature (last 24 h).
  ///
  /// In pl, this message translates to:
  /// **'Co działo się w nocy?'**
  String get historyNightEntryTitle;

  /// Subtitle of the overnight history entry.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura sterująca z ostatniej doby'**
  String get historyNightEntrySubtitle;

  /// Screen reader hint of an entity row that opens its history.
  ///
  /// In pl, this message translates to:
  /// **'pokaż historię'**
  String get historyEntityHint;

  /// Label of the history time range selector.
  ///
  /// In pl, this message translates to:
  /// **'Zakres'**
  String get historyWindowLabel;

  /// History range: last hour.
  ///
  /// In pl, this message translates to:
  /// **'1 h'**
  String get historyWindowHour;

  /// History range: last 6 hours.
  ///
  /// In pl, this message translates to:
  /// **'6 h'**
  String get historyWindowSixHours;

  /// History range: last 24 hours.
  ///
  /// In pl, this message translates to:
  /// **'24 h'**
  String get historyWindowDay;

  /// History range: last 7 days.
  ///
  /// In pl, this message translates to:
  /// **'7 dni'**
  String get historyWindowWeek;

  /// History range in a sentence: last hour.
  ///
  /// In pl, this message translates to:
  /// **'ostatnia godzina'**
  String get historyWindowHourLong;

  /// History range in a sentence: last 6 hours.
  ///
  /// In pl, this message translates to:
  /// **'ostatnie 6 godzin'**
  String get historyWindowSixHoursLong;

  /// History range in a sentence: last 24 hours.
  ///
  /// In pl, this message translates to:
  /// **'ostatnia doba'**
  String get historyWindowDayLong;

  /// History range in a sentence: last 7 days.
  ///
  /// In pl, this message translates to:
  /// **'ostatnie 7 dni'**
  String get historyWindowWeekLong;

  /// Switches the history chart to an accessible table.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż jako tabelę'**
  String get historyShowTable;

  /// Switches the history table back to the chart.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż wykres'**
  String get historyShowChart;

  /// History without samples in the range.
  ///
  /// In pl, this message translates to:
  /// **'Brak zmian w tym okresie'**
  String get historyEmptyTitle;

  /// Why a history can be empty (samples are change events).
  ///
  /// In pl, this message translates to:
  /// **'GI Home zapisuje odczyt tylko wtedy, gdy jego wartość się zmienia. Jeśli była stała, historia jest pusta.'**
  String get historyEmptyBody;

  /// Banner: the history was truncated by the server limit.
  ///
  /// In pl, this message translates to:
  /// **'W tym okresie jest więcej zmian, niż aplikacja wczytuje naraz. Wykres pokazuje tylko ich część; wybierz krótszy zakres.'**
  String get historyTruncated;

  /// Text entities have no chart, only the table.
  ///
  /// In pl, this message translates to:
  /// **'To odczyt tekstowy, więc jego historia jest pokazana jako tabela.'**
  String get historyTextOnly;

  /// Screen reader label while the chart is being downsampled.
  ///
  /// In pl, this message translates to:
  /// **'Przygotowywanie wykresu'**
  String get historyChartLoading;

  /// History summary: minimum value.
  ///
  /// In pl, this message translates to:
  /// **'Najniżej'**
  String get historySummaryMin;

  /// History summary: maximum value.
  ///
  /// In pl, this message translates to:
  /// **'Najwyżej'**
  String get historySummaryMax;

  /// History summary: latest value.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnio'**
  String get historySummaryLast;

  /// History summary: number of recorded changes.
  ///
  /// In pl, this message translates to:
  /// **'Zmiany'**
  String get historySummaryChanges;

  /// Screen reader summary of a numeric history chart.
  ///
  /// In pl, this message translates to:
  /// **'Wykres: {name}, {range}. Najniżej {min}, najwyżej {max}, ostatnio {last} o {time}. Zapisanych zmian: {count}.'**
  String historyChartSemantics(
    String name,
    String range,
    String min,
    String max,
    String last,
    String time,
    int count,
  );

  /// Screen reader summary of an on/off history chart.
  ///
  /// In pl, this message translates to:
  /// **'Wykres: {name}, {range}. Ostatnio {last} o {time}. Zapisanych przełączeń: {count}.'**
  String historySwitchSemantics(
    String name,
    String range,
    String last,
    String time,
    int count,
  );

  /// History table column: time.
  ///
  /// In pl, this message translates to:
  /// **'Czas'**
  String get historyTableTime;

  /// History table column: value.
  ///
  /// In pl, this message translates to:
  /// **'Wartość'**
  String get historyTableValue;

  /// No description provided for @historyTableRowSemantics.
  ///
  /// In pl, this message translates to:
  /// **'{time}: {value}'**
  String historyTableRowSemantics(String time, String value);

  /// No description provided for @historyTablePage.
  ///
  /// In pl, this message translates to:
  /// **'Strona {page} z {pages}'**
  String historyTablePage(int page, int pages);

  /// History table: previous page (newer samples).
  ///
  /// In pl, this message translates to:
  /// **'Nowsze'**
  String get historyTableNewer;

  /// History table: next page (older samples).
  ///
  /// In pl, this message translates to:
  /// **'Starsze'**
  String get historyTableOlder;

  /// HISTORY_RANGE_INVALID: the from/to range was rejected.
  ///
  /// In pl, this message translates to:
  /// **'GI Home odrzucił ten zakres czasu. Sprawdź datę i godzinę w telefonie.'**
  String get errorHistoryRangeInvalid;

  /// No description provided for @navAttention.
  ///
  /// In pl, this message translates to:
  /// **'Uwaga'**
  String get navAttention;

  /// No description provided for @attentionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Uwaga'**
  String get attentionTitle;

  /// No description provided for @attentionBadgeSemantics.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{1 sprawa wymaga uwagi} few{{count} sprawy wymagają uwagi} many{{count} spraw wymaga uwagi} other{{count} sprawy wymaga uwagi}}'**
  String attentionBadgeSemantics(int count);

  /// No description provided for @attentionEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nic nie wymaga uwagi'**
  String get attentionEmptyTitle;

  /// No description provided for @attentionEmptyBody.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenia działają i mają kontakt z GI Home.'**
  String get attentionEmptyBody;

  /// No description provided for @attentionSectionCritical.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczne'**
  String get attentionSectionCritical;

  /// No description provided for @attentionSectionImportant.
  ///
  /// In pl, this message translates to:
  /// **'Ważne'**
  String get attentionSectionImportant;

  /// No description provided for @attentionSectionNotice.
  ///
  /// In pl, this message translates to:
  /// **'Do sprawdzenia'**
  String get attentionSectionNotice;

  /// No description provided for @attentionSectionResolved.
  ///
  /// In pl, this message translates to:
  /// **'Rozwiązane w ciągu 24 h'**
  String get attentionSectionResolved;

  /// No description provided for @attentionAccountTitle.
  ///
  /// In pl, this message translates to:
  /// **'Twoje konto'**
  String get attentionAccountTitle;

  /// No description provided for @attentionMustChangePassword.
  ///
  /// In pl, this message translates to:
  /// **'Wymagana zmiana hasła'**
  String get attentionMustChangePassword;

  /// No description provided for @attentionResolvedAt.
  ///
  /// In pl, this message translates to:
  /// **'{what} · rozwiązane o {time}'**
  String attentionResolvedAt(String what, String time);

  /// No description provided for @offlineSnapshotReadOnly.
  ///
  /// In pl, this message translates to:
  /// **'Tylko do odczytu: stan urządzeń z ostatniego połączenia.'**
  String get offlineSnapshotReadOnly;

  /// No description provided for @flagConditionalGetTitle.
  ///
  /// In pl, this message translates to:
  /// **'Warunkowe pobieranie urządzeń (ETag)'**
  String get flagConditionalGetTitle;

  /// No description provided for @flagConditionalGetDescription.
  ///
  /// In pl, this message translates to:
  /// **'Lista i szczegóły urządzeń są pobierane z nagłówkiem If-None-Match; odpowiedź 304 oszczędza transfer. Zmiana działa od następnej sesji.'**
  String get flagConditionalGetDescription;

  /// No description provided for @flagMdnsFallbackTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukiwanie urządzenia przez multicast DNS'**
  String get flagMdnsFallbackTitle;

  /// No description provided for @flagMdnsFallbackDescription.
  ///
  /// In pl, this message translates to:
  /// **'Tylko Android. Gdy system nie rozpoznaje nazwy .local, aplikacja pyta o nią bezpośrednio sieć lokalną. Zmiana działa przy następnym wyszukiwaniu.'**
  String get flagMdnsFallbackDescription;

  /// No description provided for @settingsAccountManage.
  ///
  /// In pl, this message translates to:
  /// **'Profil i bezpieczeństwo'**
  String get settingsAccountManage;

  /// No description provided for @accountTitle.
  ///
  /// In pl, this message translates to:
  /// **'Profil i bezpieczeństwo'**
  String get accountTitle;

  /// No description provided for @accountProfileSection.
  ///
  /// In pl, this message translates to:
  /// **'Profil'**
  String get accountProfileSection;

  /// No description provided for @accountFirstNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Imię'**
  String get accountFirstNameLabel;

  /// No description provided for @accountLastNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwisko (opcjonalnie)'**
  String get accountLastNameLabel;

  /// No description provided for @accountFirstNameRequired.
  ///
  /// In pl, this message translates to:
  /// **'Podaj imię.'**
  String get accountFirstNameRequired;

  /// No description provided for @accountNameTooLong.
  ///
  /// In pl, this message translates to:
  /// **'Maksymalnie 100 znaków.'**
  String get accountNameTooLong;

  /// No description provided for @accountSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get accountSave;

  /// No description provided for @accountSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano profil.'**
  String get accountSaved;

  /// No description provided for @accountLanguageSection.
  ///
  /// In pl, this message translates to:
  /// **'Język konta'**
  String get accountLanguageSection;

  /// No description provided for @accountLanguageHint.
  ///
  /// In pl, this message translates to:
  /// **'Po zalogowaniu aplikacja i panel WWW używają tego języka, chyba że w ustawieniach aplikacji wybrano inny.'**
  String get accountLanguageHint;

  /// No description provided for @accountLanguagePolish.
  ///
  /// In pl, this message translates to:
  /// **'Polski'**
  String get accountLanguagePolish;

  /// No description provided for @accountLanguageEnglish.
  ///
  /// In pl, this message translates to:
  /// **'English'**
  String get accountLanguageEnglish;

  /// No description provided for @accountLanguageSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zmieniono język konta.'**
  String get accountLanguageSaved;

  /// No description provided for @accountSecuritySection.
  ///
  /// In pl, this message translates to:
  /// **'Bezpieczeństwo'**
  String get accountSecuritySection;

  /// No description provided for @accountChangePassword.
  ///
  /// In pl, this message translates to:
  /// **'Zmień hasło'**
  String get accountChangePassword;

  /// No description provided for @accountChangePasswordSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Inne urządzenia zostaną wylogowane'**
  String get accountChangePasswordSubtitle;

  /// No description provided for @accountSessions.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne sesje'**
  String get accountSessions;

  /// No description provided for @accountSessionsSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenia zalogowane na Twoje konto'**
  String get accountSessionsSubtitle;

  /// No description provided for @accountRecoveryCode.
  ///
  /// In pl, this message translates to:
  /// **'Kod odzyskiwania'**
  String get accountRecoveryCode;

  /// No description provided for @accountRecoveryCodeSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Pozwala ustawić nowe hasło, gdy zapomnisz obecnego'**
  String get accountRecoveryCodeSubtitle;

  /// No description provided for @changePasswordVoluntaryIntro.
  ///
  /// In pl, this message translates to:
  /// **'Po zmianie hasła inne urządzenia zostaną wylogowane. Ten telefon pozostanie zalogowany.'**
  String get changePasswordVoluntaryIntro;

  /// No description provided for @changePasswordVoluntarySubmit.
  ///
  /// In pl, this message translates to:
  /// **'Zmień hasło'**
  String get changePasswordVoluntarySubmit;

  /// No description provided for @sessionsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne sesje'**
  String get sessionsTitle;

  /// No description provided for @sessionsThisPhone.
  ///
  /// In pl, this message translates to:
  /// **'Ten telefon'**
  String get sessionsThisPhone;

  /// No description provided for @sessionsUnknownDevice.
  ///
  /// In pl, this message translates to:
  /// **'Nieznane urządzenie'**
  String get sessionsUnknownDevice;

  /// No description provided for @sessionsSignedIn.
  ///
  /// In pl, this message translates to:
  /// **'Zalogowano {date}'**
  String sessionsSignedIn(DateTime date);

  /// No description provided for @sessionsLastUsed.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnio aktywna {date}'**
  String sessionsLastUsed(DateTime date);

  /// No description provided for @sessionsIpAddress.
  ///
  /// In pl, this message translates to:
  /// **'Adres IP: {ip}'**
  String sessionsIpAddress(String ip);

  /// No description provided for @sessionsRevokeTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj tę sesję'**
  String get sessionsRevokeTooltip;

  /// No description provided for @sessionsRevokeTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wylogować to urządzenie?'**
  String get sessionsRevokeTitle;

  /// No description provided for @sessionsRevokeBody.
  ///
  /// In pl, this message translates to:
  /// **'Urządzenie będzie musiało zalogować się ponownie.'**
  String get sessionsRevokeBody;

  /// No description provided for @sessionsRevokeCurrentTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wylogować ten telefon?'**
  String get sessionsRevokeCurrentTitle;

  /// No description provided for @sessionsRevokeCurrentBody.
  ///
  /// In pl, this message translates to:
  /// **'Sesja tego telefonu zostanie zakończona i wrócisz do ekranu logowania.'**
  String get sessionsRevokeCurrentBody;

  /// No description provided for @sessionsRevokeConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj'**
  String get sessionsRevokeConfirm;

  /// No description provided for @sessionsRevoked.
  ///
  /// In pl, this message translates to:
  /// **'Sesja została zakończona.'**
  String get sessionsRevoked;

  /// No description provided for @sessionsLogoutAll.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj wszystkie urządzenia'**
  String get sessionsLogoutAll;

  /// No description provided for @sessionsLogoutAllTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wylogować wszystkie urządzenia?'**
  String get sessionsLogoutAllTitle;

  /// No description provided for @sessionsLogoutAllBody.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie sesje, również na tym telefonie, zostaną zakończone.'**
  String get sessionsLogoutAllBody;

  /// No description provided for @sessionsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnych sesji.'**
  String get sessionsEmpty;

  /// No description provided for @sessionsReviewPrompt.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{Na Twoim koncie jest jeszcze 1 aktywna sesja.} few{Na Twoim koncie są jeszcze {count} aktywne sesje.} many{Na Twoim koncie jest jeszcze {count} aktywnych sesji.} other{Na Twoim koncie jest jeszcze {count} aktywnej sesji.}}'**
  String sessionsReviewPrompt(int count);

  /// No description provided for @sessionsReviewAction.
  ///
  /// In pl, this message translates to:
  /// **'Przejrzyj'**
  String get sessionsReviewAction;

  /// No description provided for @recoveryCodeTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kod odzyskiwania'**
  String get recoveryCodeTitle;

  /// No description provided for @recoveryCodeIntro.
  ///
  /// In pl, this message translates to:
  /// **'Kod odzyskiwania pozwala ustawić nowe hasło na ekranie logowania, gdy zapomnisz obecnego. Nowy kod unieważnia poprzedni.'**
  String get recoveryCodeIntro;

  /// No description provided for @recoveryCodeGenerate.
  ///
  /// In pl, this message translates to:
  /// **'Wygeneruj nowy kod'**
  String get recoveryCodeGenerate;

  /// No description provided for @recoveryCodeConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wygenerować nowy kod?'**
  String get recoveryCodeConfirmTitle;

  /// No description provided for @recoveryCodeConfirmBody.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni kod przestanie działać. Nowy kod zobaczysz tylko raz.'**
  String get recoveryCodeConfirmBody;

  /// No description provided for @recoveryCodeConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Wygeneruj'**
  String get recoveryCodeConfirm;

  /// No description provided for @recoveryCodeShownOnce.
  ///
  /// In pl, this message translates to:
  /// **'Ten kod jest pokazywany tylko raz. Zapisz go w bezpiecznym miejscu, np. w menedżerze haseł.'**
  String get recoveryCodeShownOnce;

  /// No description provided for @recoveryCodeCopy.
  ///
  /// In pl, this message translates to:
  /// **'Kopiuj kod'**
  String get recoveryCodeCopy;

  /// No description provided for @recoveryCodeCopied.
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano. Schowek zostanie wyczyszczony za minutę.'**
  String get recoveryCodeCopied;

  /// No description provided for @recoveryCodeHidden.
  ///
  /// In pl, this message translates to:
  /// **'Kod jest ukryty, gdy ekran jest nagrywany lub aplikacja działa w tle.'**
  String get recoveryCodeHidden;

  /// No description provided for @recoveryCodeAcknowledge.
  ///
  /// In pl, this message translates to:
  /// **'Zapisałem kod w bezpiecznym miejscu'**
  String get recoveryCodeAcknowledge;

  /// No description provided for @recoveryCodeDone.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get recoveryCodeDone;

  /// No description provided for @recoveryCodeLeaveBlocked.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw potwierdź, że kod został zapisany.'**
  String get recoveryCodeLeaveBlocked;

  /// No description provided for @recoveryRotatePromptTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wygeneruj nowy kod odzyskiwania'**
  String get recoveryRotatePromptTitle;

  /// No description provided for @recoveryRotatePromptBody.
  ///
  /// In pl, this message translates to:
  /// **'Hasło zostało ustawione kodem odzyskiwania, który nadal działa. Wygeneruj nowy kod, aby poprzedni przestał działać.'**
  String get recoveryRotatePromptBody;

  /// No description provided for @recoveryRotatePromptLater.
  ///
  /// In pl, this message translates to:
  /// **'Później'**
  String get recoveryRotatePromptLater;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pl, this message translates to:
  /// **'Nie pamiętasz hasła?'**
  String get loginForgotPassword;

  /// No description provided for @recoveryResetTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odzyskiwanie hasła'**
  String get recoveryResetTitle;

  /// Replaces the recovery reset form while the screen is recorded or the app is in the background.
  ///
  /// In pl, this message translates to:
  /// **'Formularz jest ukryty, gdy ekran jest nagrywany lub aplikacja działa w tle.'**
  String get recoveryResetHidden;

  /// No description provided for @recoveryResetIntro.
  ///
  /// In pl, this message translates to:
  /// **'Podaj e-mail konta, kod odzyskiwania i nowe hasło. Po zmianie wszystkie urządzenia zostaną wylogowane.'**
  String get recoveryResetIntro;

  /// No description provided for @recoveryResetCodeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kod odzyskiwania'**
  String get recoveryResetCodeLabel;

  /// No description provided for @recoveryResetCodeHelper.
  ///
  /// In pl, this message translates to:
  /// **'8 grup po 4 znaki oddzielonych myślnikami, np. 1A2B-3C4D-…'**
  String get recoveryResetCodeHelper;

  /// No description provided for @recoveryResetCodeRequired.
  ///
  /// In pl, this message translates to:
  /// **'Podaj kod odzyskiwania.'**
  String get recoveryResetCodeRequired;

  /// No description provided for @recoveryResetCodeMalformed.
  ///
  /// In pl, this message translates to:
  /// **'Kod ma postać 8 grup po 4 znaki (0–9, A–F) oddzielonych myślnikami.'**
  String get recoveryResetCodeMalformed;

  /// No description provided for @recoveryResetSubmit.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw nowe hasło'**
  String get recoveryResetSubmit;

  /// No description provided for @recoveryResetInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się ustawić hasła. Sprawdź e-mail i kod odzyskiwania.'**
  String get recoveryResetInvalid;

  /// No description provided for @recoveryResetRateLimited.
  ///
  /// In pl, this message translates to:
  /// **'Zbyt wiele prób. Spróbuj za kilka minut.'**
  String get recoveryResetRateLimited;

  /// No description provided for @recoveryResetDoneTitle.
  ///
  /// In pl, this message translates to:
  /// **'Hasło zostało zmienione'**
  String get recoveryResetDoneTitle;

  /// No description provided for @recoveryResetDoneBody.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się nowym hasłem. Po zalogowaniu wygeneruj nowy kod odzyskiwania, bo obecny nadal działa.'**
  String get recoveryResetDoneBody;

  /// No description provided for @recoveryResetGoToLogin.
  ///
  /// In pl, this message translates to:
  /// **'Przejdź do logowania'**
  String get recoveryResetGoToLogin;

  /// No description provided for @recoveryResetBack.
  ///
  /// In pl, this message translates to:
  /// **'Wróć do logowania'**
  String get recoveryResetBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
