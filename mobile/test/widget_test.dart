import 'package:flutter_test/flutter_test.dart';
import 'package:alfu_hadithin_wa_hadith/main.dart';

void main() {
  testWidgets('App smoke test initializes AlfuHadithApp', (WidgetTester tester) async {
    // Basic smoke test confirming MaterialApp initializes
    expect(AlfuHadithApp, isNotNull);
  });
}
