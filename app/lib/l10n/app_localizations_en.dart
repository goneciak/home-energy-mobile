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
  String get connectAddressHint => 'e.g. gi-home.local or 192.168.1.20';

  @override
  String get connectAddressRequired => 'Enter the GI Home address';

  @override
  String get connectSearchTitle => 'Find GI Home';

  @override
  String get connectSearching => 'Looking for GI Home…';

  @override
  String get connectSearchNoneFound =>
      'No GI Home found on this network. Enter its address below.';

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
  String get heatingCardControllerUnknown => 'Controller: no data';

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
  String get staleAppTitle => 'Update the app';

  @override
  String get staleAppBody =>
      'This version of the app does not understand some GI Home responses. Install the latest version.';

  @override
  String get staleAppOpenStore => 'Open the store';

  @override
  String get staleAppDismiss => 'Hide message';
}
