// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GI Home';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionChangeAppliance => 'Change appliance';

  @override
  String get actionOpenSettings => 'Open settings';

  @override
  String get actionFindAppliance => 'Find GI Home';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonNoData => 'No data';

  @override
  String get commonNoDataValue => '—';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get connectTitle => 'Connect to GI Home';

  @override
  String get connectIntro =>
      'Your phone must be on the same Wi-Fi as GI Home. Pick a found appliance or enter its address.';

  @override
  String get connectAddressLabel => 'GI Home address';

  @override
  String get connectAddressHint => 'e.g. gi-home.local or 192.168.1.20:3000';

  @override
  String get connectAddressRequired => 'Enter the GI Home address';

  @override
  String get connectSearchTitle => 'Find GI Home';

  @override
  String get connectSearching => 'Looking for GI Home…';

  @override
  String get connectSearchNoneFound =>
      'No GI Home found on this network. Enter its address below, preferably an IP address.';

  @override
  String get connectSearchAgain => 'Search again';

  @override
  String get connectCandidateCurrent => 'Current appliance';

  @override
  String get connectCandidateNotSetUp => 'Not set up';

  @override
  String get connectManualTitle => 'Or enter the address';

  @override
  String get connectHintsTitle => 'Hints';

  @override
  String get connectHintAndroidEmulator => 'Android emulator';

  @override
  String get connectHintIosSimulator => 'iOS simulator';

  @override
  String get connectHintAndroidUsb => 'Android over USB';

  @override
  String get connectHintLanPhone => 'Phone on the LAN';

  @override
  String get connectHintLanProxy => 'Via dev_lan_proxy';

  @override
  String get connectHintComputerIp => 'PC-IP';

  @override
  String connectHintUsbNote(String command) {
    return 'Android over USB: first run $command on the computer, then connect to localhost:3000.';
  }

  @override
  String get connectHintProxyNote =>
      'Via dev_lan_proxy: when GI Core stays on loopback, the forwarder on the computer passes port 8080 to 127.0.0.1:3000. Type the computer\'s IP before :8080.';

  @override
  String get connectHintLan =>
      'Phone on Wi-Fi: type the computer\'s LAN IP address before :3000. The backend must run with GI_CORE_BIND_ADDRESS=0.0.0.0 (dev-up -Lan) and port 3000 must be open in the firewall.';

  @override
  String get connectSubmit => 'Check';

  @override
  String get connectProbing => 'Checking the address…';

  @override
  String get connectConfirmTitle => 'Is this your GI Home?';

  @override
  String connectConfirmSubtitle(String deviceName, String host) {
    return '$deviceName · $host';
  }

  @override
  String get connectNotInitializedNote =>
      'This appliance has not been set up yet.';

  @override
  String get connectCleartextNote =>
      'The connection in your home network is not encrypted. Use it only on a trusted Wi-Fi network.';

  @override
  String get connectConfirmYes => 'Yes, connect';

  @override
  String get connectConfirmNo => 'No, enter another address';

  @override
  String get connectErrorInvalidAddress =>
      'This does not look like a valid address. Enter the GI Home name, IP address or URL.';

  @override
  String get connectErrorNotGiHome =>
      'Another device answers at this address, not GI Home.';

  @override
  String get errorUnreachable =>
      'Cannot connect to GI Home. Check that your phone is on the same Wi-Fi network.';

  @override
  String get errorTimeout =>
      'GI Home did not answer in time. Please try again.';

  @override
  String get errorTlsUntrusted =>
      'The server certificate is not trusted – use http:// in your home network or a certificate from a public CA.';

  @override
  String get errorLocalNetworkDenied =>
      'GI Home has no access to the local network. Allow it in your phone’s Settings.';

  @override
  String get errorInsecureTransport =>
      'Unencrypted connections (http://) are allowed only in your home network. Use https:// for other addresses.';

  @override
  String get errorForbidden => 'You do not have permission for this action.';

  @override
  String get errorNotFound => 'The item was removed or changed.';

  @override
  String get errorRouteAbsent =>
      'This feature is not available in this GI Home version.';

  @override
  String get errorValidation => 'Check the data you entered.';

  @override
  String get errorRateLimited => 'Too many attempts. Try again in a moment.';

  @override
  String get errorServer => 'GI Home reported an error. Please try again.';

  @override
  String get errorMaintenance =>
      'GI Home is briefly unavailable – it is starting up or under maintenance. Please try again in a few minutes.';

  @override
  String get errorUnexpectedResponse =>
      'GI Home returned an unexpected response. Check the appliance address.';

  @override
  String get errorUnexpectedShape =>
      'Could not read the GI Home response. The app may need an update.';

  @override
  String get errorUnauthorized =>
      'GI Home rejected the request. Please try again.';

  @override
  String get errorRefreshCookieMissing =>
      'GI Home did not send session data. Try logging in again.';

  @override
  String get errorVaultUnavailable =>
      'Cannot read your login data – please try again.';

  @override
  String get errorDifferentAppliance =>
      'A different GI Home answers at the saved address. Connect to the right appliance again.';

  @override
  String get errorApplianceReset =>
      'GI Home was reset. Finish setting it up, then log in again.';

  @override
  String get errorCancelled => 'The operation was cancelled.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorDeviceEntityNotFound =>
      'This item is no longer part of the device. Refresh the view.';

  @override
  String get errorDeviceNotFound =>
      'The device was removed or changed. Refresh the view.';

  @override
  String get errorHeatingSuspended =>
      'Heating is suspended, so nothing can be turned on. Resume heating first.';

  @override
  String get errorEntityDisabled =>
      'This item is disabled in the device configuration.';

  @override
  String get errorEntityNotWritable =>
      'This item cannot be controlled from the app.';

  @override
  String get errorDeviceOffline =>
      'The device is offline. The command was not sent.';

  @override
  String get errorDeviceUnreachable =>
      'GI Home does not know the controller\'s address. The command was not sent.';

  @override
  String get errorCommandUnconfirmed =>
      'The controller did not confirm the command. The state is unknown – refresh the view and check it before trying again.';

  @override
  String get errorCommandTimeout =>
      'The controller did not respond in time. It is not known whether the command was carried out – refresh the view before trying again.';

  @override
  String get errorDeviceHostForbidden =>
      'The controller\'s address is outside the home network, so GI Home blocked it. Check the device configuration in the GI Home web panel.';

  @override
  String errorRequestId(String requestId) {
    return 'Request ID: $requestId';
  }

  @override
  String get setupRequiredTitle => 'Finish the setup';

  @override
  String setupRequiredBody(String host) {
    return 'GI Home at $host has not been set up yet. Finish the setup in the GI Home web panel in your browser, then come back to the app.';
  }

  @override
  String get setupRequiredOpenPanel => 'Finish setup in the browser';

  @override
  String get setupRequiredOpenFailed => 'Could not open the browser.';

  @override
  String get setupRequiredCheckAgain => 'Check again';

  @override
  String get setupRequiredStillNotInitialized => 'GI Home is still not set up.';

  @override
  String setupRequiredDevHint(String command) {
    return 'Developer mode: the web panel does not run with the dev stack. Initialise the backend with $command.';
  }

  @override
  String get restoreConnecting => 'Connecting to GI Home…';

  @override
  String get restoreFailedTitle => 'Could not connect to GI Home';

  @override
  String get restoreVaultUnavailableTitle =>
      'Login data is temporarily unavailable';

  @override
  String get restoreVaultUnavailableHint =>
      'We will try again when you return to the app.';

  @override
  String get loginTitle => 'Log in';

  @override
  String loginSubtitle(String deviceName) {
    return 'to $deviceName';
  }

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailInvalid => 'Enter a valid email address.';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordRequired => 'Enter your password.';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get loginErrorUserDisabled =>
      'This account is disabled. Contact the owner of GI Home.';

  @override
  String get loginErrorRateLimited => 'Too many login attempts.';

  @override
  String loginRetryCountdown(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Try again in $seconds seconds.',
      one: 'Try again in 1 second.',
    );
    return '$_temp0';
  }

  @override
  String get sessionLostRevoked =>
      'Your session expired or was ended on another device (e.g. the limit of 10 logged-in devices).';

  @override
  String get sessionLostExpired =>
      'Your session expired after 30 days. Please log in again.';

  @override
  String get sessionLostUserDisabled => 'This account has been disabled.';

  @override
  String get sessionLostProtocol =>
      'Your session was interrupted. Please log in again.';

  @override
  String get sessionLostVaultWiped =>
      'Your saved login data could not be read and was removed. Please log in again.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordIntro =>
      'For security, set a new password before you start using the app.';

  @override
  String get changePasswordCurrentLabel => 'Current password';

  @override
  String get changePasswordNewLabel => 'New password';

  @override
  String get changePasswordRepeatLabel => 'Repeat new password';

  @override
  String get changePasswordRules =>
      '8 to 256 characters, including a lowercase letter, an uppercase letter and a digit.';

  @override
  String get changePasswordSubmit => 'Change password and continue';

  @override
  String get changePasswordCurrentInvalid =>
      'The current password is incorrect.';

  @override
  String get changePasswordSameAsCurrent =>
      'The new password must differ from the current one.';

  @override
  String changePasswordOtherSessionsEnded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Your password has been changed. $count other devices were logged out.',
      one: 'Your password has been changed. 1 other device was logged out.',
      zero: 'Your password has been changed.',
    );
    return '$_temp0';
  }

  @override
  String get passwordRequired => 'Enter a password.';

  @override
  String get passwordTooShort =>
      'The password must have at least 8 characters.';

  @override
  String get passwordTooLong => 'The password can have at most 256 characters.';

  @override
  String get passwordNeedsLowercase =>
      'The password must contain a lowercase letter.';

  @override
  String get passwordNeedsUppercase =>
      'The password must contain an uppercase letter.';

  @override
  String get passwordNeedsDigit => 'The password must contain a digit.';

  @override
  String get passwordMismatch => 'The passwords do not match.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsApplianceSection => 'GI Home appliance';

  @override
  String get settingsApplianceName => 'Name';

  @override
  String get settingsApplianceAddress => 'Address';

  @override
  String get settingsCleartext =>
      'HTTP – unencrypted connection in the local network';

  @override
  String get settingsEncrypted => 'HTTPS – encrypted connection';

  @override
  String get settingsLanOnly => 'Access only in your home network';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsUserName => 'User';

  @override
  String get settingsUserEmail => 'Email';

  @override
  String get settingsUserRole => 'Role';

  @override
  String settingsSessionValidUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Session valid until $dateString';
  }

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutLocalOnly =>
      'Logged out on this phone. The session on the appliance expires within 30 days, or you can remove it in the GI Home web panel (Profile → Sessions).';

  @override
  String get settingsSwitchUser => 'Switch user';

  @override
  String get settingsSwitchUserSubtitle =>
      'Log out and sign in with another account';

  @override
  String get settingsSwitchUserConfirmTitle => 'Switch user?';

  @override
  String settingsSwitchUserConfirmBody(String email) {
    return '$email will be logged out and its data removed from this phone. You can then sign in with another account.';
  }

  @override
  String get settingsChangeAppliance => 'Change appliance';

  @override
  String get settingsChangeApplianceConfirmTitle => 'Change appliance?';

  @override
  String settingsChangeApplianceConfirmBody(String name) {
    return 'This logs you out and removes the data of GI Home “$name” from this phone.';
  }

  @override
  String settingsChangeApplianceConfirmBodyNoLogout(String name) {
    return 'The data of GI Home “$name” will be removed from this phone. Logging out on the appliance is not possible right now, so the session stays active there until it expires (at most 30 days).';
  }

  @override
  String get settingsLicenses => 'Open-source licences';

  @override
  String get settingsLicensesSubtitle => 'Libraries and fonts used in the app';

  @override
  String get settingsDiagnosticReport => 'Send diagnostic report';

  @override
  String get settingsDiagnosticReportSubtitle =>
      'Errors and technical counters, no sign-in data';

  @override
  String get diagnosticReportTitle => 'Diagnostic report';

  @override
  String get diagnosticReportIntro =>
      'The report is a JSON file that you send yourself with an app of your choice. Nothing is sent automatically.';

  @override
  String get diagnosticReportContains =>
      'It contains the app and system version, language, counters (reasons for being signed out, GI Home connection and response errors, start-up time) and the latest app errors.';

  @override
  String get diagnosticReportExcludes =>
      'Passwords, tokens, cookies, e-mail addresses, recovery codes and IP addresses are removed before saving. The report contains no data from your devices.';

  @override
  String get diagnosticReportShare => 'Share';

  @override
  String get diagnosticReportSubject => 'GI Home diagnostic report';

  @override
  String get diagnosticReportFailed =>
      'Could not prepare the report. Please try again.';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String settingsAppVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleUser => 'Household member';

  @override
  String get roleService => 'Service';

  @override
  String get roleUnknown => 'Unknown role';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeNoRoom => 'No room';

  @override
  String get homeEmptyTitle => 'No devices';

  @override
  String get homeEmptyBody =>
      'Add devices in the GI Home web panel and they will appear here.';

  @override
  String get homeConditionGood => 'All good';

  @override
  String get homeConditionNeedsAttention => 'Needs attention';

  @override
  String get homeConditionActionRequired => 'Action required';

  @override
  String get homeConditionLimitedData => 'Limited data';

  @override
  String get homeDevicesSection => 'Devices';

  @override
  String staleDataBanner(String time) {
    return 'Data may be out of date (last update $time)';
  }

  @override
  String lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String get lastSeenNever => 'Not connected yet';

  @override
  String faultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faults',
      one: '1 fault',
      zero: 'No faults',
    );
    return '$_temp0';
  }

  @override
  String get badgeHeatingSuspended => 'Heating suspended';

  @override
  String get badgeDryRun => 'Test mode';

  @override
  String get dryRunBanner => 'Test mode: relays do not switch physically';

  @override
  String get heatingSuspendedBanner => 'Heating is suspended.';

  @override
  String get connectivityLostLocalControl =>
      'No connection – local control keeps working';

  @override
  String get productStatusOnline => 'Working';

  @override
  String get productStatusOffline => 'Offline';

  @override
  String get productStatusConnecting => 'Connecting…';

  @override
  String get productStatusNeedsConfiguration => 'Needs configuration';

  @override
  String get productStatusError => 'Error';

  @override
  String get productStatusUnknown => 'Unknown state';

  @override
  String get connectivityOnline => 'Connected';

  @override
  String get connectivityStale => 'No recent data';

  @override
  String get connectivityOffline => 'No connection';

  @override
  String get connectivityProvisioning => 'Provisioning';

  @override
  String get connectivityError => 'Connection error';

  @override
  String get connectivityUnknown => 'Unknown connectivity';

  @override
  String get deviceDetailsTitle => 'Device details';

  @override
  String get deviceNotFound => 'The device was removed or changed.';

  @override
  String get deviceEntitiesSection => 'Elements';

  @override
  String get entityStaleValue => 'No recent data';

  @override
  String get deviceTechnicalEntitiesSection => 'Device technical data';

  @override
  String get deviceEntitiesEmpty => 'This device has no elements yet.';

  @override
  String get deviceDiagnosticsSection => 'Diagnostics';

  @override
  String get deviceControllerState => 'Controller state';

  @override
  String deviceValueFromList(String time) {
    return 'From the device list · $time';
  }

  @override
  String get entityValueOn => 'On';

  @override
  String get entityValueOff => 'Off';

  @override
  String get entityUnavailable => 'Unavailable';

  @override
  String get entityDisabled => 'Disabled';

  @override
  String get entityDomainSensor => 'Sensor';

  @override
  String get entityDomainSwitch => 'Switch';

  @override
  String get entityDomainBinarySensor => 'Binary sensor';

  @override
  String get entityDomainNumber => 'Number';

  @override
  String get entityDomainSelect => 'Selection';

  @override
  String get entityDomainClimate => 'Thermostat';

  @override
  String get entityDomainTextSensor => 'Text sensor';

  @override
  String get entityDomainButton => 'Button';

  @override
  String get entityDomainUnknown => 'Other element';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get homeConditionGoodBody => 'All devices are working properly.';

  @override
  String homeConditionUpdated(String time) {
    return 'Updated: $time';
  }

  @override
  String get homeLimitedRefreshFailed => 'Could not fetch current data.';

  @override
  String get homeLimitedOutdated => 'The data is older than 2 minutes.';

  @override
  String get homeLimitedNoDevices => 'GI Home has no enabled devices yet.';

  @override
  String get homeAttentionSection => 'Worth a look';

  @override
  String homeAttentionMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count more items',
      one: 'and 1 more item',
    );
    return '$_temp0';
  }

  @override
  String get attentionFirmwareFault => 'The controller reports a failure';

  @override
  String get attentionConnectivityError => 'Connection error with the device';

  @override
  String attentionHeatingFaults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heating faults',
      one: '1 heating fault',
    );
    return '$_temp0';
  }

  @override
  String get attentionStale => 'No recent data from the device';

  @override
  String get attentionNoData => 'The device has not sent any data yet';

  @override
  String get homeHeatingDevice => 'Heating device';

  @override
  String get homeDeviceDisabled => 'Disabled in the panel';

  @override
  String offlineBannerSince(String time) {
    return 'No connection to GI Home · data from $time';
  }

  @override
  String refreshFailedBanner(String time) {
    return 'Could not refresh · data from $time';
  }

  @override
  String get roomsUnavailableBanner =>
      'Could not load the rooms – devices are shown together.';

  @override
  String get deviceInfoSection => 'Information';

  @override
  String get deviceStatusSection => 'Status';

  @override
  String get deviceConnectivity => 'Connectivity';

  @override
  String get deviceProductStatus => 'Device status';

  @override
  String get deviceManufacturer => 'Manufacturer';

  @override
  String get deviceModel => 'Model';

  @override
  String get deviceFirmware => 'Firmware version';

  @override
  String get deviceRoom => 'Room';

  @override
  String get deviceFaults => 'Active faults';

  @override
  String get deviceNeedsAttention =>
      'Needs attention – check the device in the web panel.';

  @override
  String deviceValueFromDiagnostics(String time) {
    return 'From device diagnostics · $time';
  }

  @override
  String get deviceFlagsSection => 'Operating modes';

  @override
  String get deviceFlagHeatingSuspended => 'Heating suspended';

  @override
  String get deviceFlagDryRun => 'Test mode (relays do not switch)';

  @override
  String get deviceFlagPvBoost => 'PV surplus boost';

  @override
  String get deviceDisabledBanner =>
      'This device is disabled in the GI Home panel.';

  @override
  String get deviceDiagnosticsEmpty =>
      'The device has not sent diagnostics yet.';

  @override
  String get deviceDiagUptime => 'Uptime';

  @override
  String get deviceDiagWifiRssi => 'Wi-Fi signal';

  @override
  String get deviceDiagBootCount => 'Boot count';

  @override
  String get deviceDiagRebootLoop => 'Reboot loop detected';

  @override
  String get deviceDiagSafetyInterlock => 'Safety interlock active';

  @override
  String get deviceDiagActiveFaults => 'Faults in diagnostics';

  @override
  String signalDbm(int value) {
    return '$value dBm';
  }

  @override
  String durationDaysHours(int days, int hours) {
    return '$days d $hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get entityRoleHeatingRelay => 'Boiler relay';

  @override
  String get entityRolePumpRelay => 'Pump relay';

  @override
  String get entityRoleControlTemperature => 'Control temperature';

  @override
  String get firmwareStateBoot => 'Booting';

  @override
  String get firmwareStateSelfTest => 'Self-test';

  @override
  String get firmwareStateReady => 'Ready';

  @override
  String get firmwareStateIdle => 'Idle';

  @override
  String get firmwareStateHeatingRequested => 'Heating requested';

  @override
  String get firmwareStateHeatingVerifying => 'Verifying heating';

  @override
  String get firmwareStateHeating => 'Heating';

  @override
  String get firmwareStateStopping => 'Stopping';

  @override
  String get firmwareStateFault => 'Fault';

  @override
  String get firmwareStateSafeMode => 'Safe mode';

  @override
  String get firmwareStateUnknown => 'Unknown state';

  @override
  String heatingCardSubtitle(String room) {
    return 'Heating device · $room';
  }

  @override
  String get heatingCardBoiler => 'Boiler';

  @override
  String get heatingCardBoilerOn => 'Heating';

  @override
  String get heatingCardBoilerOff => 'Not heating';

  @override
  String get heatingCardPump => 'Pump';

  @override
  String get heatingCardPumpOn => 'Running';

  @override
  String get heatingCardPumpOff => 'Stopped';

  @override
  String get heatingCardRelayNote =>
      'Relay states as commanded by the controller';

  @override
  String get heatingCardControllerUnknown =>
      'Waiting for data from the controller';

  @override
  String get heatingCardLoading => 'Fetching details…';

  @override
  String heatingCardDataFrom(String time) {
    return 'Data from $time';
  }

  @override
  String heatingCardFailedSince(String time) {
    return 'Could not fetch details · data from $time';
  }

  @override
  String get heatingCardFailed => 'Could not fetch heating details';

  @override
  String get attentionNeedsConfiguration =>
      'Needs configuration in the GI Home web panel';

  @override
  String get homeLimitedHeatingDetailsFailed =>
      'Could not fetch heating details.';

  @override
  String get experimentalTitle => 'Experimental features';

  @override
  String get experimentalIntro =>
      'For testers. Changed flags stay on this phone until you reset them to the defaults.';

  @override
  String get experimentalFlagsSection => 'Feature flags';

  @override
  String get experimentalConfigSection => 'Configuration';

  @override
  String get experimentalFlavor => 'App flavor';

  @override
  String get experimentalNoDefines =>
      'Built without a config file: every flag is off by default.';

  @override
  String get experimentalReset => 'Reset to defaults';

  @override
  String get experimentalResetDone => 'Flags reset to their defaults.';

  @override
  String get experimentalChanged => 'Changed on this phone';

  @override
  String get experimentalDevOnly => 'Available in the dev flavor only';

  @override
  String get flagMockCoreTitle => 'Mock GI Core';

  @override
  String get flagMockCoreDescription =>
      'The app talks to a built-in mock instead of GI Core on the network. Switching it recreates the connection.';

  @override
  String get flagScheduleClockConversionTitle => 'Convert schedule times';

  @override
  String get flagScheduleClockConversionDescription =>
      'Schedule times can be edited in the home time zone; the app converts them to the GI Core clock.';

  @override
  String get flagSwitchControlByIntegrationTitle =>
      'Switch control by integration';

  @override
  String get flagSwitchControlByIntegrationDescription =>
      'Switches can be controlled depending on the device\'s integration type.';

  @override
  String get flagAndroidLocalNetworkPermissionRequestTitle =>
      'Ask for local network access (Android)';

  @override
  String get flagAndroidLocalNetworkPermissionRequestDescription =>
      'Before connecting, the app asks for the nearby devices permission (local network protection).';

  @override
  String get permissionDeniedTitle => 'No access';

  @override
  String get permissionDeniedBody =>
      'Your role in GI Home does not allow viewing this data. If this is a mistake, ask the owner or an administrator to change your role.';

  @override
  String freshnessUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String freshnessUpdatedStale(String time) {
    return 'Updated $time, data may be out of date';
  }

  @override
  String get freshnessWaitingForReading => 'Waiting for the first reading';

  @override
  String get schedulesOfflineBanner =>
      'No connection to GI Home. You are seeing the last list loaded – you can refresh it.';

  @override
  String get schedulesRefreshFailedBanner =>
      'Could not refresh the schedules. You are seeing the last list loaded – you can try again.';

  @override
  String get staleAppTitle => 'Update the app';

  @override
  String get staleAppBody =>
      'This version of the app does not understand some GI Home responses. Install the latest version.';

  @override
  String get staleAppOpenStore => 'Open the store';

  @override
  String get staleAppDismiss => 'Hide message';

  @override
  String get heatingViewOnlyHint => 'Heating changes can be made by the owner.';

  @override
  String get heatingDryRunBanner =>
      'Test mode: commands are recorded but outputs stay off.';

  @override
  String get lockNotOwnerAdmin =>
      'Heating changes can be made by the owner or an administrator. Ask them to make the change.';

  @override
  String get lockHeatingOrPumpRelay =>
      'The boiler and pump relays are driven by the controller. The app shows them read-only.';

  @override
  String get lockEntityMissing =>
      'This item is no longer part of the device. Refresh the view.';

  @override
  String get lockNotWritableSwitch =>
      'This item cannot be switched from the app.';

  @override
  String get lockEntityDisabled =>
      'This item is disabled. Enable it in the GI Home panel to control it.';

  @override
  String get lockEntityUnavailable =>
      'This item is unavailable. Check the device connection and try again.';

  @override
  String get lockStaleData =>
      'The data is out of date, so controls are locked. Wait for a refresh. Suspending heating still works.';

  @override
  String get lockSuspendedOnRequest =>
      'Heating is suspended. Resume it to turn switches on.';

  @override
  String get lockFaultLatched =>
      'The controller reports a fault or safe mode. It needs an authorized manual reset on the device; in an emergency call a technician.';

  @override
  String get consequenceStopsHeating =>
      'GI Home will turn heating off. You can resume it later.';

  @override
  String get consequenceBoilerMayStartSoon =>
      'The boiler may start within ~30 s.';

  @override
  String get consequenceRestoresBaseOrSchedule =>
      'The default setting or the active schedule applies again.';

  @override
  String get consequenceCommandNotPhysicallyVerified =>
      'The command will be sent, but the app does not confirm that the relay physically switched.';

  @override
  String get consequenceLargeTargetRaise =>
      'The target temperature rises by more than 10 °C.';

  @override
  String get consequenceLeavesOffMode =>
      'GI Home will control the boiler again and may turn it on.';

  @override
  String get consequenceAboveSafeMax =>
      'The target temperature is above the safe maximum set for PV surplus.';

  @override
  String get consequenceDryRunOutputsStayOff =>
      'Test mode: the command will be recorded but outputs stay off.';

  @override
  String get switchCommandSending => 'Sending…';

  @override
  String switchCommandLegacyConfirmed(String state, String time) {
    return 'The device confirmed the command: $state, $time. The physical relay state is not verified.';
  }

  @override
  String get switchCommandAwaitingHeartbeat =>
      'Requested · waiting for the controller to report back';

  @override
  String switchCommandHeartbeatObserved(String commanded, String output) {
    return 'After the command the controller reported: commanded $commanded, output $output – this does not confirm the physical relay state.';
  }

  @override
  String switchCommandDryRunRecorded(String commanded) {
    return 'Recorded in test mode: commanded $commanded, the output stays off.';
  }

  @override
  String get switchCommandTimedOut =>
      'The controller did not report back within 45 s – the state is unknown. Refresh before trying again.';

  @override
  String get entitySwitchAwaitingReport => 'awaiting controller report';

  @override
  String switchControllerCommanded(String state) {
    return 'Controller command: $state';
  }

  @override
  String switchDryRunWouldSet(String state) {
    return 'Controller would set: $state';
  }

  @override
  String get switchValueAwaitingReport => 'waiting for a report';

  @override
  String switchConfirmOnTitle(String name) {
    return 'Send the turn-on command to $name?';
  }

  @override
  String get switchConfirmSend => 'Send command';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String heatingStrategyTarget(String temperature, String hysteresis) {
    return 'Target $temperature °C, hysteresis $hysteresis °C';
  }

  @override
  String get heatingStrategyModeAuto => 'GI Home controls the boiler';

  @override
  String get heatingStrategyModeOff =>
      'Control off – GI Home will not turn the boiler on';

  @override
  String get heatingStrategyModeManual =>
      'GI Home does not control automatically';

  @override
  String get heatingStrategyModeUnknown => 'Unknown control mode';

  @override
  String get heatingStrategyNone =>
      'No control settings – set them up in the GI Home web panel';

  @override
  String get heatingScheduleActive => 'Schedule active';

  @override
  String heatingStrategyDefault(String temperature, String hysteresis) {
    return 'Default: $temperature °C, hysteresis $hysteresis °C';
  }

  @override
  String get heatingSuspendedTitle => 'Heating suspended';

  @override
  String get heatingSuspendedEffect =>
      'GI Home will not turn the boiler on until heating is resumed.';

  @override
  String get heatingSuspendedResumeHint =>
      'To resume heating, open the device details.';

  @override
  String get heatingSuspendedAskOwner =>
      'Only the owner or an administrator can resume heating.';

  @override
  String get heatingResumeAction => 'Resume heating';

  @override
  String heatingPvBoost(String temperature) {
    return 'PV boost: heating to $temperature °C';
  }

  @override
  String get heatingPvBoostDerived => 'Target derived from the PV safety limit';

  @override
  String get heatingPvBoostUnknownTarget => 'PV boost active – target unknown';

  @override
  String heatingStrategySource(String time) {
    return 'According to GI Home · data from $time';
  }

  @override
  String get heatingControlSection => 'Heating control';

  @override
  String get strategyEditAction => 'Change control settings';

  @override
  String get strategyEditorTitle => 'Control settings';

  @override
  String get strategyEditorIntro =>
      'You are changing the default setting. An active schedule may replace it for a while.';

  @override
  String get strategyTargetLabel => 'Target temperature (°C)';

  @override
  String get strategyHysteresisLabel => 'Hysteresis (°C)';

  @override
  String get strategyModeLabel => 'Control mode';

  @override
  String get strategyModeAutoShort => 'Auto';

  @override
  String get strategyModeOffShort => 'Off';

  @override
  String get strategyModeManualShort => 'Manual';

  @override
  String get strategyErrorNotANumber => 'Enter a number';

  @override
  String strategyErrorRange(String min, String max) {
    return 'Allowed range: $min–$max °C';
  }

  @override
  String strategyErrorStep(String step) {
    return 'Use steps of $step °C';
  }

  @override
  String strategyAboveSafeMaxWarning(String temperature) {
    return 'This is above the safe maximum for PV surplus ($temperature °C).';
  }

  @override
  String get strategySuspendedNote =>
      'Heating is suspended. The saved setting applies once heating is resumed – until then the mode stays Off.';

  @override
  String get strategySave => 'Save';

  @override
  String get strategyChecking => 'Checking the current settings…';

  @override
  String get strategySaving => 'Saving…';

  @override
  String get strategyConflictTitle =>
      'Someone changed the settings in the meantime';

  @override
  String get strategyConflictBody =>
      'Nothing was saved. Check what changed and decide what to do.';

  @override
  String strategyConflictRow(String field, String before, String after) {
    return '$field: $before → $after';
  }

  @override
  String get strategyFieldTarget => 'Target temperature';

  @override
  String get strategyFieldHysteresis => 'Hysteresis';

  @override
  String get strategyFieldMode => 'Mode';

  @override
  String get strategyFieldSuspended => 'Heating';

  @override
  String get strategyValueNone => 'none';

  @override
  String get strategyValueSuspended => 'suspended';

  @override
  String get strategyValueActive => 'active';

  @override
  String get strategyConflictReapply => 'Save my changes anyway';

  @override
  String get strategyConflictDiscard => 'Discard my changes';

  @override
  String get strategySavedTitle => 'Saved in GI Home';

  @override
  String strategySavedBase(String value) {
    return 'Default setting: $value';
  }

  @override
  String strategySavedEffective(String value) {
    return 'In effect now: $value';
  }

  @override
  String get strategySavedSuspended =>
      'Heating is suspended, so the mode stays Off until heating is resumed.';

  @override
  String strategyValue(String target, String hysteresis, String mode) {
    return '$target °C, hysteresis $hysteresis °C, $mode';
  }

  @override
  String get strategyConfirmTitle => 'Confirm the settings change';

  @override
  String get strategyConfirmSave => 'Save changes';

  @override
  String get suspendHoldAction => 'Hold to suspend heating';

  @override
  String get suspendHoldHint =>
      'Press and hold the button – a short tap changes nothing.';

  @override
  String get suspendA11yHint => 'opens the suspend confirmation';

  @override
  String get suspendConfirmTitle => 'Suspend heating?';

  @override
  String get suspendConfirmAction => 'Suspend heating';

  @override
  String get suspendAwaiting =>
      'Sent · waiting for GI Home to confirm the suspension';

  @override
  String get resumeAwaiting =>
      'Sent · waiting for GI Home to confirm the resume';

  @override
  String get suspendAppliedAwaitingHeartbeat =>
      'Heating suspended. Relays commanded off · waiting for the controller report';

  @override
  String suspendAppliedOutputsOff(String time) {
    return 'Heating suspended. Controller report at $time: relay outputs off. This does not confirm the physical relay state.';
  }

  @override
  String suspendAppliedOutputOn(String time) {
    return 'Heating suspended, but the controller report at $time still shows an output on. Refresh in a moment and, if in danger, switch the boiler off by hand.';
  }

  @override
  String get suspendAppliedNotReported =>
      'Heating suspended. Relays were commanded off, but the controller does not report its outputs.';

  @override
  String get suspendAppliedNoHeartbeat =>
      'Heating suspended. Relays were commanded off, but the controller did not report within 45 s – the relay state is unknown.';

  @override
  String get suspendAppliedLegacy =>
      'Heating suspended. This ESPHome device gets no relay-off commands – GI Home simply will not turn the boiler on.';

  @override
  String get resumeApplied =>
      'Heating resumed. The default setting or the schedule applies again.';

  @override
  String get resumeAppliedPending =>
      'Heating resumed. GI Home has not restored the control mode yet – refresh in a moment.';

  @override
  String get suspendTimedOut =>
      'GI Home did not confirm the suspension within 30 s. Refresh and check the state.';

  @override
  String get resumeTimedOut =>
      'GI Home did not confirm the resume within 30 s. Refresh and check the state.';

  @override
  String get resumeSheetTitle => 'Resume heating?';

  @override
  String resumeSheetWillApply(String value) {
    return 'Will apply: $value';
  }

  @override
  String resumeSheetTemperature(String value, String time) {
    return 'Control temperature: $value · data from $time';
  }

  @override
  String get resumeSheetTemperatureMissing =>
      'No current control temperature reading.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageAutomatic => 'Automatic';

  @override
  String get settingsLanguageAutomaticSubtitle =>
      'The language of your GI Home profile, otherwise the phone language';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageDialogTitle => 'App language';

  @override
  String languageSelectorLabel(String language) {
    return 'Language: $language';
  }

  @override
  String get settingsCoreVersion => 'GI Home software version';

  @override
  String settingsCoreVersionSubtitle(String version) {
    return '$version (as of the last update check)';
  }

  @override
  String get settingsTimezone => 'Device time zone';

  @override
  String settingsSessionRenewSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'You will need to log in again in $days days',
      one: 'You will need to log in again in 1 day',
      zero: 'Your session has expired – log in again',
    );
    return '$_temp0';
  }

  @override
  String get demoEntryTitle => 'Don\'t have GI Home yet?';

  @override
  String get demoEntryBody =>
      'See the app with a sample home. The data is made up and stays on this phone, and no command reaches any device.';

  @override
  String get demoEnter => 'Try the demo';

  @override
  String get demoStartFailed => 'The demo could not be started. Try again.';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get demoBadgeSemantics => 'Demo version';

  @override
  String get demoBannerMessage => 'Sample data – nothing is really controlled.';

  @override
  String get demoExit => 'Exit demo';

  @override
  String get schedulesTitle => 'Schedules';

  @override
  String get schedulesEntryTitle => 'Heating schedules';

  @override
  String get schedulesEntrySubtitle =>
      'Times and days with a different target temperature';

  @override
  String get schedulesEmptyTitle => 'No schedules';

  @override
  String get schedulesEmptyBody =>
      'Heating follows the default setting all the time.';

  @override
  String get schedulesAdd => 'Add schedule';

  @override
  String get scheduleActiveNow => 'Active now';

  @override
  String get scheduleDisabledChip => 'Disabled';

  @override
  String get scheduleWholeDay => 'All day';

  @override
  String scheduleTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String scheduleTimeRangeNextDay(String start, String end) {
    return '$start–$end (next day)';
  }

  @override
  String scheduleTargetLine(String target, String hysteresis) {
    return '$target °C, hysteresis $hysteresis °C';
  }

  @override
  String get scheduleClockCoreOnly => 'Times follow the GI Home clock (UTC).';

  @override
  String scheduleClockDualHome(String core, String local) {
    return 'Times follow the GI Home clock (UTC). Today $core UTC is $local home time.';
  }

  @override
  String scheduleClockDualPhone(String core, String local) {
    return 'Times follow the GI Home clock (UTC). Today $core UTC is $local on this phone.';
  }

  @override
  String scheduleClockConverting(String zone) {
    return 'Times are in home time ($zone). They are converted to the GI Home clock (UTC) with today\'s offset.';
  }

  @override
  String get scheduleDstAhead =>
      'A clock change is coming. Schedules stay at the same UTC time, so in home time they will move by an hour. Nothing is changed automatically.';

  @override
  String get scheduleOrderHint =>
      'When windows overlap, the schedule added first applies. Suspending heating takes precedence over schedules.';

  @override
  String get scheduleGone =>
      'This schedule no longer exists. The list has been refreshed.';

  @override
  String get scheduleSaved => 'Schedule saved.';

  @override
  String get scheduleDeleted => 'Schedule deleted.';

  @override
  String get scheduleNotFound => 'Schedule not found.';

  @override
  String get scheduleEditorNewTitle => 'New schedule';

  @override
  String get scheduleEditorEditTitle => 'Edit schedule';

  @override
  String get scheduleFieldName => 'Name';

  @override
  String get scheduleFieldDays => 'Days';

  @override
  String get scheduleFieldStart => 'From';

  @override
  String get scheduleFieldEnd => 'To';

  @override
  String get scheduleFieldTarget => 'Target temperature (°C)';

  @override
  String get scheduleFieldHysteresis => 'Hysteresis (°C)';

  @override
  String get scheduleFieldEnabled => 'Enabled';

  @override
  String get scheduleErrorName => 'Enter a name of up to 120 characters.';

  @override
  String get scheduleErrorDays => 'Choose at least one day.';

  @override
  String get scheduleErrorTarget => 'Enter a value from 0 to 100 °C.';

  @override
  String get scheduleErrorHysteresis => 'Enter a value from 1 to 20 °C.';

  @override
  String get scheduleWarnWholeDay =>
      'Start and end are the same, so the schedule applies all day on the chosen days.';

  @override
  String scheduleWarnWraps(String end) {
    return 'The window ends the next day at $end.';
  }

  @override
  String scheduleWarnOverlap(String names) {
    return 'Overlaps with: $names. The schedule added first applies.';
  }

  @override
  String get scheduleSave => 'Save';

  @override
  String get scheduleDelete => 'Delete schedule';

  @override
  String get scheduleDeleteConfirmTitle => 'Delete the schedule?';

  @override
  String scheduleDeleteConfirmBody(String name) {
    return 'The schedule “$name” will be deleted. If it was active, heating returns to the default setting.';
  }

  @override
  String get scheduleDeleteConfirm => 'Delete';

  @override
  String get weatherEntryTitle => 'Weather and sun';

  @override
  String get weatherEntrySubtitle =>
      'Forecast, sunrise and sunset, PV production';

  @override
  String get weatherTitle => 'Weather and sun';

  @override
  String get weatherSection => 'Weather';

  @override
  String get weatherHourlySection => 'Next hours';

  @override
  String get weatherDailySection => 'Next days';

  @override
  String get weatherNoDataTitle => 'No weather data';

  @override
  String get weatherNoDataBody =>
      'GI Home has no internet access right now or has not fetched the forecast yet. The app works – check the device’s internet connection.';

  @override
  String get weatherStaleBanner =>
      'The forecast may be out of date – GI Home could not refresh it because it has no internet access.';

  @override
  String weatherHumidity(String value) {
    return 'Humidity $value%';
  }

  @override
  String weatherWind(String speed) {
    return 'Wind $speed m/s';
  }

  @override
  String weatherPressure(String value) {
    return 'Pressure $value hPa';
  }

  @override
  String weatherPrecipitation(String value) {
    return 'Precipitation $value mm';
  }

  @override
  String weatherTemperature(String value) {
    return '$value °C';
  }

  @override
  String weatherHourSemantics(
    String time,
    String temperature,
    String condition,
  ) {
    return '$time: $temperature, $condition';
  }

  @override
  String weatherDaySemantics(
    String day,
    String min,
    String max,
    String precipitation,
    String condition,
  ) {
    return '$day: from $min to $max, precipitation $precipitation mm, $condition';
  }

  @override
  String weatherTimesHouseZone(String zone) {
    return 'Times in the home time zone ($zone)';
  }

  @override
  String get weatherTimesPhoneZone => 'Times in the phone’s time zone';

  @override
  String get weatherDaysUtc => 'Days are counted in UTC';

  @override
  String get weatherGlyphClearSky => 'Clear sky';

  @override
  String get weatherGlyphFair => 'Fair';

  @override
  String get weatherGlyphPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherGlyphCloudy => 'Cloudy';

  @override
  String get weatherGlyphFog => 'Fog';

  @override
  String get weatherGlyphShowers => 'Showers';

  @override
  String get weatherGlyphRain => 'Rain';

  @override
  String get weatherGlyphThunder => 'Thunderstorm';

  @override
  String get weatherGlyphSleetOrSnowShowers => 'Sleet or snow showers';

  @override
  String get weatherGlyphSnow => 'Snow';

  @override
  String get weatherGlyphClearNight => 'Clear night';

  @override
  String get weatherGlyphUnknown => 'Unknown weather';

  @override
  String get solarSection => 'Sun';

  @override
  String get solarSunrise => 'Sunrise';

  @override
  String get solarSunset => 'Sunset';

  @override
  String get solarDayLength => 'Day length';

  @override
  String solarAboveHorizon(String elevation) {
    return 'Sun above the horizon ($elevation°)';
  }

  @override
  String get solarBelowHorizon => 'Sun below the horizon';

  @override
  String get solarNotConfigured =>
      'Set the house location in the GI Home panel to see sunrise and sunset.';

  @override
  String get solarNoData => 'No sun data.';

  @override
  String get pvForecastSection => 'PV production forecast';

  @override
  String pvForecastPeakPower(String power) {
    return 'Installed power $power kWp';
  }

  @override
  String pvForecastDayEnergy(String energy) {
    return '$energy kWh';
  }

  @override
  String pvForecastDayPeak(String power, String time) {
    return 'peak $power kW at $time';
  }

  @override
  String get pvForecastNoDataTitle => 'No PV forecast';

  @override
  String get pvForecastNoDataBody =>
      'GI Home could not fetch the production forecast – it may have no internet access.';

  @override
  String get pvHouseTimeNote => 'Times in the home’s local time';

  @override
  String get pvPlanSection => 'PV heating plan';

  @override
  String get pvPlanDisabled => 'PV plan off';

  @override
  String get pvPlanDisabledBody =>
      'Heating does not use the PV production forecast.';

  @override
  String get pvPlanNoHours => 'PV plan without a forecast';

  @override
  String get pvPlanNoHoursBody =>
      'GI Home has no production forecast right now, so it plans no PV boost.';

  @override
  String pvPlanMode(String mode) {
    return 'Mode: $mode';
  }

  @override
  String get pvModeForecastOnly => 'forecast only';

  @override
  String get pvModeLiveInverterOnly => 'live inverter only';

  @override
  String get pvModeHybrid => 'hybrid (forecast and inverter)';

  @override
  String get pvModeUnknown => 'unknown';

  @override
  String pvPlanBaseTarget(String temperature) {
    return 'Base temperature $temperature °C';
  }

  @override
  String pvPlanSafeMax(String temperature) {
    return 'Safe maximum $temperature °C';
  }

  @override
  String pvPlanBoost(String temperature) {
    return 'Boost to $temperature °C';
  }

  @override
  String pvPlanNoBoost(String temperature) {
    return 'No boost, $temperature °C';
  }

  @override
  String pvPlanProduction(String power) {
    return '$power kW';
  }

  @override
  String pvPlanHourSemantics(String time, String production, String state) {
    return '$time: production $production, $state';
  }

  @override
  String pvPlanShowAll(int count) {
    return 'Show all hours ($count)';
  }

  @override
  String get pvPlanShowLess => 'Show less';

  @override
  String get pvPlanLoadFailed => 'Could not load the PV plan';

  @override
  String get historyTitle => 'History';

  @override
  String get historyNightEntryTitle => 'What happened overnight?';

  @override
  String get historyNightEntrySubtitle =>
      'Control temperature over the last 24 hours';

  @override
  String get historyEntityHint => 'show history';

  @override
  String get historyWindowLabel => 'Range';

  @override
  String get historyWindowHour => '1 h';

  @override
  String get historyWindowSixHours => '6 h';

  @override
  String get historyWindowDay => '24 h';

  @override
  String get historyWindowWeek => '7 days';

  @override
  String get historyWindowHourLong => 'last hour';

  @override
  String get historyWindowSixHoursLong => 'last 6 hours';

  @override
  String get historyWindowDayLong => 'last 24 hours';

  @override
  String get historyWindowWeekLong => 'last 7 days';

  @override
  String get historyShowTable => 'Show as table';

  @override
  String get historyShowChart => 'Show chart';

  @override
  String get historyEmptyTitle => 'No changes in this period';

  @override
  String get historyEmptyBody =>
      'GI Home records a reading only when its value changes. If it stayed constant, the history is empty.';

  @override
  String get historyTruncated =>
      'This period has more changes than the app loads at once. The chart shows only part of them; pick a shorter range.';

  @override
  String get historyTextOnly =>
      'This is a text reading, so its history is shown as a table.';

  @override
  String get historyChartLoading => 'Preparing the chart';

  @override
  String get historySummaryMin => 'Lowest';

  @override
  String get historySummaryMax => 'Highest';

  @override
  String get historySummaryLast => 'Latest';

  @override
  String get historySummaryChanges => 'Changes';

  @override
  String historyChartSemantics(
    String name,
    String range,
    String min,
    String max,
    String last,
    String time,
    int count,
  ) {
    return 'Chart: $name, $range. Lowest $min, highest $max, latest $last at $time. Recorded changes: $count.';
  }

  @override
  String historySwitchSemantics(
    String name,
    String range,
    String last,
    String time,
    int count,
  ) {
    return 'Chart: $name, $range. Latest $last at $time. Recorded switches: $count.';
  }

  @override
  String get historyTableTime => 'Time';

  @override
  String get historyTableValue => 'Value';

  @override
  String historyTableRowSemantics(String time, String value) {
    return '$time: $value';
  }

  @override
  String historyTablePage(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get historyTableNewer => 'Newer';

  @override
  String get historyTableOlder => 'Older';

  @override
  String get errorHistoryRangeInvalid =>
      'GI Home rejected this time range. Check the date and time on your phone.';

  @override
  String get navAttention => 'Alerts';

  @override
  String get attentionTitle => 'Alerts';

  @override
  String attentionBadgeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items need attention',
      one: '1 item needs attention',
    );
    return '$_temp0';
  }

  @override
  String get attentionEmptyTitle => 'Nothing needs attention';

  @override
  String get attentionEmptyBody =>
      'Devices are working and in contact with GI Home.';

  @override
  String get attentionSectionCritical => 'Critical';

  @override
  String get attentionSectionImportant => 'Important';

  @override
  String get attentionSectionNotice => 'Worth checking';

  @override
  String get attentionSectionResolved => 'Resolved in the last 24 h';

  @override
  String get attentionAccountTitle => 'Your account';

  @override
  String get attentionMustChangePassword => 'Password change required';

  @override
  String attentionResolvedAt(String what, String time) {
    return '$what · resolved at $time';
  }

  @override
  String get offlineSnapshotReadOnly =>
      'Read-only: device states from the last connection.';

  @override
  String get flagConditionalGetTitle => 'Conditional device requests (ETag)';

  @override
  String get flagConditionalGetDescription =>
      'The device list and details are requested with If-None-Match; a 304 response saves data. The change applies from the next session.';

  @override
  String get flagMdnsFallbackTitle => 'Find the appliance over multicast DNS';

  @override
  String get flagMdnsFallbackDescription =>
      'Android only. When the system cannot resolve a .local name, the app asks the local network for it directly. Applies from the next search.';

  @override
  String get settingsAccountManage => 'Profile and security';

  @override
  String get accountTitle => 'Profile and security';

  @override
  String get accountProfileSection => 'Profile';

  @override
  String get accountFirstNameLabel => 'First name';

  @override
  String get accountLastNameLabel => 'Last name (optional)';

  @override
  String get accountFirstNameRequired => 'Enter your first name.';

  @override
  String get accountNameTooLong => 'At most 100 characters.';

  @override
  String get accountSave => 'Save changes';

  @override
  String get accountSaved => 'Profile saved.';

  @override
  String get accountLanguageSection => 'Account language';

  @override
  String get accountLanguageHint =>
      'After sign-in the app and the web panel use this language, unless another one is picked in the app settings.';

  @override
  String get accountLanguagePolish => 'Polski';

  @override
  String get accountLanguageEnglish => 'English';

  @override
  String get accountLanguageSaved => 'Account language changed.';

  @override
  String get accountSecuritySection => 'Security';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String get accountChangePasswordSubtitle => 'Other devices are signed out';

  @override
  String get accountSessions => 'Active sessions';

  @override
  String get accountSessionsSubtitle => 'Devices signed in to your account';

  @override
  String get accountRecoveryCode => 'Recovery code';

  @override
  String get accountRecoveryCodeSubtitle =>
      'Lets you set a new password if you forget the current one';

  @override
  String get changePasswordVoluntaryIntro =>
      'After the change, other devices are signed out. This phone stays signed in.';

  @override
  String get changePasswordVoluntarySubmit => 'Change password';

  @override
  String get sessionsTitle => 'Active sessions';

  @override
  String get sessionsThisPhone => 'This phone';

  @override
  String get sessionsUnknownDevice => 'Unknown device';

  @override
  String sessionsSignedIn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Signed in $dateString';
  }

  @override
  String sessionsLastUsed(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Last active $dateString';
  }

  @override
  String sessionsIpAddress(String ip) {
    return 'IP address: $ip';
  }

  @override
  String get sessionsRevokeTooltip => 'Sign out this session';

  @override
  String get sessionsRevokeTitle => 'Sign out this device?';

  @override
  String get sessionsRevokeBody => 'The device will have to sign in again.';

  @override
  String get sessionsRevokeCurrentTitle => 'Sign out this phone?';

  @override
  String get sessionsRevokeCurrentBody =>
      'This phone\'s session ends and you return to the sign-in screen.';

  @override
  String get sessionsRevokeConfirm => 'Sign out';

  @override
  String get sessionsRevoked => 'The session was ended.';

  @override
  String get sessionsLogoutAll => 'Sign out all devices';

  @override
  String get sessionsLogoutAllTitle => 'Sign out all devices?';

  @override
  String get sessionsLogoutAllBody =>
      'Every session, this phone\'s included, will end.';

  @override
  String get sessionsEmpty => 'No active sessions.';

  @override
  String sessionsReviewPrompt(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your account has $count other active sessions.',
      one: 'Your account has 1 other active session.',
    );
    return '$_temp0';
  }

  @override
  String get sessionsReviewAction => 'Review';

  @override
  String get recoveryCodeTitle => 'Recovery code';

  @override
  String get recoveryCodeIntro =>
      'The recovery code lets you set a new password on the sign-in screen if you forget the current one. A new code replaces the previous one.';

  @override
  String get recoveryCodeGenerate => 'Generate a new code';

  @override
  String get recoveryCodeConfirmTitle => 'Generate a new code?';

  @override
  String get recoveryCodeConfirmBody =>
      'The previous code stops working. You will see the new code only once.';

  @override
  String get recoveryCodeConfirm => 'Generate';

  @override
  String get recoveryCodeShownOnce =>
      'This code is shown only once. Save it in a safe place, such as a password manager.';

  @override
  String get recoveryCodeCopy => 'Copy code';

  @override
  String get recoveryCodeCopied =>
      'Copied. The clipboard is cleared in a minute.';

  @override
  String get recoveryCodeHidden =>
      'The code is hidden while the screen is recorded or the app is in the background.';

  @override
  String get recoveryCodeAcknowledge => 'I have saved the code in a safe place';

  @override
  String get recoveryCodeDone => 'Done';

  @override
  String get recoveryCodeLeaveBlocked =>
      'First confirm that you saved the code.';

  @override
  String get recoveryRotatePromptTitle => 'Generate a new recovery code';

  @override
  String get recoveryRotatePromptBody =>
      'Your password was set with the recovery code, which still works. Generate a new code so the previous one stops working.';

  @override
  String get recoveryRotatePromptLater => 'Later';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get recoveryResetTitle => 'Password recovery';

  @override
  String get recoveryResetHidden =>
      'The form is hidden while the screen is recorded or the app is in the background.';

  @override
  String get recoveryResetIntro =>
      'Enter the account e-mail, the recovery code and a new password. After the change every device is signed out.';

  @override
  String get recoveryResetCodeLabel => 'Recovery code';

  @override
  String get recoveryResetCodeHelper =>
      '8 groups of 4 characters separated by dashes, e.g. 1A2B-3C4D-…';

  @override
  String get recoveryResetCodeRequired => 'Enter the recovery code.';

  @override
  String get recoveryResetCodeMalformed =>
      'The code is 8 groups of 4 characters (0–9, A–F) separated by dashes.';

  @override
  String get recoveryResetSubmit => 'Set new password';

  @override
  String get recoveryResetInvalid =>
      'The password could not be set. Check the e-mail and the recovery code.';

  @override
  String get recoveryResetRateLimited =>
      'Too many attempts. Try again in a few minutes.';

  @override
  String get recoveryResetDoneTitle => 'Password changed';

  @override
  String get recoveryResetDoneBody =>
      'Sign in with the new password. After signing in, generate a new recovery code, because the current one still works.';

  @override
  String get recoveryResetGoToLogin => 'Go to sign-in';

  @override
  String get recoveryResetBack => 'Back to sign-in';

  @override
  String get errorHttpsRequired =>
      'This device requires an encrypted connection (https://), which the app does not support yet. Use the unencrypted address in your home network, e.g. 192.168.1.20:3000.';

  @override
  String get connectErrorUnreachable =>
      'No GI Home found at this address. Check that your phone is on the same Wi-Fi as the device (not a guest network) and enter its IP address, e.g. 192.168.1.20:3000.';

  @override
  String get connectHelpLink => 'Where do I find the address?';

  @override
  String get connectHelpTitle => 'Where do I find the GI Home address?';

  @override
  String get connectHelpSameWifi =>
      'Your phone must be on the same Wi-Fi as GI Home. Guest networks and mobile data do not work.';

  @override
  String get connectHelpRouter =>
      'You can find the device IP address in the connected-devices list of your router, e.g. 192.168.1.20.';

  @override
  String get connectHelpPort =>
      'If the IP alone does not work, add the port: 192.168.1.20:3000. The app tries ports 80 and 3000 by itself.';

  @override
  String get connectHelpLocalName =>
      'A ready-made GI Home usually answers to gi-home.local as well, but not on every phone. The IP address always works.';

  @override
  String get connectHelpClose => 'Close';
}
