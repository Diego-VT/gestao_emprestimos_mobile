import 'package:flutter/material.dart';

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
  late Future<List<Solicitacao>> _solicitacoesFuture;

  @override
  void initState() {
    super.initState();
    _solicitacoesFuture = _solicitacaoRepository.listar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitacoes')),
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

          final solicitacoes = snapshot.data ?? [];

          if (solicitacoes.isEmpty) {
            return const Center(child: Text('Nenhuma solicitacao encontrada.'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: solicitacoes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final solicitacao = solicitacoes[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(child: Text(solicitacao.numero)),
                      title: Text(
                        solicitacao.equipamento,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${solicitacao.solicitante} - '
                        '${_formatarData(solicitacao.dataSolicitacao)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(solicitacao.status),
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        DetalheSolicitacaoScreen.routeName,
                        arguments: solicitacao.id,
                      ),
                    ),
                  );
                },
              ),
            ),
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

  String _mensagemErro(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Nao foi possivel carregar as solicitacoes.';
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
