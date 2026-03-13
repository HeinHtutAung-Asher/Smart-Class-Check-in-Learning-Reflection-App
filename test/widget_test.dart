import 'package:flutter_test/flutter_test.dart';

import 'package:smart_class_checkin/main.dart';

void main() {
  testWidgets('App loads smart class dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartClassCheckinApp());

    expect(find.text('Smart Class Check-in'), findsOneWidget);
    expect(find.text('Start Check-in'), findsOneWidget);
    expect(find.text('Finish Class'), findsNWidgets(2));
  });
}
