# Inspeção de Cibersegurança

## Escopo

- Projeto inspecionado: `gestao_emprestimos_mobile`
- Profundidade aplicada: moderada
- Data da inspeção: 30/06/2026
- Arquivos e pastas considerados: `lib/`, `android/`, `web/`, `pubspec.yaml`, `pubspec.lock`, `test/`, `README.md`, `testing.md`, `refatoracao-otimizacao.md`
- Observação: os placeholders `<ARQUIVOS|PASTA|PROJETO>`, `<SUPERFICIAL|MODERADA|PROFUNDA>` e `<LISTA DE PASTAS E ARQUIVOS CONSIDERADOS NA INSPEÇÃO>` não foram preenchidos na solicitação. Por isso, a inspeção considerou o projeto Flutter aberto no workspace e adotou profundidade moderada.

## Resumo Executivo

Foram identificados 8 achados de segurança. Os riscos mais relevantes estão relacionados ao uso de HTTP sem TLS, permissão explícita de tráfego cleartext no Android, armazenamento de token JWT em `SharedPreferences`, assinatura de release com chave debug e ausência de validações robustas para entradas enviadas ao backend.

### Contagem por Severidade

| Severidade | Quantidade |
| --- | ---: |
| Crítica | 0 |
| Alta | 3 |
| Média | 4 |
| Baixa | 1 |

### 5 Ações Mais Urgentes

1. Exigir HTTPS para a API e remover `usesCleartextTraffic="true"` do manifest de produção.
2. Migrar o armazenamento de tokens para armazenamento seguro, como Android Keystore/iOS Keychain via `flutter_secure_storage`.
3. Configurar assinatura de release própria e remover a assinatura com chave debug.
4. Remover credenciais pré-preenchidas da tela de login.
5. Validar tamanho, formato e caracteres permitidos das entradas antes de enviar dados ao backend.

## Achados Detalhados

## SEC-001 - Comunicação com API por HTTP e tráfego cleartext habilitado

**Localização**

- `lib/core/config/api_config.dart`, classe `ApiConfig`, linhas 4-7
- `android/app/src/main/AndroidManifest.xml`, elemento `<application>`, linhas 4-8

**Descrição**

O aplicativo usa `http://10.0.2.2:5000/api` como URL padrão da API e permite explicitamente tráfego sem criptografia no Android por meio de `android:usesCleartextTraffic="true"`.

**Evidência**

```dart
static const baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:5000/api',
);
```

```xml
<application
    android:label="teste_flutter"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:usesCleartextTraffic="true">
```

**Impacto Potencial**

Credenciais, tokens JWT e dados de solicitações podem ser interceptados ou alterados em trânsito por ataques de rede, como man-in-the-middle. Isso pode comprometer autenticação, sessão e integridade dos dados.

**Severidade**

Alta

**Recomendação**

Usar HTTPS em todos os ambientes não locais e desabilitar cleartext em produção.

Exemplo:

```dart
static const baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.seu-dominio.com/api',
);
```

```xml
<application
    android:label="gestao_emprestimos"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:usesCleartextTraffic="false">
```

Para desenvolvimento local, preferir `network_security_config` restrito a builds debug.

**Referências**

- OWASP Top 10: A02 Security Misconfiguration, A04 Cryptographic Failures
- CWE-319: Cleartext Transmission of Sensitive Information
- CWE-311: Missing Encryption of Sensitive Data
- CVE: não aplicável diretamente

## SEC-002 - Token JWT armazenado em SharedPreferences

**Localização**

- `lib/services/token_storage_service.dart`, classe `TokenStorageService`, linhas 13-20
- `lib/repositories/auth_repository.dart`, método `login`, linhas 32-35

**Descrição**

O token de autenticação e os dados do usuário são persistidos em `SharedPreferences`, que não é um armazenamento criptográfico apropriado para segredos.

**Evidência**

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString(StorageKeys.authToken, token);
await prefs.setString(StorageKeys.usuario, jsonEncode(usuario.toJson()));
```

```dart
await _tokenStorageService.salvarSessao(
  token: authResponse.token,
  usuario: authResponse.usuario,
);
```

**Impacto Potencial**

Em dispositivos comprometidos, backups, ambientes com root, análise forense ou extração de dados locais, o token pode ser recuperado e reutilizado para acessar a conta do usuário.

**Severidade**

Alta

**Recomendação**

Armazenar tokens com mecanismos seguros do sistema operacional, como Android Keystore e iOS Keychain.

Exemplo com `flutter_secure_storage`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const _storage = FlutterSecureStorage();

  Future<void> salvarSessao({required String token}) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> obterToken() {
    return _storage.read(key: 'auth_token');
  }

  Future<void> limparSessao() {
    return _storage.delete(key: 'auth_token');
  }
}
```

