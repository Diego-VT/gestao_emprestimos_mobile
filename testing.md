# INSTITUTO FEDERAL DO TOCANTINS – CAMPUS ARAGUATINS

# PÓS-GRADUAÇÃO LATO SENSU EM DESENVOLVIMENTO DE SISTEMAS COMPUTACIONAIS

# DISCIPLINA: DESENVOLVIMENTO MOBILE

## DIEGO VIEIRA TORRES

# PLANO DE TESTES (TDD)

## SISTEMA MOBILE DE GESTÃO DE EMPRÉSTIMO DE EQUIPAMENTOS

### Continuação do Projeto Desenvolvido na Disciplina de Desenvolvimento Web

ARAGUATINS – TO

2026

---

# PLANO DE TESTES (TDD)

## Sistema Mobile de Gestão de Empréstimo de Equipamentos

### 1. Introdução

Este documento apresenta o Plano de Testes do Sistema Mobile de Gestão de Empréstimo de Equipamentos, desenvolvido como continuidade do projeto implementado na disciplina Desenvolvimento Web.

A aplicação mobile será desenvolvida utilizando Flutter e Dart, executada e mantida por meio do Visual Studio Code, consumindo uma API REST desenvolvida previamente em Flask.

O objetivo do plano é definir uma estratégia de validação que garanta o correto funcionamento das funcionalidades do aplicativo, reduzindo falhas e prevenindo regressões durante o desenvolvimento.

---

## 2. Objetivos dos Testes

Os testes têm como objetivos:

* Validar os requisitos funcionais do aplicativo;
* Garantir a comunicação correta com a API REST;
* Verificar a integridade dos dados apresentados ao usuário;
* Detectar falhas antes da publicação;
* Garantir uma boa experiência de uso em dispositivos móveis;
* Facilitar a manutenção futura do sistema.

---

## 3. Escopo dos Testes

Serão avaliadas as seguintes funcionalidades:

### Autenticação

* Login;
* Logout;
* Persistência de sessão.

### Equipamentos

* Listagem de equipamentos;
* Consulta de detalhes;
* Atualização dos dados.

### Empréstimos

* Solicitação de empréstimo;
* Consulta de solicitações;
* Consulta de histórico.

### Integração

* Comunicação com API REST;
* Tratamento de erros;
* Processamento de respostas JSON.

---

## 4. Estratégia de Testes

### 4.1 Testes Unitários

Validam componentes individuais da aplicação.

Exemplos:

* Serviços de autenticação;
* Serviços HTTP;
* Conversão JSON;
* Validação de formulários.

### 4.2 Testes de Integração

Validam a comunicação entre:

* Flutter e API Flask;
* Serviços e modelos de dados;
* Persistência local e API.

### 4.3 Testes de Interface (Widget Tests)

Validam:

* Botões;
* Campos de entrada;
* Listas;
* Cards;
* Menus;
* Navegação.

### 4.4 Testes End-to-End

Validam fluxos completos do usuário.

Exemplos:

* Login → Listagem → Solicitação → Histórico;
* Login → Logout.

---

## 5. Ferramentas Utilizadas

### Framework Mobile

* Flutter
* Dart

### Ambiente de Desenvolvimento

* Visual Studio Code

### Ferramentas de Teste

* flutter_test
* integration_test
* mocktail
* flutter_lints

---

## 6. Dependências de Teste

Adicionar ao arquivo pubspec.yaml:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  integration_test:
    sdk: flutter

  mocktail: ^1.0.3

  flutter_lints: ^5.0.0
```

---

## 7. Casos de Teste

### MOB001 – Login com Credenciais Válidas

Objetivo:
Validar autenticação do usuário.

Resultado Esperado:
Usuário autenticado e redirecionado para a tela principal.

Prioridade:
Alta

---

### MOB002 – Login com Credenciais Inválidas

Objetivo:
Validar tratamento de erro.

Resultado Esperado:
Mensagem informando usuário ou senha inválidos.

Prioridade:
Alta

---

### MOB003 – Listar Equipamentos

Objetivo:
Validar carregamento dos equipamentos.

Resultado Esperado:
Lista apresentada corretamente.

Prioridade:
Alta

---

### MOB004 – Visualizar Detalhes do Equipamento

Objetivo:
Validar exibição dos detalhes.

Resultado Esperado:
Informações completas carregadas.

Prioridade:
Alta

---

### MOB005 – Solicitar Empréstimo

Objetivo:
Validar envio da solicitação.

Resultado Esperado:
Solicitação registrada com sucesso.

Prioridade:
Alta

---

### MOB006 – Consultar Histórico

Objetivo:
Validar histórico de empréstimos.

Resultado Esperado:
Histórico exibido corretamente.

Prioridade:
Média

---

### MOB007 – Atualização dos Dados

Objetivo:
Validar sincronização com API.

Resultado Esperado:
Dados atualizados sem inconsistências.

Prioridade:
Média

---

### MOB008 – Logout

Objetivo:
Validar encerramento da sessão.

Resultado Esperado:
Retorno para tela de login.

Prioridade:
Alta

---

## 8. Testes de Integração com API

### API001 – Login

Endpoint:

```http
POST /api/login
```

Resultado Esperado:

```http
200 OK
```

Retorno do token de autenticação.

---

### API002 – Listar Equipamentos

Endpoint:

```http
GET /api/equipamentos
```

Resultado Esperado:

Lista JSON válida.

---

### API003 – Solicitar Empréstimo

Endpoint:

```http
POST /api/emprestimos
```

Resultado Esperado:

Solicitação criada com sucesso.

---

### API004 – Histórico de Empréstimos

Endpoint:

```http
GET /api/emprestimos/meus
```

Resultado Esperado:

Histórico retornado corretamente.

---

## 9. Testes de Usabilidade

Serão avaliados:

* Facilidade de navegação;
* Clareza das informações;
* Legibilidade dos textos;
* Tempo de resposta;
* Organização visual;
* Compatibilidade com diferentes tamanhos de tela.

---

## 10. Cobertura de Testes

Meta mínima:

```text
80%
```

Execução:

```bash
flutter test
```

Relatórios poderão ser gerados durante o desenvolvimento para acompanhamento da qualidade do código.

---

## 11. Critérios de Aprovação

O aplicativo será considerado apto para entrega quando:

* Todos os testes críticos forem aprovados;
* Não houver falhas de autenticação;
* A comunicação com a API estiver funcional;
* Os fluxos principais estiverem operacionais;
* A cobertura mínima atingir 80%;
* Não forem identificados erros críticos.

---

## 12. Critérios de Regressão

Os testes deverão ser executados:

* Antes de cada commit;
* Antes de cada push;
* Após correções de bugs;
* Após inclusão de novas funcionalidades.

O objetivo é garantir que alterações futuras não comprometam funcionalidades já implementadas.

---

## 13. Considerações Finais

A aplicação dos testes definidos neste documento permitirá validar o correto funcionamento do Sistema Mobile de Gestão de Empréstimo de Equipamentos, garantindo qualidade, confiabilidade e estabilidade da solução.

A estratégia baseada em TDD contribuirá para a construção de um aplicativo robusto, alinhado às boas práticas de desenvolvimento mobile utilizando Flutter e Dart, integrado ao backend desenvolvido anteriormente na disciplina de Desenvolvimento Web.
