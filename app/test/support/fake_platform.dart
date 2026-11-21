import 'package:gi_home/src/core/platform/app_settings_opener.dart';
import 'package:gi_home/src/core/platform/local_network_permission.dart';

/// Counts "Otwórz ustawienia" instead of opening the system settings.
final class FakeSettingsOpener implements AppSettingsOpener {
  int opened = 0;

  @override
  Future<bool> open() async {
    opened++;
    return true;
  }
}

/// A platform that answers the local network permission request with
/// [answer] (or throws [error]) and counts the requests.
final class FakePermissionBackend implements LocalNetworkPermissionBackend {
  new({required this.sdkInt, this.answer = .granted, this.error});

  final int? sdkInt;
  final LocalNetworkPermissionStatus answer;
  final Exception? error;
  int requests = 0;

  @override
  Future<int?> androidSdkInt() async => sdkInt;

  @override
  Future<LocalNetworkPermissionStatus> requestNearbyWifiDevices() async {
    requests++;
    if (error case final error?) throw error;
    return answer;
  }
}
