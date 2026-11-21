import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

/// GI Core answered `HTTP_403`: the signed-in role may not see this data
/// (plan §7.5, §14). Unlike [ErrorState] there is no "Try again": the same
/// request could only fail again, so the screen offers at most a way out
/// ([action], e.g. back to Home) and says whom to ask. The GI Core client
/// already reloads `/auth/me` after a 403, so a changed role reaches
/// routing and Settings by itself.
class PermissionState extends StatelessWidget {
  const new({super.key, this.error, this.action});

  /// The 403, for its support request id; optional.
  final Object? error;

  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = this.error;
    final requestId = error == null ? null : failureRequestIdLine(l10n, error);
    return Semantics(
      liveRegion: true,
      child: EmptyState(
        icon: Icons.lock_outline,
        title: l10n.permissionDeniedTitle,
        body: [l10n.permissionDeniedBody, ?requestId].join('\n\n'),
        action: action,
      ),
    );
  }
}
