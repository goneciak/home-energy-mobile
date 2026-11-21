import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gi_core_api/gi_core_api.dart';

part 'appliance_profile.freezed.dart';
part 'appliance_profile.g.dart';

/// What the client must be rebuilt for: a different appliance, address or
/// fingerprint. Records compare by value, so this works with `select`.
typedef ApplianceConnection = ({
  String profileId,
  String baseUrl,
  DateTime? initializedAt,
});

/// The one GI Home this phone talks to (v1: single profile, plan §7.1, D1).
/// Holds no secrets; the refresh cookie lives in secure storage under
/// `p/<profileId>/rt`.
@freezed
abstract class ApplianceProfile with _$ApplianceProfile {
  const factory({
    /// Random id scoping secure-storage keys to this profile.
    required String profileId,

    /// Display name: the appliance's device name, or its host.
    required String label,

    /// Normalised origin, e.g. `http://192.168.1.20:3000`: the active
    /// address, always the first of [hosts].
    required String baseUrl,

    /// Origins this appliance has answered on, most recent first, without
    /// duplicates and at most [maxHosts] (plan §7.1). The connection ladder
    /// tries them first (plan §9.2). Profiles saved before this field
    /// existed load with `[baseUrl]`.
    @Default(<String>[]) List<String> hosts,
    String? deviceName,

    /// Appliance fingerprint (plan §9.3); `null` until the appliance is set
    /// up. The session cookie is only ever sent to a matching appliance.
    DateTime? initializedAt,

    /// Pre-fills the login form; cleared by "Zmień użytkownika".
    String? lastUserEmail,

    /// Id of the user last signed in (plan §7.1): set after login and every
    /// `GET /auth/me`, cleared by "Zmień użytkownika". Scopes per-user
    /// state such as the profile language restored on a cold start.
    String? lastUserId,

    /// Whether the one-time "not encrypted" notice (plan §9.4) was shown
    /// when an `http://` address of this profile was confirmed. A new
    /// profile (a replaced appliance) starts without it.
    @Default(false) bool cleartextNoticeShown,
  }) = _ApplianceProfile;

  const new _();

  /// Decodes a stored profile. Profiles stored before `hosts` existed only
  /// have `baseUrl`; it becomes the one known host, so nothing is lost.
  factory fromJson(Map<String, dynamic> json) =>
      _$ApplianceProfileFromJson(json)._withActiveFirst();

  /// A new profile for an appliance confirmed on the connect screen.
  /// [cleartextNoticeShown]: the confirmation showed the cleartext notice.
  factory fromProbe(
    ProbeResult probe, {
    Random? random,
    bool cleartextNoticeShown = false,
  }) {
    final setup = probe.setup;
    final origin = probe.address.origin.toString();
    return ApplianceProfile(
      profileId: newProfileId(random),
      label: _labelFor(setup, probe.address),
      baseUrl: origin,
      hosts: [origin],
      deviceName: setup.deviceName,
      initializedAt: setup.initialized ? setup.initializedAt : null,
      cleartextNoticeShown: cleartextNoticeShown,
    );
  }

  /// How many origins [hosts] keeps.
  static const maxHosts = 5;

  ApplianceAddress get address => ApplianceAddress.parse(baseUrl);

  bool get isInitialized => initializedAt != null;

  /// Whether [setup] comes from this very appliance: both report the same
  /// `initializedAt` (the fingerprint, plan §9.3). An appliance that is not
  /// set up never matches.
  bool isSameAppliance(SetupStatus setup) =>
      initializedAt != null &&
      setup.initialized &&
      setup.initializedAt == initializedAt;

  /// Whether [probe] reached this profile's appliance, so confirming it
  /// keeps the profile and its session instead of replacing them (plan
  /// §9.2, D1 = A): the fingerprint matches, or the profile has none yet
  /// (the appliance was not set up) and [probe] answered on one of its
  /// [knownHosts].
  bool matches(ProbeResult probe) =>
      isSameAppliance(probe.setup) ||
      (!isInitialized && knownHosts.contains(probe.address.origin.toString()));

  /// [baseUrl] and the other [hosts], most recent first, without
  /// duplicates: the remembered hosts of the connection ladder (plan §9.2).
  List<String> get knownHosts => {baseUrl, ...hosts}.toList();

  /// The appliance now answers on [origin] (plan §9.3: a new IP, found
  /// through `gi-home.local`): it becomes the active address and the most
  /// recent known host. Profile id, fingerprint and user stay, so the
  /// stored session is kept.
  ApplianceProfile movedTo(String origin) => copyWith(
    baseUrl: origin,
    hosts: [origin, ...knownHosts],
  )._withActiveFirst();

  /// [hosts] with [baseUrl] first, de-duplicated and capped at [maxHosts].
  ApplianceProfile _withActiveFirst() {
    final known = <String>{baseUrl, ...hosts}.take(maxHosts).toList();
    return copyWith(hosts: known);
  }

  ApplianceConnection get connection =>
      (profileId: profileId, baseUrl: baseUrl, initializedAt: initializedAt);

  /// Records the fingerprint once the appliance reports it is set up.
  ApplianceProfile withSetup(SetupStatus setup) => copyWith(
    deviceName: setup.deviceName ?? deviceName,
    label: _labelFor(setup, address),
    initializedAt: setup.initialized ? setup.initializedAt : null,
  );

  /// The appliance was renamed (same `initializedAt`, new `deviceName`,
  /// plan §9.3): the label follows the new name.
  ApplianceProfile renamedTo(String deviceName) {
    final name = deviceName.trim();
    if (name.isEmpty) return this;
    return copyWith(deviceName: name, label: name);
  }

  /// The appliance reports `initialized: false` (plan §9.3): its fingerprint
  /// is gone until it is set up again, which sends the user to "Finish
  /// setup". Name and address stay, so the screen can still name it.
  ApplianceProfile asReset() => copyWith(initializedAt: null);

  static String _labelFor(SetupStatus setup, ApplianceAddress address) {
    final name = setup.deviceName?.trim();
    return name == null || name.isEmpty ? address.authority : name;
  }

  /// 128 random bits as hex.
  static String newProfileId([Random? random]) {
    final rng = random ?? Random.secure();
    return [for (var i = 0; i < 16; i++) rng.nextInt(256).toRadixString(16)]
        .map((b) => b.padLeft(2, '0'))
        .join();
  }
}
