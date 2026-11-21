import 'package:gi_core_api/src/models/enums.dart';

enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  String get verb => name.toUpperCase();
}

/// Timeout classes from plan §6.6.
enum TimeoutClass {
  /// Default GET: 4 s connect, 10 s receive.
  read(Duration(seconds: 4), Duration(seconds: 10)),

  /// POST/PATCH/DELETE: 4 s / 15 s.
  write(Duration(seconds: 4), Duration(seconds: 15)),

  /// `/auth/refresh`: 4 s / 30 s, never cancelled.
  refresh(Duration(seconds: 4), Duration(seconds: 30)),

  /// LAN probe on the connect screen: 1.5 s / 2 s.
  probe(Duration(milliseconds: 1500), Duration(seconds: 2));

  new(this.connect, this.receive);

  final Duration connect;
  final Duration receive;
}

/// Plan milestone (§20) whose screens first need an endpoint. Documentation
/// metadata: `docs/backend-contract.md` is generated from it.
enum Milestone {
  m1,
  m2,
  m3,
  m4;

  String get label => name.toUpperCase();
}

/// One GI Core operation. The catalog drives role gating, timeouts and the
/// retry policy (plan §6.2).
final class Endpoint {
  const new({
    required this.id,
    required this.method,
    required this.path,
    required this.roles,
    required this.timeout,
    required this.milestone,
    required this.feature,
    this.maxRetries = 0,
    this.refreshCookie = false,
  }) : assert(
         maxRetries == 0 || method == HttpMethod.get,
         'Only idempotent reads may be retried automatically.',
       );

  /// Nest operation id (`Controller_method`), used in diagnostics.
  final String id;
  final HttpMethod method;

  /// Path relative to `/api/v1`, with `{name}` placeholders.
  final String path;

  /// Roles allowed to call the endpoint; empty for public endpoints.
  final Set<UserRole> roles;
  final TimeoutClass timeout;

  /// Automatic retries after transient failures (GET only). Writes are never
  /// retried, apart from the single replay after a 401 refresh.
  final int maxRetries;

  /// Authenticated by the httpOnly refresh cookie (`Cookie:
  /// gi_refresh_token=…`) instead of a Bearer token. Only `/auth/refresh`.
  final bool refreshCookie;

  /// First milestone that needs the endpoint (documentation metadata).
  final Milestone milestone;

  /// The app feature that calls it, e.g. `connect`, `auth`, `home`
  /// (documentation metadata, plan §4.1).
  final String feature;

  bool get isPublic => roles.isEmpty;

  /// Whether a Bearer token is attached and a 401 triggers one refresh.
  bool get requiresAuth => !isPublic;

  bool get isIdempotent => method == HttpMethod.get;

  /// Whether a user with [role] may call this endpoint (`can()` gating).
  bool allows(UserRole role) => isPublic || roles.contains(role);

  /// [path] with placeholders replaced by URL-encoded [params].
  String resolvePath([Map<String, String> params = const {}]) {
    final resolved = path.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
      final value = params[match[1]];
      if (value == null || value.isEmpty) {
        throw ArgumentError.value(params, 'params', 'missing ${match[1]}');
      }
      return Uri.encodeComponent(value);
    });
    return resolved;
  }

  @override
  String toString() => 'Endpoint($id ${method.verb} $path)';
}
