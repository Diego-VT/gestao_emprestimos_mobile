import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/utils/api_exception.dart';
import '../models/usuario.dart';
import '../services/token_storage_service.dart';

class AuthRepository {
  AuthRepository({
    FlutterSecureStorage? secureStorage,
    TokenStorageService? tokenStorageService,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _tokenStorageService = tokenStorageService ?? TokenStorageService();

  final FlutterSecureStorage _secureStorage;
  final TokenStorageService _tokenStorageService;

  static const _usuarios = <String, Usuario>{
    'cliente@uab.edu': Usuario(
      id: 1,
      nome: 'Cliente UAB',
      email: 'cliente@uab.edu',
      perfil: 'Cliente',
    ),
    'maria@uab.edu': Usuario(
      id: 4,
      nome: 'Maria Souza',
      email: 'maria@uab.edu',
      perfil: 'Cliente',
    ),
    'joao@uab.edu': Usuario(
      id: 5,
      nome: 'Joao Pereira',
      email: 'joao@uab.edu',
      perfil: 'Cliente',
    ),
    'atendente@uab.edu': Usuario(
      id: 2,
      nome: 'Atendente UAB',
      email: 'atendente@uab.edu',
      perfil: 'Atendente',
    ),
    'suporte@uab.edu': Usuario(
      id: 6,
      nome: 'Suporte Laboratorio',
      email: 'suporte@uab.edu',
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
    final emailNormalizado = email.toLowerCase();
    final usuario = _usuarios[emailNormalizado];
    final senhaAtual = await _senhaUsuario(emailNormalizado);

    if (usuario == null || senha != senhaAtual) {
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

  Future<void> alterarSenha({
    required String email,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final emailNormalizado = email.toLowerCase();
    if (!_usuarios.containsKey(emailNormalizado)) {
      throw const ApiException(
        statusCode: 404,
        message: 'Usuario nao encontrado.',
      );
    }

    final senhaCadastrada = await _senhaUsuario(emailNormalizado);
    if (senhaAtual != senhaCadastrada) {
      throw const ApiException(
        statusCode: 401,
        message: 'Senha atual invalida.',
      );
    }

    await _secureStorage.write(
      key: _senhaKey(emailNormalizado),
      value: novaSenha,
    );
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

  Future<String> _senhaUsuario(String email) async {
    return await _secureStorage.read(key: _senhaKey(email)) ?? '123456';
  }

  String _senhaKey(String email) => 'senha_local_$email';
}
