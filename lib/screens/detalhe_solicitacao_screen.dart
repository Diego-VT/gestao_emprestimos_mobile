import 'package:flutter/material.dart';

import '../core/utils/api_exception.dart';
import '../models/solicitacao.dart';
import '../repositories/solicitacao_repository.dart';

class DetalheSolicitacaoScreen extends StatefulWidget {
  const DetalheSolicitacaoScreen({super.key});

  static const routeName = '/detalhe-solicitacao';

  @override
  State<DetalheSolicitacaoScreen> createState() =>
      _DetalheSolicitacaoScreenState();
}

class _DetalheSolicitacaoScreenState extends State<DetalheSolicitacaoScreen> {
  final _solicitacaoRepository = SolicitacaoRepository();
  Future<Solicitacao>? _solicitacaoFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _solicitacaoFuture ??= _solicitacaoRepository.obterPorId(
      ModalRoute.of(context)!.settings.arguments as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da Solicitacao')),
      body: FutureBuilder<Solicitacao>(
        future: _solicitacaoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _mensagemErro(snapshot.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final solicitacao = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CampoDetalhe(
                titulo: 'Numero',
                valor: solicitacao.numero,
                icone: Icons.tag,
              ),
              _CampoDetalhe(
                titulo: 'Equipamento',
                valor: solicitacao.equipamento,
                icone: Icons.computer,
              ),
              _CampoDetalhe(
                titulo: 'Solicitante',
                valor: solicitacao.solicitante,
                icone: Icons.person_outline,
              ),
              _CampoDetalhe(
                titulo: 'Status',
                valor: solicitacao.status,
                icone: Icons.info_outline,
              ),
              _CampoDetalhe(
                titulo: 'Data',
                valor: _formatarData(solicitacao.dataSolicitacao),
                icone: Icons.calendar_today_outlined,
              ),
              _CampoDetalhe(
                titulo: 'Justificativa',
                valor: solicitacao.justificativa,
                icone: Icons.description_outlined,
              ),
            ],
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
    return 'Nao foi possivel carregar a solicitacao.';
  }
}

class _CampoDetalhe extends StatelessWidget {
  const _CampoDetalhe({
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
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo),
        subtitle: Text(valor),
      ),
    );
  }
}
