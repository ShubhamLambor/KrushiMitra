// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_mitra/main.dart';

void main() {
  testWidgets('App loads successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KrushiMitraApp());

    // Verify that the KrushiMitraApp widget is mounted properly.
    expect(find.byType(KrushiMitraApp), findsOneWidget);
  });
}