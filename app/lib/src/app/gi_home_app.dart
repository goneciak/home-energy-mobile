import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/app/router/app_router.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/demo/presentation/demo_banner_host.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/diagnostics/presentation/stale_app_banner.dart';
import 'package:material_ui/material_ui.dart';

class GiHomeApp extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<GiHomeApp> createState() => _GiHomeAppState();
}

class _GiHomeAppState extends ConsumerState<GiHomeApp> {
  ProviderSubscription<RouteGuardState>? _coldStart;
  late final AppForeground _foreground;

  @override
  void initState() {
    super.initState();
    _foreground = ref.read(appForegroundProvider)
      ..addListener(_onForegroundChanged);
    // Kept alive: requests follow the app language from now on.
    ref.read(syncedRequestLanguageProvider);
    _watchColdStart();
  }

  /// The cold start is measured up to the Home condition (Home reports it,
  /// plan §1.1 G1). Once the stored session is no longer being restored,
  /// a start that does not lead to Home is not a sample.
  void _watchColdStart() {
    final meter = ref.read(coldStartMeterProvider);
    if (!meter.isMeasuring) return;
    if (!_foreground.value) {
      meter.abandon();
      return;
    }
    var settled = false;
    void stopListening() {
      _coldStart?.close();
      _coldStart = null;
    }

    _coldStart = ref.listenManual(routeGuardStateProvider, (_, guard) {
      if (settled) return;
      final leadsElsewhere =
          !guard.hasProfile ||
          !guard.applianceInitialized ||
          guard.session == SessionPhase.restoreFailed ||
          guard.session == SessionPhase.signedOut ||
          (guard.session == SessionPhase.signedIn && guard.mustChangePassword);
      if (leadsElsewhere) meter.abandon();
      if (guard.session == SessionPhase.restoring && !leadsElsewhere) return;
      settled = true;
      stopListening();
    }, fireImmediately: true);
    // With fireImmediately the first call runs before the assignment above.
    if (settled) stopListening();
  }

  /// In the background the OS may end the app without notice: pending
  /// diagnostics are written now (plan §8.4), and a cold start not yet at
  /// Home is no sample any more.
  void _onForegroundChanged() {
    if (_foreground.value) return;
    ref.read(coldStartMeterProvider).abandon();
    unawaited(ref.read(diagnosticsServiceProvider).flush());
  }

  @override
  void dispose() {
    _foreground.removeListener(_onForegroundChanged);
    _coldStart?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.dark();
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      // The phone language until the signed-in user's profile names one.
      locale: ref.watch(appLocaleProvider),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(goRouterProvider),
      builder: (context, child) => StaleAppBannerHost(
        child: DemoBannerHost(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