Evitar armazenar dados pessoais do usuário se não forem necessários.

**Referências**

- OWASP Top 10: A04 Cryptographic Failures
- CWE-312: Cleartext Storage of Sensitive Information
- CWE-922: Insecure Storage of Sensitive Information
- CVE: não aplicável diretamente

## SEC-003 - Build de release assinado com chave debug

**Localização**

- `android/app/build.gradle.kts`, bloco `buildTypes.release`, linhas 28-33

**Descrição**

O build de release está configurado para usar a chave debug. Chaves debug são previsíveis, inadequadas para publicação e podem permitir distribuição de builds não confiáveis com a mesma identidade do aplicativo.

**Evidência**

```kotlin
release {
    // TODO: Add your own signing config for the release build.
    // Signing with the debug keys for now, so `flutter run --release` works.
    signingConfig = signingConfigs.getByName("debug")
}
```

**Impacto Potencial**

Um build malicioso ou não autorizado pode ser assinado com chave debug em cenários de distribuição fora da loja oficial. Isso afeta integridade, confiança do usuário e cadeia de suprimentos.

**Severidade**

Alta

**Recomendação**

Criar uma assinatura de release própria e manter senhas fora do repositório, usando `key.properties`, variáveis de ambiente ou cofre de segredos.

Exemplo:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = true
    }
}
```

Adicionar `key.properties` e arquivos `.jks` ao `.gitignore`.

**Referências**

- OWASP Top 10: A03 Software Supply Chain Failures, A08 Software or Data Integrity Failures
- CWE-321: Use of Hard-coded Cryptographic Key
- CWE-494: Download of Code Without Integrity Check
- CVE: não aplicável diretamente

## SEC-004 - Credenciais de demonstração pré-preenchidas na tela de login

**Localização**

- `lib/screens/login_screen.dart`, classe `_LoginScreenState`, linhas 17-19

**Descrição**

Os campos de e-mail e senha são inicializados com valores fixos. Mesmo que sejam credenciais de demonstração, elas podem ser reutilizadas indevidamente, vazar em builds de produção ou incentivar contas compartilhadas.

**Evidência**

```dart
final _emailController = TextEditingController(text: 'cliente@uab.edu');
final _senhaController = TextEditingController(text: '123456');
```

**Impacto Potencial**

Se a conta existir no backend, qualquer pessoa com acesso ao app pode tentar autenticar usando as credenciais expostas. Também há risco de senha fraca ser copiada para ambientes reais.

**Severidade**

Média

**Recomendação**

Remover valores padrão em produção e usar preenchimento somente em builds debug.

Exemplo:

```dart
import 'package:flutter/foundation.dart';

