import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_change_source.g.dart';

/// The kind of network the phone is on.
enum NetworkKind { wifi, mobile, ethernet, vpn, other, none }

/// What the phone is connected to after a change.
@immutable
final class NetworkState {
  const new(this.kinds, {this.identity});

  /// Not connected to anything.
  static const none = NetworkState({NetworkKind.none});

  /// The active kinds (a phone may be on Wi-Fi and a VPN at once).
  final Set<NetworkKind> kinds;

  /// Which network of that kind (an SSID or gateway), when the platform
  /// tells. The real source cannot: connectivity only reports the kind, so a
  /// move between two Wi-Fi networks is caught by the return to the
  /// foreground instead.
  final String? identity;

  bool get isConnected => !kinds.contains(NetworkKind.none);

  @override
  bool operator ==(Object other) =>
      other is NetworkState &&
      other.identity == identity &&
      setEquals(other.kinds, kinds);

  @override
  int get hashCode => Object.hash(identity, Object.hashAllUnordered(kinds));

  @override
  String toString() =>
      'NetworkState(${kinds.map((k) => k.name).join('+')}'
      '${identity == null ? '' : ', $identity'})';
}

/// Tells when the phone moved to another network (Wi-Fi to mobile, another
/// Wi-Fi, back online). Only changes are emitted, never the state at
/// subscription time. Behind an interface so tests drive it by hand.
abstract interface class NetworkChangeSource {
  Stream<NetworkState> get changes;
}

/// `connectivity_plus`: emits when the set of active network kinds changes.
final class ConnectivityNetworkChangeSource implements NetworkChangeSource {
  new([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<NetworkState> get changes {
    StreamSubscription<List<ConnectivityResult>>? subscription;
    late final StreamController<NetworkState> controller;
    controller = StreamController<NetworkState>(
      onListen: () {
        NetworkState? previous;
        // The first report waits for the state at the start, so it is
        // compared with it; without it (unknown) it counts as a change.
        final started = _connectivity.checkConnectivity().then<void>(
          (results) => previous = _stateOf(results),
          onError: (Object _) {},
        );
        subscription = _connectivity.onConnectivityChanged.listen((
          results,
        ) async {
          await started;
          final next = _stateOf(results);
          if (next == previous || controller.isClosed) return;
          previous = next;
          controller.add(next);
        }, onError: controller.addError);
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  static NetworkState _stateOf(List<ConnectivityResult> results) {
    final kinds = {
      for (final result in results)
        switch (result) {
          ConnectivityResult.wifi => NetworkKind.wifi,
          ConnectivityResult.mobile => NetworkKind.mobile,
          ConnectivityResult.ethernet => NetworkKind.ethernet,
          ConnectivityResult.vpn => NetworkKind.vpn,
          ConnectivityResult.none => NetworkKind.none,
          _ => NetworkKind.other,
        },
    };
    return kinds.isEmpty ? NetworkState.none : NetworkState(kinds);
  }
}

/// A source that never changes: demo mode, the dev mock and anywhere the
/// platform has no connectivity service.
final class NoNetworkChangeSource implements NetworkChangeSource {
  const new();

  @override
  Stream<NetworkState> get changes => const Stream.empty();
}

@Riverpod(keepAlive: true)
NetworkChangeSource networkChangeSource(Ref ref) =>
    ConnectivityNetworkChangeSource();
