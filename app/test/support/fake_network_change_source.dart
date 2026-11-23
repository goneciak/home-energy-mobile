import 'dart:async';

import 'package:gi_home/src/core/platform/network_change_source.dart';

/// A [NetworkChangeSource] the test drives by hand.
final class FakeNetworkChangeSource implements NetworkChangeSource {
  final _controller = StreamController<NetworkState>.broadcast();

  @override
  Stream<NetworkState> get changes => _controller.stream;

  void emit(NetworkState state) => _controller.add(state);

  /// Wi-Fi to mobile data.
  void wifiToMobile() => emit(const NetworkState({NetworkKind.mobile}));

  /// Another Wi-Fi network (a platform that can tell reports its identity).
  void wifiToOtherWifi([String identity = 'other-ssid']) =>
      emit(NetworkState(const {NetworkKind.wifi}, identity: identity));

  /// Offline to Wi-Fi.
  void noneToWifi() => emit(const NetworkState({NetworkKind.wifi}));

  void goOffline() => emit(NetworkState.none);

  Future<void> close() => _controller.close();
}
