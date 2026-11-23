import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/platform/network_change_source.dart';

final class _FakeConnectivity extends ConnectivityPlatform {
  new(this.initial);

  List<ConnectivityResult> initial;
  Object? checkFailure;
  final controller = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    // A test double throws whatever the scenario sets.
    // ignore: only_throw_errors
    if (checkFailure case final failure?) throw failure;
    return initial;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      controller.stream;
}

void main() {
  late _FakeConnectivity platform;

  setUp(() {
    platform = _FakeConnectivity([ConnectivityResult.wifi]);
    ConnectivityPlatform.instance = platform;
    addTearDown(platform.controller.close);
  });

  Future<List<NetworkState>> collect(Future<void> Function() emit) async {
    final seen = <NetworkState>[];
    final subscription = ConnectivityNetworkChangeSource().changes.listen(
      seen.add,
    );
    await pumpEventQueue();
    await emit();
    await pumpEventQueue();
    await subscription.cancel();
    return seen;
  }

  test('reports only changes, never the state at the start', () async {
    final seen = await collect(() async {});

    expect(seen, isEmpty);
  });

  test('Wi-Fi to mobile data is a change', () async {
    final seen = await collect(
      () async => platform.controller.add([ConnectivityResult.mobile]),
    );

    expect(seen, [
      const NetworkState({NetworkKind.mobile}),
    ]);
  });

  test('the same state reported again is not a change', () async {
    final seen = await collect(() async {
      platform.controller
        ..add([ConnectivityResult.wifi])
        ..add([ConnectivityResult.wifi]);
    });

    expect(seen, isEmpty);
  });

  test('offline and back is two changes', () async {
    final seen = await collect(() async {
      platform.controller
        ..add([ConnectivityResult.none])
        ..add([ConnectivityResult.wifi, ConnectivityResult.vpn]);
    });

    expect(seen, [
      NetworkState.none,
      const NetworkState({NetworkKind.wifi, NetworkKind.vpn}),
    ]);
    expect(seen.first.isConnected, isFalse);
  });

  test('an unknown start counts the first event as a change', () async {
    platform.checkFailure = StateError('unavailable');

    final seen = await collect(
      () async => platform.controller.add([ConnectivityResult.wifi]),
    );

    expect(seen, [
      const NetworkState({NetworkKind.wifi}),
    ]);
  });

  test('other kinds are mapped, and an empty report means offline', () async {
    final seen = await collect(() async {
      platform.controller
        ..add([ConnectivityResult.ethernet, ConnectivityResult.bluetooth])
        ..add(const []);
    });

    expect(seen, [
      const NetworkState({NetworkKind.ethernet, NetworkKind.other}),
      NetworkState.none,
    ]);
  });

  test('the placeholder source never reports', () async {
    expect(await const NoNetworkChangeSource().changes.toList(), isEmpty);
  });
}
