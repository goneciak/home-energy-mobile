import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/open_app_settings_button.dart';
import 'package:material_ui/material_ui.dart';

/// Explains why shown data may not be current (plan §8.3, §11):
///
/// * the latest refresh failed → "Brak połączenia z GI Home · dane z 07:41"
///   (or the failure reason for other errors), on top of the last good data;
/// * the data is older than its freshness limit → "Dane mogą być
///   nieaktualne (ostatnia aktualizacja 07:41)".
///
/// Renders nothing when the data is current.
class FreshnessBanner extends StatelessWidget {
  const new({
    required this.fetchedAt,
    required this.error,
    required this.isStale,
    required this.now,
    super.key,
  });

  /// When the shown data arrived.
  final DateTime fetchedAt;

  /// Error of the latest refresh, if it failed.
  final Object? error;

  final bool isStale;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final time = formatClockTime(l10n, fetchedAt, now);
    final error = this.error;
    if (error != null) {
      final unreachable =
          error is UnreachableFailure || error is TimeoutFailure;
      return MessageBanner(
        tone: MessageTone.warning,
        message: unreachable
            ? l10n.offlineBannerSince(time)
            : l10n.refreshFailedBanner(time),
        detail: unreachable ? null : failureMessage(l10n, error),
        action: failureAction(error),
      );
    }
    if (isStale) {
      return MessageBanner(
        tone: MessageTone.warning,
        message: l10n.staleDataBanner(time),
      );
    }
    return const SizedBox.shrink();
  }
}
