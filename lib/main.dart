import 'package:flutter/material.dart';

import 'core/utils/auth_gate.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detalhe_solicitacao_screen.dart';
import 'screens/login_screen.dart';
import 'screens/nova_solicitacao_screen.dart';
import 'screens/solicitacoes_screen.dart';

void main() {
  runApp(const GestaoEmprestimosApp());
}

class GestaoEmprestimosApp extends StatelessWidget {
  const GestaoEmprestimosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestao de Emprestimos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const AuthGate(),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
        SolicitacoesScreen.routeName: (context) => const SolicitacoesScreen(),
        NovaSolicitacaoScreen.routeName: (context) =>
            const NovaSolicitacaoScreen(),
        DetalheSolicitacaoScreen.routeName: (context) =>
            const DetalheSolicitacaoScreen(),
      },
    );
  }
}
