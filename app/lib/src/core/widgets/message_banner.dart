import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

enum MessageTone { info, warning, error }

/// Inline message with an icon, so colour is never the only signal
/// (plan §12.9). The [message] is announced to screen readers as a live
/// region; the [detail] is not, so it may change without re-announcing.
class MessageBanner extends StatelessWidget {
  const new({
    required this.message,
    super.key,
    this.tone = MessageTone.error,
    this.detail,
    this.monospaceDetail = false,
    this.action,
  });

  final String message;
  final MessageTone tone;

  /// Secondary line, e.g. the request id of a server error or a countdown.
  final String? detail;

  /// Sets [detail] in the mono font, for a technical value such as a request
  /// id that the user may read out or copy (plan §14).
  final bool monospaceDetail;

  /// A button below the text, e.g. "Otwórz ustawienia" (plan §9.4).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final (color, icon) = switch (tone) {
      MessageTone.info => (tokens.teal, Icons.info_outline),
      MessageTone.warning => (tokens.warning, Icons.warning_amber_rounded),
      MessageTone.error => (tokens.danger, Icons.error_outline),
    };
    final textTheme = Theme.of(context).textTheme;
    final detail = this.detail;
    final action = this.action;
    final detailStyle = textTheme.bodySmall?.copyWith(color: tokens.textMuted);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(tokens.radius * 0.75),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    liveRegion: true,
                    child: Text(message, style: textTheme.bodyMedium),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 4),
                    SelectableText(
                      detail,
                      style: monospaceDetail
                          ? GiFonts.monospace(detailStyle)
                          : detailStyle,
                    ),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: action,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
