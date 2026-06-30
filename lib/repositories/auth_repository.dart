import '../core/utils/api_exception.dart';
import '../models/auth_response.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/token_storage_service.dart';

class AuthRepository {
  AuthRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorageService,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorageService = tokenStorageService ?? TokenStorageService();

  final ApiService _apiService;
  final TokenStorageService _tokenStorageService;

  Future<Usuario> login({
    required String email,
    required String senha,
  }) async {
    final response = await _apiService.login(email: email, senha: senha);

    if (response is! Map<String, dynamic>) {
      throw const ApiException(message: 'Resposta de login invalida.');
    }

    final authResponse = AuthResponse.fromJson(response);
    if (authResponse.token.isEmpty) {
      throw const ApiException(message: 'Token JWT nao retornado pela API.');
    }

    await _tokenStorageService.salvarSessao(
      token: authResponse.token,
      usuario: authResponse.usuario,
    );

    return authResponse.usuario;
  }

  Future<bool> existeSessao() {
    return _tokenStorageService.existeSessao();
  }

  Future<Usuario?> obterUsuarioLogado() {
    return _tokenStorageService.obterUsuario();
  }

  Future<void> logout() {
    return _tokenStorageService.limparSessao();
  }
}
