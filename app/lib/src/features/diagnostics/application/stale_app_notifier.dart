import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stale_app_notifier.g.dart';

/// Whether to show "Zaktualizuj aplikację" (plan §16 point 4): GI Core kept
/// sending responses this version cannot read (`StaleAppPolicy`). The user
/// may [dismiss] it for the rest of the app session.
@Riverpod(keepAlive: true)
class StaleAppNotifier extends _$StaleAppNotifier {
  var _dismissed = false;

  @override
  bool build() {
    final suggested = ref.watch(diagnosticsServiceProvider).updateSuggested;
    void update() => state = suggested.value && !_dismissed;
    suggested.addListener(update);
    ref.onDispose(() => suggested.removeListener(update));
    return suggested.value && !_dismissed;
  }

  void dismiss() {
    _dismissed = true;
    state = false;
  }
}
