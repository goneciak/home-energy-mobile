import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Heading of a list section, announced as a header to screen readers.
class SectionHeader extends StatelessWidget {
  const new(this.title, {super.key, this.padding});

  final String title;

  /// Defaults to list-tile insets with extra space above.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding ?? const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: GiTokens.of(context).ember),
      ),
    ),
  );
}
