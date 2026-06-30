class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.seu-dominio.com/api',
  );

  static const timeout = Duration(seconds: 20);
}
