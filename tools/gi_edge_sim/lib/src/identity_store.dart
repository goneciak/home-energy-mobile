import 'dart:convert';
import 'dart:io';

/// What the firmware keeps in NVS: the credential, the one monotonic request
/// counter and the boot counter. It survives a simulated reboot.
class IdentityStore {
  new({this.path}) {
    _load();
  }

  final String? path;

  /// The Core device UUID (adopted from the activation response).
  String? deviceId;
  String? sharedSecret;
  int sequence = 0;
  int bootCount = 0;

  /// Set when the credential was wiped after repeated 401 answers: the device
  /// then tries `/edge/self-heal` with its MAC.
  bool selfHealArmed = false;

  bool get provisioned => deviceId != null && sharedSecret != null;

  /// Incremented before use, persisted, never reused.
  int reserveSequence() {
    sequence++;
    save();
    return sequence;
  }

  void adopt({required String deviceId, required String sharedSecret}) {
    this.deviceId = deviceId;
    this.sharedSecret = sharedSecret;
    selfHealArmed = false;
    save();
  }

  void wipeCredential() {
    sharedSecret = null;
    selfHealArmed = true;
    save();
  }

  /// Back to a blank device. The sequence is kept: it is never reused.
  void factoryReset() {
    deviceId = null;
    sharedSecret = null;
    selfHealArmed = false;
    save();
  }

  void save() {
    final target = path;
    if (target == null) return;
    final file = File(target)..parent.createSync(recursive: true);
    file.writeAsStringSync(
      jsonEncode({
        'deviceId': deviceId,
        'sharedSecret': sharedSecret,
        'sequence': sequence,
        'bootCount': bootCount,
        'selfHealArmed': selfHealArmed,
      }),
    );
  }

  void _load() {
    final source = path;
    if (source == null) return;
    final file = File(source);
    if (!file.existsSync()) return;
    try {
      final json = jsonDecode(file.readAsStringSync());
      if (json is! Map<String, Object?>) return;
      deviceId = json['deviceId'] as String?;
      sharedSecret = json['sharedSecret'] as String?;
      sequence = (json['sequence'] as int?) ?? 0;
      bootCount = (json['bootCount'] as int?) ?? 0;
      selfHealArmed = (json['selfHealArmed'] as bool?) ?? false;
    } on Object {
      // A corrupt file is a device with a blank NVS.
    }
  }
}
