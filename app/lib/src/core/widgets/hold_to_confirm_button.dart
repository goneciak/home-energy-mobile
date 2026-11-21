import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// A button that acts only after being pressed and held for [holdDuration]
/// (plan §12.1). A short tap does nothing but show [hint]; releasing early
/// cancels. The fill shows the progress, and the label says what to do, so
/// colour is never the only signal.
///
/// Screen readers cannot hold, so the button is exposed as a plain button
/// whose activation calls [onAccessibleActivate] (typically a confirmation
/// dialog) instead.
class HoldToConfirmButton extends StatefulWidget {
  const new({
    required this.label,
    required this.icon,
    required this.onConfirmed,
    required this.onAccessibleActivate,
    this.hint,
    this.semanticsHint,
    this.holdDuration = defaultHoldDuration,
    super.key,
  });

  /// Plan §12.1: "przytrzymanie przez ok. 600 ms".
  static const defaultHoldDuration = Duration(milliseconds: 600);

  final String label;
  final IconData icon;

  /// Called once the hold completes; `null` disables the button.
  final VoidCallback? onConfirmed;

  /// The accessibility path (screen reader activation).
  final VoidCallback? onAccessibleActivate;

  /// Shown below the button after a short tap.
  final String? hint;

  /// Read by screen readers after the label.
  final String? semanticsHint;

  final Duration holdDuration;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  )..addStatusListener(_onStatus);

  bool _showHint = false;

  @override
  void didUpdateWidget(HoldToConfirmButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress.duration = widget.holdDuration;
    if (widget.onConfirmed == null) _progress.value = 0;
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _progress.value = 0;
    widget.onConfirmed?.call();
  }

  void _start() {
    if (widget.onConfirmed == null) return;
    setState(() => _showHint = false);
    _progress.forward(from: 0);
  }

  void _cancel({required bool showHint}) {
    if (!_progress.isAnimating) return;
    _progress.value = 0;
    if (showHint && widget.hint != null) setState(() => _showHint = true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final enabled = widget.onConfirmed != null;
    final color = enabled
        ? tokens.warning
        : scheme.onSurface.withValues(alpha: 0.38);
    final hint = widget.hint;
    final radius = BorderRadius.circular(tokens.radius * 0.75);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          container: true,
          button: true,
          enabled: enabled,
          label: widget.label,
          hint: widget.semanticsHint,
          onTap: enabled ? widget.onAccessibleActivate : null,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _start(),
              onTapUp: (_) => _cancel(showHint: true),
              onTapCancel: () => _cancel(showHint: false),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: color),
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _progress,
                            builder: (context, _) => FractionallySizedBox(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: _progress.value,
                              child: ColoredBox(
                                color: color.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(widget.icon, color: color, size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.label,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: enabled ? null : color),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showHint && hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              hint,
              key: const ValueKey('hold-hint'),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: tokens.textMuted),
            ),
          ),
      ],
    );
  }
}
