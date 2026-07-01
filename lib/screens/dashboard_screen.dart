import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import 'login_screen.dart';
import 'nova_solicitacao_screen.dart';
import 'relatorios_screen.dart';
import 'solicitacoes_screen.dart';
import 'usuarios_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Inicial'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => _sair(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth;
          final colunas = largura >= 1000
              ? 4
              : largura >= 640
              ? 3
              : 2;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: colunas,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: largura >= 640 ? 1.25 : 1.05,
                children: [
                  _MenuItem(
                    titulo: 'Solicitacoes',
                    icone: Icons.assignment_outlined,
                    onTap: () => Navigator.pushNamed(
                      context,
                      SolicitacoesScreen.routeName,
                    ),
                  ),
                  _MenuItem(
                    titulo: 'Nova Solicitacao',
                    icone: Icons.add_box_outlined,
                    onTap: () => Navigator.pushNamed(
                      context,
                      NovaSolicitacaoScreen.routeName,
                    ),
                  ),
                  _MenuItem(
                    titulo: 'Relatorios',
                    icone: Icons.bar_chart_outlined,
                    onTap: () => Navigator.pushNamed(
                      context,
                      RelatoriosScreen.routeName,
                    ),
                  ),
                  _MenuItem(
                    titulo: 'Usuarios',
                    icone: Icons.people_outline,
                    onTap: () =>
                        Navigator.pushNamed(context, UsuariosScreen.routeName),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sair(BuildContext context) async {
    await AuthRepository().logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.titulo,
    required this.icone,
    required this.onTap,
  });

  final String titulo;
  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icone,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
