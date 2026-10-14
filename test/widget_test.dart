import 'package:flutter_test/flutter_test.dart';
import 'package:finance_maya/main.dart';

void main() {
  testWidgets('Pocketly shows its empty dashboard', (tester) async {
    await tester.pumpWidget(const PocketlyApp());

    expect(find.text('Pocketly'), findsOneWidget);
    expect(find.text('Upload transaction statement'), findsOneWidget);
    expect(find.text('\$0.00'), findsNWidgets(3));
  });
}
