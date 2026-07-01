import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/status_style.dart';
import '../core/utils/api_exception.dart';
import '../models/solicitacao.dart';
import '../repositories/solicitacao_repository.dart';
import 'detalhe_solicitacao_screen.dart';

class SolicitacoesScreen extends StatefulWidget {
  const SolicitacoesScreen({super.key});

  static const routeName = '/solicitacoes';

  @override
  State<SolicitacoesScreen> createState() => _SolicitacoesScreenState();
}

class _SolicitacoesScreenState extends State<SolicitacoesScreen> {
  final _solicitacaoRepository = SolicitacaoRepository();
  final _buscaController = TextEditingController();
  late Future<List<Solicitacao>> _solicitacoesFuture;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _solicitacoesFuture = _solicitacaoRepository.listar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações'), centerTitle: true),
      body: FutureBuilder<List<Solicitacao>>(
        future: _solicitacoesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErroCarregamento(
              mensagem: _mensagemErro(snapshot.error),
              onTentarNovamente: () {
                setState(() {
                  _solicitacoesFuture = _solicitacaoRepository.listar();
                });
              },
            );
          }

          final solicitacoes = _filtrar(snapshot.data ?? []);
          final lista = solicitacoes.isEmpty
              ? const Center(child: Text('Nenhuma solicitação encontrada.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: solicitacoes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final solicitacao = solicitacoes[index];

                    return _SolicitacaoCard(
                      solicitacao: solicitacao,
                      dataFormatada: _formatarData(solicitacao.dataSolicitacao),
                      onTap: () => Navigator.pushNamed(
                        context,
                        DetalheSolicitacaoScreen.routeName,
                        arguments: solicitacao.id,
                      ),
                    );
                  },
                );

          return _ConteudoComBusca(
            buscaController: _buscaController,
            onBusca: _atualizarBusca,
            child: lista,
          );
        },
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  void _atualizarBusca(String value) {
    setState(() => _busca = value.trim().toLowerCase());
  }

  List<Solicitacao> _filtrar(List<Solicitacao> solicitacoes) {
    if (_busca.isEmpty) {
      return solicitacoes;
    }
    return solicitacoes
        .where(
          (solicitacao) =>
              solicitacao.equipamento.toLowerCase().contains(_busca) ||
              solicitacao.status.toLowerCase().contains(_busca),
        )
        .toList(growable: false);
  }

  String _mensagemErro(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Não foi possível carregar as solicitações.';
  }
}

class _ConteudoComBusca extends StatelessWidget {
  const _ConteudoComBusca({
    required this.buscaController,
    required this.onBusca,
    required this.child,
  });

  final TextEditingController buscaController;
  final ValueChanged<String> onBusca;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: TextField(
                controller: buscaController,
                onChanged: onBusca,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar equipamento...',
                  prefixIcon: Icon(Icons.search),
                  prefixIconColor: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _SolicitacaoCard extends StatelessWidget {
  const _SolicitacaoCard({
    required this.solicitacao,
    required this.dataFormatada,
    required this.onTap,
  });

  final Solicitacao solicitacao;
  final String dataFormatada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = StatusStyle.fromStatus(solicitacao.status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.analysisSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  _iconeEquipamento(solicitacao.equipamento),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solicitacao.equipamento,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dataFormatada,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(texto: solicitacao.status, style: status),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconeEquipamento(String nome) {
    final normalizado = nome.toLowerCase();
    if (normalizado.contains('notebook')) {
      return Icons.laptop_mac_outlined;
    }
    if (normalizado.contains('projetor')) {
      return Icons.connected_tv_outlined;
    }
    if (normalizado.contains('camera') || normalizado.contains('câmera')) {
      return Icons.photo_camera_outlined;
    }
    if (normalizado.contains('tablet')) {
      return Icons.tablet_mac_outlined;
    }
    return Icons.cable_outlined;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.texto, required this.style});

  final String texto;
  final StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 116),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.softColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: style.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  const _ErroCarregamento({
    required this.mensagem,
    required this.onTentarNovamente,
  });

  final String mensagem;
  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
