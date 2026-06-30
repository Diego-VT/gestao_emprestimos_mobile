import '../core/utils/api_exception.dart';
import '../models/solicitacao.dart';
import '../services/api_service.dart';

class SolicitacaoRepository {
  SolicitacaoRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<Solicitacao>> listar() async {
    final response = await _apiService.listarSolicitacoes();
    final lista = _extrairLista(response);

    return lista
        .whereType<Map<String, dynamic>>()
        .map(Solicitacao.fromJson)
        .toList();
  }

  Future<Solicitacao> obterPorId(int id) async {
    final response = await _apiService.obterSolicitacao(id);
    final json = _extrairObjeto(response);
    return Solicitacao.fromJson(json);
  }

  Future<Solicitacao> criar({
    required String equipamento,
    required String justificativa,
  }) async {
    final response = await _apiService.criarSolicitacao(
      equipamento: equipamento,
      justificativa: justificativa,
    );
    final json = _extrairObjeto(response);
    return Solicitacao.fromJson(json);
  }

  List<dynamic> _extrairLista(dynamic response) {
    if (response is List<dynamic>) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      final lista = response['data'] ??
          response['solicitacoes'] ??
          response['items'] ??
          response['results'];

      if (lista is List<dynamic>) {
        return lista;
      }
    }

    throw const ApiException(message: 'Lista de solicitacoes invalida.');
  }

  Map<String, dynamic> _extrairObjeto(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['solicitacao'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return response;
    }

    throw const ApiException(message: 'Solicitacao invalida.');
  }
}
