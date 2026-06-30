import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/utils/api_exception.dart';
import 'token_storage_service.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    TokenStorageService? tokenStorageService,
  })  : _httpClient = httpClient ?? http.Client(),
        _tokenStorageService = tokenStorageService ?? TokenStorageService();

  final http.Client _httpClient;
  final TokenStorageService _tokenStorageService;

  Future<dynamic> get(String path, {bool autenticado = true}) {
    return _send(
      method: 'GET',
      path: path,
      autenticado: autenticado,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool autenticado = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      autenticado: autenticado,
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool autenticado = true,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      autenticado: autenticado,
    );
  }

  Future<dynamic> delete(String path, {bool autenticado = true}) {
    return _send(
      method: 'DELETE',
      path: path,
      autenticado: autenticado,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool autenticado,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      _validarTransporteSeguro(uri);
      final headers = await _headers(autenticado: autenticado);
      final encodedBody = body == null ? null : jsonEncode(body);

      final request = switch (method) {
        'GET' => _httpClient.get(uri, headers: headers),
        'POST' => _httpClient.post(uri, headers: headers, body: encodedBody),
        'PUT' => _httpClient.put(uri, headers: headers, body: encodedBody),
        'DELETE' => _httpClient.delete(uri, headers: headers),
        _ => throw const ApiException(message: 'Metodo HTTP invalido.'),
      };
      final response = await request.timeout(ApiConfig.timeout);

      return _processarResposta(response);
    } on http.ClientException {
      throw const ApiException(message: 'Erro de comunicacao com o servidor.');
    } on FormatException {
      throw const ApiException(message: 'Resposta invalida do servidor.');
    } on TimeoutException {
      throw const ApiException(message: 'Tempo de conexao esgotado.');
    }
  }

  Future<Map<String, String>> _headers({required bool autenticado}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (autenticado) {
      final token = await _tokenStorageService.obterToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  dynamic _processarResposta(http.Response response) {
    if (response.statusCode == 204) {
      return null;
    }

    final body = _decodificarBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extrairMensagemErro(body),
    );
  }

  String _extrairMensagemErro(dynamic body) {
    if (body is Map<String, dynamic>) {
      return (body['message'] ??
              body['erro'] ??
              body['error'] ??
              body['detail'] ??
              'Erro ao processar a requisicao.')
          .toString();
    }

    return 'Erro ao processar a requisicao.';
  }

  dynamic _decodificarBody(String responseBody) {
    if (responseBody.isEmpty) {
      return null;
    }

    return jsonDecode(responseBody);
  }

  void _validarTransporteSeguro(Uri uri) {
    if (kReleaseMode && uri.scheme != 'https') {
      throw const ApiException(
        message: 'Conexao insegura bloqueada.',
      );
    }
  }
}
