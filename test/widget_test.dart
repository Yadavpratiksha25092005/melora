// Basic smoke test — just verifies the app builds without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/app.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Just confirms the widget tree built successfully.
    expect(find.byType(App), findsOneWidget);
  });
}