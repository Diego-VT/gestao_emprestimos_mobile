import 'usuario.dart';

class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.usuario,
  });

  final String token;
  final Usuario usuario;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final source = data is Map<String, dynamic> ? data : json;
    final usuarioJson = source['usuario'] ?? source['user'];

    return AuthResponse(
      token: (source['token'] ?? source['access_token'] ?? source['jwt'] ?? '')
          .toString(),
      usuario: usuarioJson is Map<String, dynamic>
          ? Usuario.fromJson(usuarioJson)
          : Usuario.fromJson(source),
    );
  }
}
