# Refatoração e Otimização

## Sistema Mobile de Gestão de Empréstimo de Equipamentos

Este documento registra as mudanças realizadas na etapa de refatoração e otimização do aplicativo mobile desenvolvido em Flutter/Dart.

O objetivo da etapa foi melhorar a organização do código, preparar o aplicativo para integração real com a API REST do backend Flask, remover dependências de dados simulados e tornar o fluxo de autenticação mais consistente.

## 1. Organização da Estrutura do Projeto

A estrutura do projeto foi reorganizada com a criação de novas camadas e diretórios:

- `lib/core/config`: configurações gerais da aplicação;
- `lib/core/constants`: constantes reutilizáveis, como endpoints da API e chaves de armazenamento;
- `lib/core/utils`: classes auxiliares, tratamento de exceções e controle de sessão inicial;
- `lib/repositories`: camada responsável por converter respostas da API em modelos da aplicação;
- `lib/services`: serviços de comunicação HTTP e persistência local.

Essa separação reduz o acoplamento entre telas, serviços e modelos, facilitando a manutenção e a evolução do projeto.

## 2. Substituição dos Dados Simulados pela Integração com API

Antes da refatoração, o `ApiService` utilizava uma lista local de solicitações simuladas e retornava dados fictícios para login, listagem, detalhe e criação de solicitações.

Na refatoração, essa lógica foi substituída por chamadas HTTP reais através da classe `ApiClient`.

Foram adicionadas operações para:

- `GET`: consulta de dados;
- `POST`: criação de registros e autenticação;
- `PUT`: atualização de registros;
- `DELETE`: remoção de registros.

Com isso, o aplicativo passou a ficar preparado para consumir a API REST disponibilizada pelo backend.

## 3. Centralização das Configurações da API

Foi criada a classe `ApiConfig`, responsável por centralizar:

- URL base da API;
- tempo limite das requisições.

A URL base utiliza `String.fromEnvironment`, permitindo informar outro endereço durante a execução do aplicativo sem alterar o código-fonte.

Exemplo de configuração padrão:

```text
http://10.0.2.2:5000/api
```

Esse endereço é adequado para testes no emulador Android acessando uma API local.

## 4. Centralização dos Endpoints

Foi criada a classe `ApiEndpoints`, reunindo os caminhos usados nas requisições:

- `/auth/login`;
- `/solicitacoes`;
- `/usuarios`;
- `/solicitacoes/{id}`;
- `/usuarios/{id}`.

Essa mudança evita a repetição de strings nas telas e serviços, além de reduzir erros ao alterar rotas da API.

## 5. Criação do Cliente HTTP

Foi implementada a classe `ApiClient`, responsável por:

- montar a URL completa das requisições;
- enviar headers padrão;
- codificar o corpo das requisições em JSON;
- incluir token JWT no header `Authorization`;
- aplicar timeout nas chamadas;
- processar respostas de sucesso;
- extrair mensagens de erro;
- lançar exceções padronizadas.

Essa classe concentra a comunicação HTTP e evita duplicação de lógica em diferentes partes do aplicativo.

## 6. Tratamento Padronizado de Erros

Foi criada a classe `ApiException` para representar falhas de comunicação ou erros retornados pela API.

O tratamento contempla:

- erro de comunicação com o servidor;
- resposta inválida;
- tempo de conexão esgotado;
- mensagens retornadas em campos como `message`, `erro`, `error` ou `detail`;
- status HTTP de erro.

Com isso, as telas conseguem exibir mensagens mais claras ao usuário e o código fica mais previsível.

## 7. Persistência de Sessão

Foi adicionado o serviço `TokenStorageService`, utilizando `flutter_secure_storage` para salvar localmente:

- token de autenticação;
- dados do usuário logado.

O serviço também permite:

- recuperar o token;
- recuperar o usuário;
- verificar se existe sessão ativa;
- limpar a sessão no logout.

Essa mudança permite manter o usuário autenticado entre aberturas do aplicativo.

## 8. Criação da Camada de Repositórios

Foram criados repositórios para isolar as regras de acesso aos dados:

- `AuthRepository`;
- `SolicitacaoRepository`;
- `UsuarioRepository`.

Essas classes ficam responsáveis por chamar o `ApiService`, validar o formato das respostas e converter JSON em modelos da aplicação.

Essa abordagem deixa as telas mais simples, pois elas deixam de conhecer detalhes da API e passam a trabalhar com objetos como `Usuario` e `Solicitacao`.

## 9. Refatoração do Fluxo de Autenticação

O login foi alterado para usar `AuthRepository` em vez de autenticação simulada.

Após autenticar, o aplicativo:

- valida a resposta da API;
- extrai o token JWT;
- salva a sessão localmente;
- redireciona o usuário para o dashboard.

Também foi criado o `AuthGate`, componente responsável por decidir a tela inicial do aplicativo:

- se existir sessão ativa, abre o dashboard;
- se não existir sessão, abre a tela de login.

Com isso, o `main.dart` passou a usar o `AuthGate` como entrada principal.

## 10. Atualização do Logout

O botão de saída do dashboard passou a limpar a sessão salva localmente antes de retornar à tela de login.

Essa mudança evita que o aplicativo mantenha tokens antigos após o usuário sair.

## 11. Refatoração das Telas de Solicitação

As telas relacionadas a solicitações foram atualizadas para usar `SolicitacaoRepository`:

- listagem de solicitações;
- detalhe de solicitação;
- criação de nova solicitação.

Também foram adicionados tratamentos para erros de carregamento, com mensagens amigáveis e opção de tentar novamente na listagem.

## 12. Atualização dos Modelos

Os modelos `Usuario` e `Solicitacao` foram ampliados com métodos de conversão entre objeto e JSON.

Isso permite que os dados recebidos da API sejam convertidos de forma centralizada e reutilizável.

Também foi criado o modelo `AuthResponse`, responsável por representar a resposta de autenticação da API, incluindo:

- token;
- usuário autenticado.

## 13. Novas Dependências

Foram adicionadas as dependências:

- `http`: usada para comunicação com a API REST;
- `flutter_secure_storage`: usada para persistência segura da sessão.

Essas bibliotecas permitem substituir a simulação local por um fluxo real de comunicação e autenticação.

## 14. Ajustes nos Testes

O teste de widget foi ajustado para inicializar valores simulados do `FlutterSecureStorage`.

Também foi adicionado `pumpAndSettle()` para aguardar o `AuthGate` concluir a verificação assíncrona da sessão antes das validações da tela de login.

## 15. Benefícios da Refatoração

As mudanças realizadas trouxeram os seguintes benefícios:

- código mais organizado por responsabilidade;
- menor duplicação de lógica;
- telas menos dependentes de detalhes da API;
- preparação para integração real com backend Flask;
- autenticação persistente com token;
- tratamento de erros mais consistente;
- maior facilidade de manutenção;
- maior facilidade para adicionar novos recursos.

## 16. Considerações Finais

A etapa de refatoração e otimização transformou o aplicativo de uma versão baseada em dados simulados para uma estrutura mais próxima de um aplicativo integrado a um backend real.

Com a nova organização, o projeto fica mais adequado para evolução, testes, manutenção e integração com a aplicação Web desenvolvida anteriormente.
