import '../core/utils/api_exception.dart';
import '../models/solicitacao.dart';
import 'auth_repository.dart';

class SolicitacaoRepository {
  SolicitacaoRepository({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  static final List<Solicitacao> _solicitacoes = [
    Solicitacao(
      id: 1,
      equipamento: 'Notebook Dell Latitude',
      solicitante: 'Cliente UAB',
      status: 'Pendente',
      dataSolicitacao: DateTime(2026, 6, 28),
      justificativa: 'Uso em apresentação de trabalho acadêmico.',
    ),
    Solicitacao(
      id: 2,
      equipamento: 'Projetor Epson PowerLite',
      solicitante: 'Maria Souza',
      status: 'Aprovada',
      dataSolicitacao: DateTime(2026, 6, 25),
      justificativa: 'Apoio para aula prática em laboratório.',
    ),
    Solicitacao(
      id: 3,
      equipamento: 'Tablet Samsung Galaxy Tab',
      solicitante: 'João Pereira',
      status: 'Em análise',
      dataSolicitacao: DateTime(2026, 6, 20),
      justificativa: 'Registro de presença em evento institucional.',
    ),
    Solicitacao(
      id: 4,
      equipamento: 'Câmera Logitech C920',
      solicitante: 'Suporte Laboratório',
      status: 'Pendente',
      dataSolicitacao: DateTime(2026, 6, 18),
      justificativa: 'Gravação de treinamento interno.',
    ),
    Solicitacao(
      id: 5,
      equipamento: 'Kit Adaptadores HDMI/USB-C',
      solicitante: 'Cliente UAB',
      status: 'Concluída',
      dataSolicitacao: DateTime(2026, 6, 12),
      justificativa: 'Conexão de notebook em sala de reunião.',
    ),
  ];

  Future<List<Solicitacao>> listar() async {
    return List<Solicitacao>.unmodifiable(_solicitacoes);
  }

  Future<Solicitacao> obterPorId(int id) async {
    try {
      return _solicitacoes.firstWhere((solicitacao) => solicitacao.id == id);
    } on StateError {
      throw const ApiException(message: 'Solicitação não encontrada.');
    }
  }

  Future<Solicitacao> criar({
    required String equipamento,
    required String justificativa,
  }) async {
    final usuario = await _authRepository.obterUsuarioLogado();
    final solicitacao = Solicitacao(
      id: _proximoId(),
      equipamento: equipamento,
      solicitante: usuario?.nome ?? 'Usuário local',
      status: 'Pendente',
      dataSolicitacao: DateTime.now(),
      justificativa: justificativa,
    );

    _solicitacoes.insert(0, solicitacao);
    return solicitacao;
  }

  int _proximoId() {
    if (_solicitacoes.isEmpty) {
      return 1;
    }
    return _solicitacoes
            .map((solicitacao) => solicitacao.id)
            .reduce((maior, id) => id > maior ? id : maior) +
        1;
  }
}
