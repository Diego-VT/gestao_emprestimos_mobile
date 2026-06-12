import 'package:flutter/material.dart';

import '../models/solicitacao.dart';
import '../services/api_service.dart';

class DetalheSolicitacaoScreen extends StatefulWidget {
  const DetalheSolicitacaoScreen({super.key});

  static const routeName = '/detalhe-solicitacao';

  @override
  State<DetalheSolicitacaoScreen> createState() =>
      _DetalheSolicitacaoScreenState();
}

class _DetalheSolicitacaoScreenState extends State<DetalheSolicitacaoScreen> {
  final _apiService = ApiService();
  Future<Solicitacao?>? _solicitacaoFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _solicitacaoFuture ??= _apiService.obterSolicitacao(
      ModalRoute.of(context)!.settings.arguments as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da Solicitacao')),
      body: FutureBuilder<Solicitacao?>(
        future: _solicitacaoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final solicitacao = snapshot.data;

          if (solicitacao == null) {
            return const Center(child: Text('Solicitacao nao encontrada.'));
          }

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
