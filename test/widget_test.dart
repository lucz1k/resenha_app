import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resenha_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Inicializa o app
    await tester.pumpWidget(MyApp());

    // Verifica se existe o número 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Clica no botão de adicionar
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica se o contador foi incrementado
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
