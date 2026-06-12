import 'package:flutter_test/flutter_test.dart';
import 'package:emprestimo_equipamentos_mobile/main.dart';

void main() {
  testWidgets('exibe tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const GestaoEmprestimosApp());

    expect(find.text('Gestao de Emprestimos'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