final _emailController = TextEditingController(
  text: kDebugMode ? 'cliente@uab.edu' : '',
);
final _senhaController = TextEditingController(
  text: kDebugMode ? '123456' : '',
);
```

Idealmente, remover até mesmo do código e usar fixtures locais de teste.

**Referências**

- OWASP Top 10: A07 Authentication Failures
- CWE-798: Use of Hard-coded Credentials
- CWE-259: Use of Hard-coded Password
- CVE: não aplicável diretamente

## SEC-005 - Validação insuficiente de entradas enviadas ao backend

**Localização**

- `lib/screens/login_screen.dart`, método `build`, validadores, linhas 105-128
- `lib/screens/nova_solicitacao_screen.dart`, método `build`, validadores, linhas 84-107
- `lib/services/api_service.dart`, métodos `login` e `criarSolicitacao`, linhas 13-20 e 35-41

**Descrição**

Os campos validam basicamente presença de valor e, no e-mail, apenas a existência de `@`. Campos como `equipamento` e `justificativa` não possuem limite de tamanho, whitelist/blacklist contextual, normalização ou validação de formato. Os dados são enviados diretamente ao backend.

**Evidência**

```dart
if (!value.contains('@')) {
  return 'Informe um e-mail valido.';
}
```

```dart
if (value == null || value.trim().isEmpty) {
  return 'Informe a justificativa.';
}
```

```dart
body: {
  'equipamento': equipamento,
  'justificativa': justificativa,
},
```

**Impacto Potencial**

Caso o backend não aplique validação e codificação de saída adequadas, entradas maliciosas podem contribuir para injeção, XSS armazenado em interfaces Web administrativas, abuso de recursos por payloads grandes ou inconsistência de dados.

**Severidade**

Média

**Recomendação**

Aplicar validação no cliente para melhorar qualidade e reduzir abuso, mantendo validação obrigatória no backend.

Exemplo:

```dart
String? validarTextoObrigatorio(String? value, int maxLength) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) {
    return 'Campo obrigatorio.';
  }
  if (texto.length > maxLength) {
    return 'Informe no maximo $maxLength caracteres.';
  }
  final permitido = RegExp(r"^[\p{L}\p{N}\s.,;:!?@#%()/_-]+$", unicode: true);
  if (!permitido.hasMatch(texto)) {
    return 'Caracteres nao permitidos.';
  }
  return null;
}
```

No backend, usar consultas parametrizadas, validação por schema e escape/encoding de saída em páginas HTML.

**Referências**

- OWASP Top 10: A05 Injection, A06 Insecure Design
- CWE-20: Improper Input Validation
- CWE-79: Improper Neutralization of Input During Web Page Generation
- CWE-89: Improper Neutralization of Special Elements used in an SQL Command
- CVE: não aplicável diretamente

## SEC-006 - Operações administrativas sem verificação explícita de perfil no cliente

**Localização**

- `lib/repositories/usuario_repository.dart`, classe `UsuarioRepository`, linhas 11-56
- `lib/services/api_service.dart`, métodos de usuários, linhas 44-60

**Descrição**

O aplicativo possui métodos para listar, criar, atualizar e remover usuários, incluindo criação de atendentes, mas a camada cliente não verifica o perfil do usuário antes de chamar essas operações.

**Evidência**

```dart
Future<Usuario> criarAtendente({
  required String nome,
  required String email,
  required String senha,
}) async {
  final response = await _apiService.criarUsuario({
    'nome': nome,
    'email': email,
    'senha': senha,
    'perfil': 'Atendente',
  });
```

```dart
Future<dynamic> removerUsuario(int id) {
  return _apiClient.delete(ApiEndpoints.usuarioPorId(id));
}
```

**Impacto Potencial**

Se o backend não validar autorização por perfil em todas as rotas, usuários sem privilégios podem criar, alterar ou remover contas. Mesmo com backend protegido, a ausência de checagem no cliente aumenta risco de exposição acidental de fluxos administrativos.

**Severidade**

Média

**Recomendação**

Garantir autorização obrigatória no backend para todas as rotas de usuário. No cliente, ocultar fluxos administrativos e bloquear chamadas com base no perfil recuperado da sessão.

Exemplo:

```dart
Future<void> exigirAdministrador() async {
  final usuario = await AuthRepository().obterUsuarioLogado();
  if (usuario?.perfil.toLowerCase() != 'administrador') {
    throw const ApiException(message: 'Acesso nao autorizado.');
  }
}
```

Esse controle no cliente é complementar; a decisão final deve ser sempre do servidor.

**Referências**

- OWASP Top 10: A01 Broken Access Control
- CWE-862: Missing Authorization
- CWE-863: Incorrect Authorization
- CVE: não aplicável diretamente

## SEC-007 - Mensagens de erro da API exibidas diretamente ao usuário

**Localização**

- `lib/services/api_client.dart`, método `_extrairMensagemErro`, linhas 125-135
- `lib/screens/login_screen.dart`, bloco `on ApiException`, linhas 49-56
- `lib/screens/nova_solicitacao_screen.dart`, bloco `on ApiException`, linhas 51-58

**Descrição**

O aplicativo extrai mensagens de erro retornadas pela API e exibe esse texto diretamente em `SnackBar`. Se o backend retornar detalhes técnicos, traces, nomes de tabelas, regras internas ou mensagens não sanitizadas, essas informações podem ser expostas ao usuário.

**Evidência**

```dart
return (body['message'] ??
        body['erro'] ??
        body['error'] ??
        body['detail'] ??
        'Erro ao processar a requisicao.')
    .toString();
```

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(erro.message)),
);
```

**Impacto Potencial**

Exposição de informações sensíveis sobre a API, enumeração de usuários no login, mensagens técnicas úteis para ataque e possível exibição de conteúdo hostil retornado pelo servidor.

**Severidade**

Média

**Recomendação**

Mapear erros para mensagens genéricas no cliente e registrar detalhes técnicos apenas no backend ou em telemetria segura.

Exemplo:

```dart
String mensagemUsuario(ApiException erro) {
  if (erro.statusCode == 401 || erro.statusCode == 403) {
    return 'Credenciais invalidas ou acesso nao autorizado.';
  }
  if (erro.statusCode != null && erro.statusCode! >= 500) {
    return 'Servico temporariamente indisponivel.';
  }
  return 'Nao foi possivel concluir a operacao.';
}
```

**Referências**

- OWASP Top 10: A10 Mishandling of Exceptional Conditions
- CWE-209: Generation of Error Message Containing Sensitive Information
- CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
- CVE: não aplicável diretamente

## SEC-008 - Ausência de cabeçalhos de segurança para build Web

**Localização**

- `web/index.html`, linhas 1-46
- Configuração de hospedagem Web: não encontrada no repositório

**Descrição**

O projeto possui alvo Web, mas não há configuração visível de cabeçalhos HTTP de segurança para Content Security Policy, HSTS, X-Frame-Options, Referrer-Policy ou Permissions-Policy. Esses cabeçalhos normalmente são definidos no servidor ou na plataforma de hospedagem, mas não há documentação/configuração no projeto.

**Evidência**

```html
<script src="flutter_bootstrap.js" async></script>
```

Não foram encontrados arquivos de configuração de servidor ou hospedagem contendo políticas como `Content-Security-Policy` ou `Strict-Transport-Security`.

**Impacto Potencial**

Em publicação Web, a ausência desses cabeçalhos pode facilitar XSS, clickjacking, downgrade de HTTPS e vazamento de informações por referrer, dependendo da hospedagem e do conteúdo servido.

**Severidade**

Baixa

**Recomendação**

Definir cabeçalhos na hospedagem. Exemplo genérico:

```text
Content-Security-Policy: default-src 'self'; script-src 'self'; connect-src 'self' https://api.seu-dominio.com; img-src 'self' data:; style-src 'self' 'unsafe-inline'
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Frame-Options: DENY
Referrer-Policy: no-referrer
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

A política CSP deve ser testada em ambiente de homologação, pois Flutter Web pode exigir ajustes específicos.

**Referências**

- OWASP Top 10: A02 Security Misconfiguration, A05 Injection
- CWE-693: Protection Mechanism Failure
- CWE-1021: Improper Restriction of Rendered UI Layers or Frames
- CWE-79: Improper Neutralization of Input During Web Page Generation
- CVE: não aplicável diretamente

## Pontos Positivos Observados

- As requisições usam `jsonEncode`, evitando concatenação manual de JSON.
- O header `Authorization: Bearer` é centralizado em `ApiClient`.
- Há timeout configurado para requisições HTTP.
- O código não contém uso local de SQL, `rawQuery`, `eval` ou WebView.
- Não foram encontrados segredos de provedores externos ou chaves de API reais no repositório durante a busca textual.

## Observações Sobre SQL Injection, XSS e CORS

- SQL Injection: não há acesso direto a banco de dados no aplicativo mobile. O risco principal está no backend Flask, que deve usar queries parametrizadas/ORM seguro e validação por schema.
- XSS: o app Flutter mobile não renderiza HTML diretamente, mas campos como `justificativa` e `equipamento` podem gerar XSS armazenado se forem exibidos sem escape na aplicação Web administrativa.
- CORS: não há configuração de CORS no cliente Flutter. A política deve ser revisada no backend Flask e restringida aos domínios realmente necessários.

## Conclusão

O projeto está em uma fase funcional de integração com API, mas ainda precisa de endurecimento antes de uso em produção. As correções prioritárias são criptografia em trânsito, armazenamento seguro de sessão, assinatura correta de release e validações mais rigorosas. Os controles de autorização e proteção contra injeção devem ser obrigatoriamente reforçados no backend, pois o cliente mobile não deve ser considerado uma barreira de segurança confiável.
