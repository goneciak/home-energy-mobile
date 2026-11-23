import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gi_home/src/core/platform/gi_platform_channel.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:multicast_dns/multicast_dns.dart';

/// Looks up the IPv4 address that answers to a `.local` `name` over
/// multicast DNS, or `null` when nobody answers within `timeout`.
///
/// The seam between `MulticastDnsHostResolver` and the `multicast_dns`
/// package, so tests need no network.
abstract interface class MdnsAddressLookup {
  Future<String?> lookupIpv4(String name, {required Duration timeout});
}

/// The `multicast_dns` package: one client per lookup, stopped afterwards,
/// with Android's Wi-Fi multicast lock held meanwhile.
final class PackageMdnsAddressLookup implements MdnsAddressLookup {
  const new();

  @override
  Future<String?> lookupIpv4(String name, {required Duration timeout}) async {
    await _multicastLock('acquireMulticastLock');
    final client = MDnsClient();
    try {
      await client.start();
      final records = client.lookup<IPAddressResourceRecord>(
        ResourceRecordQuery.addressIPv4(name),
        timeout: timeout,
      );
      await for (final record in records) {
        return record.address.address;
      }
      return null;
    } finally {
      client.stop();
      await _multicastLock('releaseMulticastLock');
    }
  }

  static Future<void> _multicastLock(String method) async {
    try {
      await giPlatformChannel.invokeMethod<Object?>(method);
    } on PlatformException {
      // Best effort: the lookup then tries without the lock.
    } on MissingPluginException {
      // Not Android.
    }
  }
}

/// The fallback behind the `mdnsFallback` feature flag: resolves a `.local`
/// name by asking the local network itself, for phones whose system resolver
/// does not (spike S3, Android only). It returns the IP address it found,
/// since the system cannot resolve the name, and is consulted only after
/// [SystemHostResolver] gave up (see [FirstHostResolver]).
///
/// Whatever it finds is only a candidate: the connection ladder confirms it
/// by `/health/live` and the setup fingerprint before it is trusted. Only
/// reads are sent. Needs `CHANGE_WIFI_MULTICAST_STATE` on Android.
final class MulticastDnsHostResolver implements HostResolver {
  const new({
    this.lookup = const PackageMdnsAddressLookup(),
    this.timeout = const Duration(seconds: 2),
  });

  final MdnsAddressLookup lookup;

  /// How long a name may take to answer.
  final Duration timeout;

  @override
  Future<String?> resolve(String name) async {
    if (!name.endsWith('.local')) return null;
    try {
      // The outer timeout also bounds a client that never starts.
      final address = await lookup
          .lookupIpv4(name, timeout: timeout)
          .timeout(timeout + const Duration(seconds: 1));
      return address != null && isLocalNetworkIpv4(address) ? address : null;
    } on TimeoutException {
      return null;
    }
  }
}

/// Whether [address] is an IPv4 address of a local network: private
/// (10/8, 172.16/12, 192.168/16) or link-local (169.254/16). An answer
/// from anywhere else is not an appliance on this network and is dropped,
/// so the ladder never probes (or later talks cleartext to) a public host.
bool isLocalNetworkIpv4(String address) {
  final parts = address.split('.');
  if (parts.length != 4) return false;
  final octets = parts.map(int.tryParse).toList();
  if (octets.any((o) => o == null || o < 0 || o > 255)) return false;
  final [a, b, ...] = octets.cast<int>();
  return a == 10 ||
      (a == 172 && b >= 16 && b <= 31) ||
      (a == 192 && b == 168) ||
      (a == 169 && b == 254);
}
