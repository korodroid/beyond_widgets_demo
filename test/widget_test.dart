import 'package:flutter_test/flutter_test.dart';

import 'package:beyond_widgets_demo/main.dart';
import 'package:beyond_widgets_demo/home/home_screen.dart';
import 'package:beyond_widgets_demo/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Home screen lists all six demo topics', (tester) async {
    await tester.pumpWidget(const BeyondWidgetsApp());
    await tester.pumpAndSettle();

    final l10n =
        AppLocalizations.of(tester.element(find.byType(HomeScreen)))!;

    expect(find.text(l10n.appTitle), findsOneWidget);
    for (final entry in buildDemoEntries(l10n)) {
      expect(find.text(entry.title), findsOneWidget);
    }
  });
}
