class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  final int id;
  final String nome;
  final String email;
  final String perfil;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: _intValue(json['id'] ?? json['usuario_id']),
      nome: (json['nome'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      perfil: (json['perfil'] ?? json['role'] ?? 'Cliente').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'perfil': perfil,
    };
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
