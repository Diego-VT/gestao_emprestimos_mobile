import '../core/utils/api_exception.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import 'auth_repository.dart';

class UsuarioRepository {
  UsuarioRepository({
    ApiService? apiService,
    AuthRepository? authRepository,
  })  : _apiService = apiService ?? ApiService(),
        _authRepository = authRepository ?? AuthRepository();

  final ApiService _apiService;
  final AuthRepository _authRepository;

  Future<List<Usuario>> listarAtendentes() async {
    await _exigirAdministrador();
    final response = await _apiService.listarUsuarios();
    final lista = _extrairLista(response);

    return lista
        .whereType<Map<String, dynamic>>()
        .map(Usuario.fromJson)
        .where((usuario) => usuario.perfil.toLowerCase() == 'atendente')
        .toList();
  }

  Future<Usuario> criarAtendente({
    required String nome,
    required String email,
    required String senha,
  }) async {
    await _exigirAdministrador();
    final response = await _apiService.criarUsuario({
      'nome': nome,
      'email': email,
      'senha': senha,
      'perfil': 'Atendente',
    });

    return Usuario.fromJson(_extrairObjeto(response));
  }

  Future<Usuario> atualizarAtendente({
    required int id,
    required String nome,
    required String email,
  }) async {
    await _exigirAdministrador();
    final response = await _apiService.atualizarUsuario(
      id: id,
      usuario: {
        'nome': nome,
        'email': email,
        'perfil': 'Atendente',
      },
    );

    return Usuario.fromJson(_extrairObjeto(response));
  }

  Future<void> remover(int id) async {
    await _exigirAdministrador();
    await _apiService.removerUsuario(id);
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

  List<dynamic> _extrairLista(dynamic response) {
    if (response is List<dynamic>) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      final lista =
          response['data'] ?? response['usuarios'] ?? response['items'];

      if (lista is List<dynamic>) {
        return lista;
      }
    }

    throw const ApiException(message: 'Lista de usuarios invalida.');
  }

  Map<String, dynamic> _extrairObjeto(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['usuario'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return response;
    }

    throw const ApiException(message: 'Usuario invalido.');
  }
}
