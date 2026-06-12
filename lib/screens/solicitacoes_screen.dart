import 'package:flutter/material.dart';

import '../models/solicitacao.dart';
import '../services/api_service.dart';
import 'detalhe_solicitacao_screen.dart';

class SolicitacoesScreen extends StatefulWidget {
  const SolicitacoesScreen({super.key});

  static const routeName = '/solicitacoes';

  @override
  State<SolicitacoesScreen> createState() => _SolicitacoesScreenState();
}

class _SolicitacoesScreenState extends State<SolicitacoesScreen> {
  final _apiService = ApiService();
  late Future<List<Solicitacao>> _solicitacoesFuture;

  @override
  void initState() {
    super.initState();
    _solicitacoesFuture = _apiService.listarSolicitacoes();
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

          final solicitacoes = snapshot.data ?? [];

          if (solicitacoes.isEmpty) {
            return const Center(child: Text('Nenhuma solicitacao encontrada.'));
          }

          return ListView.separated(
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
                  leading: CircleAvatar(
                    child: Text(solicitacao.numero),
                  ),
                  title: Text(solicitacao.equipamento),
                  subtitle: Text(_formatarData(solicitacao.dataSolicitacao)),
                  trailing: Chip(label: Text(solicitacao.status)),
                  onTap: () => Navigator.pushNamed(
                    context,
                    DetalheSolicitacaoScreen.routeName,
                    arguments: solicitacao.id,
                  ),
                ),
              );
            },
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
