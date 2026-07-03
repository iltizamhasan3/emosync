import 'package:flutter_test/flutter_test.dart';

import 'package:emosync_app/main.dart';

void main() {
  testWidgets('App should display login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EmoSyncApp());

    // Verify login screen elements
    expect(find.text('EmoSync'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Belum punya akun? '), findsOneWidget);
  });
}