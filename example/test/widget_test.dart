import 'package:drawer_rail_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example renders the drawer and default page', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    // The header logo and a couple of entries are visible.
    expect(find.text('drawer_rail'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
  });
}
