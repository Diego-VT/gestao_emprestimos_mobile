import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/status_style.dart';
import '../models/equipamento.dart';
import '../models/solicitacao.dart';
import '../models/usuario.dart';
import '../repositories/equipamento_repository.dart';
import '../repositories/solicitacao_repository.dart';
import '../repositories/usuario_repository.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  static const routeName = '/relatorios';

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  late Future<_RelatorioDados> _relatorioFuture;

  @override
  void initState() {
    super.initState();
    _relatorioFuture = _carregarRelatorio();
  }

  Future<_RelatorioDados> _carregarRelatorio() async {
    final solicitacoes = await SolicitacaoRepository().listar();
    final equipamentos = await EquipamentoRepository().listar();

    List<Usuario> usuarios = const [];
    try {
      usuarios = await UsuarioRepository().listarTodos();
    } catch (_) {
      usuarios = const [];
    }

    return _RelatorioDados(
      solicitacoes: solicitacoes,
      equipamentos: equipamentos,
      usuarios: usuarios,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios'), centerTitle: true),
      body: FutureBuilder<_RelatorioDados>(
        future: _relatorioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final dados = snapshot.data;
          if (dados == null) {
            return const Center(
              child: Text('Não foi possível carregar os relatórios.'),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ResumoGrid(dados: dados),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 760) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _SecaoStatus(dados: dados)),
                            const SizedBox(width: 16),
                            Expanded(child: _SecaoEquipamentos(dados: dados)),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _SecaoStatus(dados: dados),
                          const SizedBox(height: 16),
                          _SecaoEquipamentos(dados: dados),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _SecaoUsuarios(dados: dados),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResumoGrid extends StatelessWidget {
  const _ResumoGrid({required this.dados});

  final _RelatorioDados dados;

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      maxCrossAxisExtent: 240,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.65,
      children: [
        _IndicadorCard(
          titulo: 'Solicitações',
          valor: dados.solicitacoes.length.toString(),
          icone: Icons.assignment_outlined,
        ),
        _IndicadorCard(
          titulo: 'Pendentes',
          valor: dados.totalPorStatus('Pendente').toString(),
          icone: Icons.pending_actions_outlined,
        ),
        _IndicadorCard(
          titulo: 'Equipamentos',
          valor: dados.equipamentos.length.toString(),
          icone: Icons.devices_other,
        ),
        _IndicadorCard(
          titulo: 'Usuários',
          valor: dados.usuarios.isEmpty
              ? '-'
              : dados.usuarios.length.toString(),
          icone: Icons.people_outline,
        ),
      ],
    );
  }
}

class _SecaoStatus extends StatelessWidget {
  const _SecaoStatus({required this.dados});

  final _RelatorioDados dados;

  @override
  Widget build(BuildContext context) {
    final status = dados.statusOrdenados;

    return _Secao(
      titulo: 'Solicitações por Status',
      children: status.map((entry) {
        final style = StatusStyle.fromStatus(entry.key);
        return _LinhaRelatorio(
          titulo: entry.key,
          valor: entry.value.toString(),
          percentual: dados.percentual(entry.value, dados.solicitacoes.length),
          cor: style.color,
        );
      }).toList(),
    );
  }
}

class _SecaoEquipamentos extends StatelessWidget {
  const _SecaoEquipamentos({required this.dados});

  final _RelatorioDados dados;

  @override
  Widget build(BuildContext context) {
    final disponiveis = dados.equipamentos
        .where((equipamento) => equipamento.disponivel)
        .length;

    return _Secao(
      titulo: 'Equipamentos',
      children: [
        _LinhaRelatorio(
          titulo: 'Disponíveis',
          valor: disponiveis.toString(),
          percentual: dados.percentual(disponiveis, dados.equipamentos.length),
          cor: AppColors.completed,
        ),
        _LinhaRelatorio(
          titulo: 'Em manutenção',
          valor: (dados.equipamentos.length - disponiveis).toString(),
          percentual: dados.percentual(
            dados.equipamentos.length - disponiveis,
            dados.equipamentos.length,
          ),
          cor: AppColors.maintenance,
        ),
      ],
    );
  }
}

class _SecaoUsuarios extends StatelessWidget {
  const _SecaoUsuarios({required this.dados});

  final _RelatorioDados dados;

  @override
  Widget build(BuildContext context) {
    if (dados.usuarios.isEmpty) {
      return const _Secao(
        titulo: 'Usuários',
        children: [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Disponível apenas para administrador.'),
          ),
        ],
      );
    }

    final perfis = dados.perfisOrdenados;

    return _Secao(
      titulo: 'Usuários por perfil',
      children: perfis.map((entry) {
        return _LinhaRelatorio(
          titulo: entry.key,
          valor: entry.value.toString(),
          percentual: dados.percentual(entry.value, dados.usuarios.length),
          cor: AppColors.primary,
        );
      }).toList(),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _IndicadorCard extends StatelessWidget {
  const _IndicadorCard({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  final String titulo;
  final String valor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              valor,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              titulo,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaRelatorio extends StatelessWidget {
  const _LinhaRelatorio({
    required this.titulo,
    required this.valor,
    required this.percentual,
    required this.cor,
  });

  final String titulo;
  final String valor;
  final double percentual;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percentual.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: AppColors.neutralSoft,
                    valueColor: AlwaysStoppedAnimation<Color>(cor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatorioDados {
  const _RelatorioDados({
    required this.solicitacoes,
    required this.equipamentos,
    required this.usuarios,
  });

  final List<Solicitacao> solicitacoes;
  final List<Equipamento> equipamentos;
  final List<Usuario> usuarios;

  int totalPorStatus(String status) {
    return solicitacoes
        .where(
          (solicitacao) =>
              solicitacao.status.toLowerCase() == status.toLowerCase(),
        )
        .length;
  }

  double percentual(int valor, int total) {
    if (total == 0) {
      return 0;
    }
    return valor / total;
  }

  List<MapEntry<String, int>> get statusOrdenados {
    final contagem = <String, int>{};
    for (final solicitacao in solicitacoes) {
      contagem.update(
        solicitacao.status,
        (valor) => valor + 1,
        ifAbsent: () => 1,
      );
    }
    return contagem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  List<MapEntry<String, int>> get perfisOrdenados {
    final contagem = <String, int>{};
    for (final usuario in usuarios) {
      contagem.update(usuario.perfil, (valor) => valor + 1, ifAbsent: () => 1);
    }
    return contagem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }
}
