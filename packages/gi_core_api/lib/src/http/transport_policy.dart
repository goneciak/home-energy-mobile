import 'dart:io' show InternetAddress, InternetAddressType;

/// Cleartext rule from plan §9.4: `http://` only inside the home network
/// (RFC 1918, link-local, loopback, unique-local IPv6, `*.local`); anything
/// else must use `https://`. Credentials and the refresh cookie never go to a
/// host that fails this policy, and https is never silently downgraded.
///
/// Decision on `10.0.2.2`: plan §9.4 lists it as allowed "in the dev flavor
/// only", but the Android emulator's alias for the host loopback lies inside
/// RFC 1918's 10.0.0.0/8, so this policy allows it in every flavor. That is
/// deliberate: a real home network may well use 10.0.2.x, and denying it in
/// beta or prod would lock such homes out. The policy therefore takes no
/// flavor input; dev-only conveniences (the `10.0.2.2:3000` preset) live in
/// the app's dev flavor instead.
abstract final class TransportPolicy {
  static bool allows(Uri uri) => switch (uri.scheme) {
    'https' => true,
    'http' => isHomeNetworkHost(uri.host),
    _ => false,
  };

  static bool isHomeNetworkHost(String rawHost) {
    final host = rawHost.toLowerCase().replaceAll(RegExp(r'^\[|\]$'), '');
    if (host == 'localhost' || host.endsWith('.local')) return true;
    final address = InternetAddress.tryParse(host);
    if (address == null) return false;
    if (address.isLoopback || address.isLinkLocal) return true;
    final bytes = address.rawAddress;
    if (address.type == InternetAddressType.IPv4) {
      return bytes[0] == 10 ||
          (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
          (bytes[0] == 192 && bytes[1] == 168);
    }
    // Unique local IPv6 fc00::/7.
    return (bytes[0] & 0xfe) == 0xfc;
  }
}
