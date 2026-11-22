import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:meta/meta.dart';

/// The last good `GET /devices` list of one user of one appliance, kept
/// across restarts (plan §8.3, G1, G3): a cold start without a connection
/// shows it read-only, with its age.
@immutable
final class DeviceSnapshot {
  const new({required this.userId, required this.devices});

  /// Throws [FormatException] (or a type error) for anything else.
  factory fromJson(Map<String, Object?> json) {
    if (json['v'] != _version) throw const FormatException('version');
    return DeviceSnapshot(
      userId: json['userId']! as String,
      devices: Fetched(
        List.unmodifiable([
          for (final device in json['devices']! as List<Object?>)
            DeviceListItem.fromJson(device! as Map<String, Object?>),
        ]),
        DateTime.parse(json['savedAt']! as String).toLocal(),
      ),
    );
  }

  final String userId;

  /// The list and when it arrived (phone clock).
  final Fetched<List<DeviceListItem>> devices;

  static const _version = 1;

  Map<String, Object?> toJson() => {
    'v': _version,
    'userId': userId,
    'savedAt': devices.fetchedAt.toUtc().toIso8601String(),
    'devices': [for (final device in devices.value) device.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is DeviceSnapshot &&
      other.userId == userId &&
      other.devices == devices;

  @override
  int get hashCode => Object.hash(userId, devices);
}

/// Where [DeviceSnapshot]s live, per appliance profile and user. Every
/// method never throws: a storage failure only means no snapshot.
abstract interface class DeviceSnapshotStore {
  Future<DeviceSnapshot?> read({
    required String profileId,
    required String userId,
  });

  Future<void> write(String profileId, DeviceSnapshot snapshot);

  /// Removes the snapshots of every user of [profileId] (logout, user
  /// change, forgotten or replaced appliance, lost session).
  Future<void> wipe(String profileId);
}

/// [DeviceSnapshotStore] in secure storage, i.e. encrypted at rest by the
/// Keychain (iOS, this device only, never synced) or the Keystore-backed
/// cipher (Android), like the session (plan §7.1, §8.3). Nothing goes to
/// plain files or preferences.
final class SecureDeviceSnapshotStore implements DeviceSnapshotStore {
  const new(this._storage);

  final FlutterSecureStorage _storage;

  /// Prefix of every snapshot key of [profileId].
  static String prefixFor(String profileId) => 'p/$profileId/snap/';

  static String keyFor(String profileId, String userId) =>
      '${prefixFor(profileId)}$userId';

  @override
  Future<DeviceSnapshot?> read({
    required String profileId,
    required String userId,
  }) async {
    final key = keyFor(profileId, userId);
    final String? raw;
    try {
      raw = await _storage.read(key: key);
    } on Object {
      return null;
    }
    if (raw == null) return null;
    try {
      final snapshot = DeviceSnapshot.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
      return snapshot.userId == userId ? snapshot : null;
    } on Object {
      // Unreadable (an older app version, a model change): useless.
      await _delete(key);
      return null;
    }
  }

  @override
  Future<void> write(String profileId, DeviceSnapshot snapshot) async {
    try {
      await _storage.write(
        key: keyFor(profileId, snapshot.userId),
        value: jsonEncode(snapshot.toJson()),
      );
    } on Object {
      // Best effort: the next good list tries again.
    }
  }

  @override
  Future<void> wipe(String profileId) async {
    final prefix = prefixFor(profileId);
    try {
      final all = await _storage.readAll();
      for (final key in all.keys) {
        if (key.startsWith(prefix)) await _delete(key);
      }
    } on Object {
      // Secure storage unavailable; the entries are scoped to this profile
      // and user and are never shown to anyone else.
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on Object {
      // See [wipe].
    }
  }
}

/// [DeviceSnapshotStore] in memory: demo mode (nothing real is stored) and
/// tests.
final class MemoryDeviceSnapshotStore implements DeviceSnapshotStore {
  final Map<String, DeviceSnapshot> entries = {};

  @override
  Future<DeviceSnapshot?> read({
    required String profileId,
    required String userId,
  }) async => entries[SecureDeviceSnapshotStore.keyFor(profileId, userId)];

  @override
  Future<void> write(String profileId, DeviceSnapshot snapshot) async =>
      entries[SecureDeviceSnapshotStore.keyFor(profileId, snapshot.userId)] =
          snapshot;

  @override
  Future<void> wipe(String profileId) async => entries.removeWhere(
    (key, _) => key.startsWith(SecureDeviceSnapshotStore.prefixFor(profileId)),
  );
}
