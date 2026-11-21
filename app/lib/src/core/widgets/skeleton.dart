import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder of content that is still loading (plan §14): the blocks of
/// [child] ([SkeletonBlock]s, laid out like the content to come) gently fade
/// in and out, without a shimmer, and stand still when the system asks for
/// reduced motion.
///
/// Screen readers hear one "Ładowanie…" instead of the empty blocks.
class Skeleton extends StatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  /// One fade, from full to dim and back.
  static const period = Duration(milliseconds: 1600);

  /// Opacity at the dimmest point of the fade.
  static const minOpacity = 0.45;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Skeleton.period,
  );

  /// Built once: a [CurvedAnimation] listens to its parent until disposed.
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: 1,
    end: Skeleton.minOpacity,
  ).animate(_curve);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.commonLoading,
    container: true,
    excludeSemantics: true,
    child: FadeTransition(opacity: _opacity, child: widget.child),
  );
}

/// One placeholder block in the raised surface colour: a line of text
/// (the default height), a chip or a whole card.
class SkeletonBlock extends StatelessWidget {
  const new({super.key, this.width, this.height = 14, this.radius});

  /// A card-sized block, e.g. the place of a heating card.
  const new card({super.key, this.height = 120}) : width = null, radius = null;

  /// `null` fills the available width.
  final double? width;
  final double height;

  /// Defaults to a pill for lines and the card radius for taller blocks.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final radius = this.radius ?? (height > 32 ? tokens.radius : height / 2);
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceRaised,
          border: Border.all(color: tokens.textMuted.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
