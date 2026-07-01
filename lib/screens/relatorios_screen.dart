import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Relatorios')),
      body: FutureBuilder<_RelatorioDados>(
        future: _relatorioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final dados = snapshot.data;
          if (dados == null) {
            return const Center(
              child: Text('Nao foi possivel carregar os relatorios.'),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _ResumoGrid(dados: dados),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 760) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _SecaoStatus(dados: dados)),
                            const SizedBox(width: 12),
                            Expanded(child: _SecaoEquipamentos(dados: dados)),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _SecaoStatus(dados: dados),
                          const SizedBox(height: 12),
                          _SecaoEquipamentos(dados: dados),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
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
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        _IndicadorCard(
          titulo: 'Solicitacoes',
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
          titulo: 'Usuarios',
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
      titulo: 'Solicitacoes por status',
      children: status.map((entry) {
        return _LinhaRelatorio(
          titulo: entry.key,
          valor: entry.value.toString(),
          percentual: dados.percentual(entry.value, dados.solicitacoes.length),
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
          titulo: 'Disponiveis',
          valor: disponiveis.toString(),
          percentual: dados.percentual(disponiveis, dados.equipamentos.length),
        ),
        _LinhaRelatorio(
          titulo: 'Em manutencao',
          valor: (dados.equipamentos.length - disponiveis).toString(),
          percentual: dados.percentual(
            dados.equipamentos.length - disponiveis,
            dados.equipamentos.length,
          ),
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
        titulo: 'Usuarios',
        children: [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Disponivel apenas para administrador.'),
          ),
        ],
      );
    }

    final perfis = dados.perfisOrdenados;

    return _Secao(
      titulo: 'Usuarios por perfil',
      children: perfis.map((entry) {
        return _LinhaRelatorio(
          titulo: entry.key,
          valor: entry.value.toString(),
          percentual: dados.percentual(entry.value, dados.usuarios.length),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...children,
        ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(valor, style: Theme.of(context).textTheme.headlineSmall),
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
  });

  final String titulo;
  final String valor;
  final double percentual;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: LinearProgressIndicator(value: percentual.clamp(0, 1)),
      trailing: Text(valor),
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
