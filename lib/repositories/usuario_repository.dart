import '../core/utils/api_exception.dart';
import '../models/usuario.dart';
import 'auth_repository.dart';

class UsuarioRepository {
  UsuarioRepository({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  static final List<Usuario> _usuarios = [
    const Usuario(
      id: 1,
      nome: 'Cliente UAB',
      email: 'cliente@uab.edu',
      perfil: 'Cliente',
    ),
    const Usuario(
      id: 2,
      nome: 'Atendente UAB',
      email: 'atendente@uab.edu',
      perfil: 'Atendente',
    ),
    const Usuario(
      id: 3,
      nome: 'Administrador UAB',
      email: 'admin@uab.edu',
      perfil: 'Administrador',
    ),
    const Usuario(
      id: 4,
      nome: 'Maria Souza',
      email: 'maria@uab.edu',
      perfil: 'Cliente',
    ),
    const Usuario(
      id: 5,
      nome: 'Joao Pereira',
      email: 'joao@uab.edu',
      perfil: 'Cliente',
    ),
    const Usuario(
      id: 6,
      nome: 'Suporte Laboratorio',
      email: 'suporte@uab.edu',
      perfil: 'Atendente',
    ),
  ];

  Future<List<Usuario>> listarTodos() async {
    await _exigirAdministrador();
    return List<Usuario>.unmodifiable(_usuarios);
  }

  Future<List<Usuario>> listarAtendentes() async {
    await _exigirAdministrador();

    return _usuarios
        .where((usuario) => usuario.perfil.toLowerCase() == 'atendente')
        .toList();
  }

  Future<Usuario> criarAtendente({
    required String nome,
    required String email,
    required String senha,
  }) async {
    await _exigirAdministrador();
    final usuario = Usuario(
      id: _proximoId(),
      nome: nome,
      email: email,
      perfil: 'Atendente',
    );

    _usuarios.add(usuario);
    return usuario;
  }

  Future<Usuario> atualizarAtendente({
    required int id,
    required String nome,
    required String email,
  }) async {
    await _exigirAdministrador();
    final index = _usuarios.indexWhere((usuario) => usuario.id == id);
    if (index == -1) {
      throw const ApiException(message: 'Usuario nao encontrado.');
    }

    final usuario = Usuario(
      id: id,
      nome: nome,
      email: email,
      perfil: 'Atendente',
    );

    _usuarios[index] = usuario;
    return usuario;
  }

  Future<void> remover(int id) async {
    await _exigirAdministrador();
    _usuarios.removeWhere((usuario) => usuario.id == id);
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

  int _proximoId() {
    if (_usuarios.isEmpty) {
      return 1;
    }
    return _usuarios
            .map((usuario) => usuario.id)
            .reduce((maior, id) => id > maior ? id : maior) +
        1;
  }
}
