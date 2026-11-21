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
  /// **'Sterownik: brak danych'**
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
