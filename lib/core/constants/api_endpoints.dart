class ApiEndpoints {
  const ApiEndpoints._();

  static const login = '/auth/login';
  static const solicitacoes = '/solicitacoes';
  static const usuarios = '/usuarios';

  static String solicitacaoPorId(int id) => '/solicitacoes/$id';

  static String usuarioPorId(int id) => '/usuarios/$id';
}
