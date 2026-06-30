import '../core/constants/api_endpoints.dart';
import 'api_client.dart';

class ApiService {
  ApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<dynamic> login({
    required String email,
    required String senha,
  }) {
    return _apiClient.post(
      ApiEndpoints.login,
      autenticado: false,
      body: {
        'email': email,
        'senha': senha,
      },
    );
  }

  Future<dynamic> listarSolicitacoes() {
    return _apiClient.get(ApiEndpoints.solicitacoes);
  }

  Future<dynamic> obterSolicitacao(int id) {
    return _apiClient.get(ApiEndpoints.solicitacaoPorId(id));
  }

  Future<dynamic> criarSolicitacao({
    required String equipamento,
    required String justificativa,
  }) {
    return _apiClient.post(
      ApiEndpoints.solicitacoes,
      body: {
        'equipamento': equipamento,
        'justificativa': justificativa,
      },
    );
  }

  Future<dynamic> listarUsuarios() {
    return _apiClient.get(ApiEndpoints.usuarios);
  }

  Future<dynamic> criarUsuario(Map<String, dynamic> usuario) {
    return _apiClient.post(ApiEndpoints.usuarios, body: usuario);
  }

  Future<dynamic> atualizarUsuario({
    required int id,
    required Map<String, dynamic> usuario,
  }) {
    return _apiClient.put(ApiEndpoints.usuarioPorId(id), body: usuario);
  }

  Future<dynamic> removerUsuario(int id) {
    return _apiClient.delete(ApiEndpoints.usuarioPorId(id));
  }
}
