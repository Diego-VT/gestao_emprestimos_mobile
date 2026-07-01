import '../core/utils/api_exception.dart';
import '../models/usuario.dart';
import '../services/token_storage_service.dart';

class AuthRepository {
  AuthRepository({TokenStorageService? tokenStorageService})
    : _tokenStorageService = tokenStorageService ?? TokenStorageService();

  final TokenStorageService _tokenStorageService;

  static const _usuarios = <String, Usuario>{
    'cliente@uab.edu': Usuario(
      id: 1,
      nome: 'Cliente UAB',
      email: 'cliente@uab.edu',
      perfil: 'Cliente',
    ),
    'atendente@uab.edu': Usuario(
      id: 2,
      nome: 'Atendente UAB',
      email: 'atendente@uab.edu',
      perfil: 'Atendente',
    ),
    'admin@uab.edu': Usuario(
      id: 3,
      nome: 'Administrador UAB',
      email: 'admin@uab.edu',
      perfil: 'Administrador',
    ),
  };

  Future<Usuario> login({required String email, required String senha}) async {
    final usuario = _usuarios[email.toLowerCase()];
    if (usuario == null || senha != '123456') {
      throw const ApiException(
        statusCode: 401,
        message: 'E-mail ou senha invalidos.',
      );
    }

    await _tokenStorageService.salvarSessao(
      token: 'token-local-${usuario.id}',
      usuario: usuario,
    );

    return usuario;
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
