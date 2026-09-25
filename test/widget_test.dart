import 'package:flutter_test/flutter_test.dart';
import 'package:mobquebracodigo/main.dart';

void main() {
  testWidgets('App inicia na HomePage', (tester) async {
    await tester.pumpWidget(const QuebraCodigoApp());
    expect(find.byType(QuebraCodigoApp), findsOneWidget);
  });
}
