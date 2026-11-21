import 'dart:async';
import 'dart:io';

/// Turns a `.local` name into the host to probe (plan §9.2, step 2).
///
/// Returns the host to put in `http://<host>`, or `null` when the name does
/// not resolve. It may throw; the ladder treats that as "not found".
///
/// This is the extension point for the `multicast_dns` fallback on Android
/// (spike S3): such a resolver returns the IP address it found, since the
/// system cannot resolve the name itself, and is chained after the system
/// one with [FirstHostResolver].
abstract interface class HostResolver {
  Future<String?> resolve(String name);
}

/// Signature of [InternetAddress.lookup], injectable for tests.
typedef AddressLookup = Future<List<InternetAddress>> Function(String host);

/// The operating system's resolver (iOS resolves `.local` names through
/// mDNS itself; on Android support depends on the version and vendor, S3).
/// A name that resolves is probed by name, so the system keeps resolving
/// it for every request.
final class SystemHostResolver implements HostResolver {
  const new({
    this.timeout = const Duration(seconds: 2),
    this._lookup = InternetAddress.lookup,
  });

  /// How long one name may take; an unanswered `.local` query otherwise
  /// waits for the system's own, much longer timeout.
  final Duration timeout;
  final AddressLookup _lookup;

  @override
  Future<String?> resolve(String name) async {
    try {
      final addresses = await _lookup(name).timeout(timeout);
      return addresses.isEmpty ? null : name;
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    }
  }
}

/// Asks each resolver in turn until one resolves the name; a resolver that
/// throws counts as "not resolved".
final class FirstHostResolver implements HostResolver {
  const new(this.resolvers);

  final List<HostResolver> resolvers;

  @override
  Future<String?> resolve(String name) async {
    for (final resolver in resolvers) {
      try {
        final host = await resolver.resolve(name);
        if (host != null) return host;
      } on Object {
        // Try the next one.
      }
    }
    return null;
  }
}

/// Resolves a fixed set of names to themselves: the dev flavor's mock Core
/// (everything answers there) and tests.
final class StaticHostResolver implements HostResolver {
  const new(this.names);

  final Set<String> names;

  @override
  Future<String?> resolve(String name) async =>
      names.contains(name) ? name : null;
}
