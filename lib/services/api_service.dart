import '../models/solicitacao.dart';
import '../models/usuario.dart';

class ApiService {
  static final List<Solicitacao> _solicitacoes = [
    Solicitacao(
      id: 1,
      equipamento: 'Notebook Dell Latitude',
      solicitante: 'Ana Souza',
      status: 'Pendente',
      dataSolicitacao: DateTime(2026, 6, 1),
      justificativa: 'Uso em aula pratica no laboratorio de redes.',
    ),
    Solicitacao(
      id: 2,
      equipamento: 'Projetor Epson',
      solicitante: 'Carlos Lima',
      status: 'Aprovada',
      dataSolicitacao: DateTime(2026, 6, 3),
      justificativa: 'Apresentacao de trabalho academico.',
    ),
    Solicitacao(
      id: 3,
      equipamento: 'Kit de cabos HDMI',
      solicitante: 'Mariana Costa',
      status: 'Devolvida',
      dataSolicitacao: DateTime(2026, 6, 5),
      justificativa: 'Configuracao de sala para seminario.',
    ),
    Solicitacao(
      id: 4,
      equipamento: 'Tablet Samsung',
      solicitante: 'Joao Pereira',
      status: 'Rejeitada',
      dataSolicitacao: DateTime(2026, 6, 7),
      justificativa: 'Teste de aplicativo mobile.',
    ),
  ];

  Future<Usuario?> login({
    required String email,
    required String senha,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Integracao futura: substituir este mock por uma requisicao POST
    // para a API Flask, validando as credenciais no backend.
    if (email.isNotEmpty && senha.isNotEmpty) {
      return Usuario(
        id: 1,
        nome: 'Usuario Demo',
        email: email,
        perfil: 'Cliente',
      );
    }

    return null;
  }

  Future<List<Solicitacao>> listarSolicitacoes() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Integracao futura: buscar a lista via GET na API Flask.
    return List<Solicitacao>.unmodifiable(_solicitacoes);
  }

  Future<Solicitacao?> obterSolicitacao(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Integracao futura: buscar o detalhe via GET na API Flask usando o id.
    for (final solicitacao in _solicitacoes) {
      if (solicitacao.id == id) {
        return solicitacao;
      }
    }

    return null;
  }

  Future<Solicitacao> criarSolicitacao({
    required String equipamento,
    required String justificativa,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Integracao futura: enviar estes dados via POST para a API Flask.
    final novaSolicitacao = Solicitacao(
      id: _solicitacoes.length + 1,
      equipamento: equipamento,
      solicitante: 'Usuario Demo',
      status: 'Pendente',
      dataSolicitacao: DateTime.now(),
      justificativa: justificativa,
    );

    _solicitacoes.insert(0, novaSolicitacao);
    return novaSolicitacao;
  }
}
