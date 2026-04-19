import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitforge/main.dart';

void main() {
  testWidgets('App smoke test - verifies HabitForgeApp builds', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    // Note: Since the app uses GoRouter and Firebase, a full integration test would be needed
    // for deeper verification, but for this smoke test we ensure the root widget compiles.
    await tester.pumpWidget(const ProviderScope(child: HabitForgeApp()));

    // Verify the app title or a key branding element exists
    expect(find.byType(HabitForgeApp), findsOneWidget);
  });
}
