import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

/// The connectivity plug-in for tests that run the whole app: always on
/// Wi-Fi, never changing, no platform channel involved.
final class QuietConnectivity extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.wifi,
  ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}
