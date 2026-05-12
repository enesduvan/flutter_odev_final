import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_odev_final/main.dart';

void main() {
  testWidgets('Ana ekran baslik ve gorev ekle butonu gorunur', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Görev Hatırlatıcı'), findsOneWidget);
    expect(find.text('Görev Ekle'), findsOneWidget);
  });
}
