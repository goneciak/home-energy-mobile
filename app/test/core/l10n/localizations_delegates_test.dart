import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<BuildContext> pumpApp(WidgetTester tester, Locale locale) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    return context;
  }

  testWidgets('material_ui widgets get Polish strings', (tester) async {
    final context = await pumpApp(tester, const Locale('pl'));

    expect(MaterialLocalizations.of(context).backButtonTooltip, 'Wstecz');
    expect(context.l10n.localeName, 'pl');
  });

  testWidgets('material_ui widgets get English strings', (tester) async {
    final context = await pumpApp(tester, const Locale('en'));

    expect(MaterialLocalizations.of(context).backButtonTooltip, 'Back');
    expect(context.l10n.localeName, 'en');
  });
}
