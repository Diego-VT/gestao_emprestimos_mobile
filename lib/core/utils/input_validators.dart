class InputValidators {
  const InputValidators._();

  static final _emailRegex = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  static final _caracteresBloqueadosRegex = RegExp(r'''[<>{}\[\]\\`$]''');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Informe o e-mail.';
    }
    if (email.length > 254 || !_emailRegex.hasMatch(email)) {
      return 'Informe um e-mail valido.';
    }
    return null;
  }

  static String? senha(String? value) {
    final senha = value ?? '';
    if (senha.isEmpty) {
      return 'Informe a senha.';
    }
    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (senha.length > 128) {
      return 'A senha deve ter no maximo 128 caracteres.';
    }
    return null;
  }

  static String? textoObrigatorio(
    String? value, {
    required String nomeCampo,
    required int maxLength,
  }) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Informe $nomeCampo.';
    }
    if (texto.length > maxLength) {
      return 'Informe no maximo $maxLength caracteres.';
    }
    if (_caracteresBloqueadosRegex.hasMatch(texto)) {
      return 'Remova caracteres nao permitidos.';
    }
    return null;
  }
}
