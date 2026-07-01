import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/auth_gate.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detalhe_solicitacao_screen.dart';
import 'screens/login_screen.dart';
import 'screens/nova_solicitacao_screen.dart';
import 'screens/relatorios_screen.dart';
import 'screens/solicitacoes_screen.dart';
import 'screens/usuarios_screen.dart';

void main() {
  runApp(const GestaoEmprestimosApp());
}

class GestaoEmprestimosApp extends StatelessWidget {
  const GestaoEmprestimosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Empréstimos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
        SolicitacoesScreen.routeName: (context) => const SolicitacoesScreen(),
        NovaSolicitacaoScreen.routeName: (context) =>
            const NovaSolicitacaoScreen(),
        DetalheSolicitacaoScreen.routeName: (context) =>
            const DetalheSolicitacaoScreen(),
        RelatoriosScreen.routeName: (context) => const RelatoriosScreen(),
        UsuariosScreen.routeName: (context) => const UsuariosScreen(),
      },
    );
  }
}
