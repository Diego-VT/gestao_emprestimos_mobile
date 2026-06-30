import 'package:flutter/material.dart';

import '../core/utils/api_exception.dart';
import '../core/utils/input_validators.dart';
import '../repositories/solicitacao_repository.dart';

class NovaSolicitacaoScreen extends StatefulWidget {
  const NovaSolicitacaoScreen({super.key});

  static const routeName = '/nova-solicitacao';

  @override
  State<NovaSolicitacaoScreen> createState() => _NovaSolicitacaoScreenState();
}

class _NovaSolicitacaoScreenState extends State<NovaSolicitacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _equipamentoController = TextEditingController();
  final _justificativaController = TextEditingController();
  final _solicitacaoRepository = SolicitacaoRepository();

  bool _enviando = false;

  @override
  void dispose() {
    _equipamentoController.dispose();
    _justificativaController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _enviando = true);

    try {
      await _solicitacaoRepository.criar(
        equipamento: _equipamentoController.text.trim(),
        justificativa: _justificativaController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitacao enviada com sucesso.')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mensagemEnvio(erro))),
      );
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Solicitacao')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _equipamentoController,
                decoration: const InputDecoration(
                  labelText: 'Equipamento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.computer),
                ),
                validator: (value) => InputValidators.textoObrigatorio(
                  value,
                  nomeCampo: 'o equipamento',
                  maxLength: 120,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _justificativaController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Justificativa',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) => InputValidators.textoObrigatorio(
                  value,
                  nomeCampo: 'a justificativa',
                  maxLength: 500,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _enviando ? null : _enviar,
                icon: _enviando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mensagemEnvio(ApiException erro) {
    if (erro.statusCode == 401 || erro.statusCode == 403) {
      return 'Voce nao tem permissao para enviar esta solicitacao.';
    }
    return 'Nao foi possivel enviar a solicitacao. Tente novamente.';
  }
}
