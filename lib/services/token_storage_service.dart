import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/storage_keys.dart';
import '../models/usuario.dart';

class TokenStorageService {
  TokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> salvarSessao({
    required String token,
    required Usuario usuario,
  }) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
    await _storage.write(
      key: StorageKeys.usuario,
      value: jsonEncode(usuario.toJson()),
    );
  }

  Future<String?> obterToken() async {
    return _storage.read(key: StorageKeys.authToken);
  }

  Future<Usuario?> obterUsuario() async {
    final usuarioJson = await _storage.read(key: StorageKeys.usuario);

    if (usuarioJson == null) {
      return null;
    }

    final decoded = jsonDecode(usuarioJson);
    if (decoded is Map<String, dynamic>) {
      return Usuario.fromJson(decoded);
    }

    return null;
  }

  Future<bool> existeSessao() async {
    final token = await obterToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> limparSessao() async {
    await _storage.delete(key: StorageKeys.authToken);
    await _storage.delete(key: StorageKeys.usuario);
  }
}
