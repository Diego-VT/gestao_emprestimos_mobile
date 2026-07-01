import '../core/utils/api_exception.dart';
import '../models/usuario.dart';
import 'auth_repository.dart';

class UsuarioRepository {
  UsuarioRepository({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  Future<List<Usuario>> listarTodos() async {
    await _exigirAdministrador();
    return List<Usuario>.unmodifiable(AuthRepository.usuariosLocais);
  }

  Future<List<Usuario>> listarAtendentes() async {
    await _exigirAdministrador();

    return AuthRepository.usuariosLocais
        .where((usuario) => usuario.perfil.toLowerCase() == 'atendente')
        .toList();
  }

  Future<Usuario> criarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String perfil,
  }) async {
    await _exigirAdministrador();
    final emailNormalizado = email.toLowerCase();

    if (AuthRepository.existeUsuario(emailNormalizado)) {
      throw const ApiException(
        statusCode: 409,
        message: 'Ja existe usuario com este e-mail.',
      );
    }

    final usuario = Usuario(
      id: AuthRepository.proximoUsuarioId(),
      nome: nome,
      email: emailNormalizado,
      perfil: perfil,
    );

    AuthRepository.cadastrarUsuarioLocal(usuario);
    await _authRepository.definirSenhaUsuario(
      email: usuario.email,
      novaSenha: senha,
    );

    return usuario;
  }

  Future<Usuario> criarAtendente({
    required String nome,
    required String email,
    required String senha,
  }) {
    return criarUsuario(
      nome: nome,
      email: email,
      senha: senha,
      perfil: 'Atendente',
    );
  }

  Future<Usuario> atualizarAtendente({
    required int id,
    required String nome,
    required String email,
  }) async {
    return atualizarUsuario(
      id: id,
      nome: nome,
      email: email,
      perfil: 'Atendente',
    );
  }

  Future<Usuario> atualizarUsuario({
    required int id,
    required String nome,
    required String email,
    required String perfil,
  }) async {
    await _exigirAdministrador();
    Usuario? usuarioAtual;
    for (final usuario in AuthRepository.usuariosLocais) {
      if (usuario.id == id) {
        usuarioAtual = usuario;
        break;
      }
    }

    if (usuarioAtual == null) {
      throw const ApiException(message: 'Usuario nao encontrado.');
    }

    final emailNormalizado = email.toLowerCase();
    if (emailNormalizado != usuarioAtual.email.toLowerCase() &&
        AuthRepository.existeUsuario(emailNormalizado)) {
      throw const ApiException(
        statusCode: 409,
        message: 'Ja existe usuario com este e-mail.',
      );
    }

    final usuario = Usuario(
      id: id,
      nome: nome,
      email: emailNormalizado,
      perfil: perfil,
    );

    AuthRepository.atualizarUsuarioLocal(
      emailAnterior: usuarioAtual.email,
      usuario: usuario,
    );

    return usuario;
  }

  Future<void> alterarSenhaUsuario({
    required String email,
    required String novaSenha,
  }) async {
    await _exigirAdministrador();
    await _authRepository.definirSenhaUsuario(
      email: email,
      novaSenha: novaSenha,
    );
  }

  Future<void> remover(int id) async {
    await _exigirAdministrador();
    AuthRepository.removerUsuarioLocal(id);
  }

  Future<void> _exigirAdministrador() async {
    final usuario = await _authRepository.obterUsuarioLogado();
    if (usuario?.perfil.toLowerCase() != 'administrador') {
      throw const ApiException(
        statusCode: 403,
        message: 'Acesso nao autorizado.',
      );
    }
  }
}
