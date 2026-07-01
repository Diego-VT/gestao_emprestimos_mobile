# Descrição do Projeto

## Sistema Web e Mobile de Gestão de Empréstimo de Equipamentos

O projeto consiste no desenvolvimento de um sistema para gestão de empréstimos de equipamentos, com uma aplicação Web administrativa e uma aplicação Mobile voltada ao uso prático por solicitantes, atendentes e administradores.

A proposta tem como objetivo substituir controles manuais, como planilhas, formulários físicos ou anotações informais, por uma solução digital capaz de organizar o cadastro de equipamentos, controlar solicitações de empréstimo, registrar devoluções e acompanhar o histórico de uso dos equipamentos.

O sistema será aplicado em ambientes como escolas, universidades, laboratórios, setores administrativos ou empresas que realizam empréstimos de notebooks, projetores, tablets, câmeras, ferramentas, periféricos ou outros equipamentos institucionais.

## Objetivo Geral

Desenvolver um sistema integrado Web e Mobile para controlar o processo de empréstimo de equipamentos, permitindo maior organização, rastreabilidade, segurança e facilidade de acesso às informações.

## Aplicação Web

A aplicação Web será utilizada principalmente para administração do sistema.

Suas principais funcionalidades serão:

- Cadastro, edição e remoção de equipamentos;
- Cadastro de categorias de equipamentos;
- Cadastro e gerenciamento de usuários;
- Aprovação ou rejeição de solicitações de empréstimo;
- Registro de entrega e devolução de equipamentos;
- Consulta de histórico de movimentações;
- Geração de relatórios gerenciais;
- Controle de equipamentos disponíveis, emprestados, em manutenção ou inativos.

A aplicação Web será desenvolvida com:

- Python;
- Flask;
- Jinja2;
- Bootstrap;
- SQLite;
- SQLAlchemy;
- Flask-Login;
- HTML, CSS e JavaScript.

## Aplicação Mobile

A aplicação Mobile será desenvolvida a partir das funcionalidades principais do sistema Web, oferecendo uma interface adaptada para smartphones.

O aplicativo permitirá que o usuário realize ações de forma rápida e prática pelo celular, sem depender exclusivamente do acesso por computador.

Suas principais funcionalidades serão:

- Login do usuário;
- Visualização dos equipamentos disponíveis;
- Consulta de detalhes do equipamento;
- Solicitação de empréstimo;
- Acompanhamento do status da solicitação;
- Consulta do histórico de empréstimos;
- Notificação visual de solicitações aprovadas, rejeitadas ou pendentes;
- Registro de devolução ou confirmação de recebimento, conforme o perfil do usuário.

A aplicação Mobile será desenvolvida utilizando:

- Flutter;
- Dart;
- Visual Studio Code;
- Consumo de API REST fornecida pelo backend Flask.

## Acesso de Teste no Aplicativo Mobile

No momento, o aplicativo mobile possui uma base local para uso offline,
sem depender da API. Todos os usuários abaixo usam a mesma senha:

```text
123456
```

Usuários disponíveis:

| Perfil | E-mail | Senha |
| --- | --- | --- |
| Cliente | cliente@uab.edu | 123456 |
| Cliente | maria@uab.edu | 123456 |
| Cliente | joao@uab.edu | 123456 |
| Atendente | atendente@uab.edu | 123456 |
| Atendente | suporte@uab.edu | 123456 |
| Administrador | admin@uab.edu | 123456 |

O modo offline também possui equipamentos cadastrados localmente para criar
solicitações de empréstimo pelo aplicativo.

## Perfis de Usuário

O sistema contará com três perfis principais:

### Solicitante

Usuário que poderá consultar equipamentos disponíveis, solicitar empréstimos e acompanhar suas solicitações.

### Atendente

Usuário responsável por analisar solicitações, aprovar ou rejeitar pedidos, registrar entregas e devoluções.

### Administrador

Usuário responsável pelo gerenciamento geral do sistema, incluindo equipamentos, categorias, usuários, relatórios e auditoria das movimentações.

## Integração entre Web e Mobile

A aplicação Web e a aplicação Mobile utilizarão a mesma base de dados por meio de um backend centralizado.

O backend será desenvolvido com Flask e disponibilizará rotas Web para navegação tradicional e rotas de API REST para comunicação com o aplicativo Flutter.

Exemplos de recursos disponibilizados pela API:

- Autenticação de usuários;
- Listagem de equipamentos;
- Consulta de detalhes de equipamentos;
- Criação de solicitações de empréstimo;
- Consulta de solicitações do usuário;
- Atualização de status de empréstimos;
- Registro de devoluções.

## Gestão dos Equipamentos

Cada equipamento terá informações como:

- Nome;
- Categoria;
- Número de patrimônio;
- Descrição;
- Estado de conservação;
- Quantidade disponível;
- Status;
- Data de cadastro;
- Observações.

Os principais status dos equipamentos serão:

- Disponível;
- Emprestado;
- Em manutenção;
- Inativo.

## Controle de Empréstimos

O processo de empréstimo seguirá o seguinte fluxo:

1. O solicitante acessa o aplicativo mobile ou o sistema Web;
2. Consulta os equipamentos disponíveis;
3. Realiza uma solicitação de empréstimo;
4. O atendente ou administrador analisa a solicitação;
5. A solicitação pode ser aprovada ou rejeitada;
6. Em caso de aprovação, o equipamento é entregue ao solicitante;
7. O sistema registra a data de entrega;
8. Ao final do uso, o equipamento é devolvido;
9. O atendente registra a devolução;
10. O empréstimo é encerrado no sistema.

## Relatórios Gerenciais

A aplicação Web disponibilizará relatórios para apoio à gestão, como:

- Equipamentos mais emprestados;
- Equipamentos atualmente indisponíveis;
- Empréstimos em andamento;
- Empréstimos em atraso;
- Histórico de empréstimos por usuário;
- Histórico de empréstimos por período;
- Quantidade de solicitações aprovadas, rejeitadas e pendentes.

## Tecnologias Utilizadas

### Backend Web

- Python;
- Flask;
- SQLAlchemy;
- SQLite;
- Flask-Login;
- API REST.

### Frontend Web

- HTML;
- CSS;
- JavaScript;
- Jinja2;
- Bootstrap.

### Mobile

- Flutter;
- Dart;
- Visual Studio Code.

### Infraestrutura e Desenvolvimento

- Git;
- GitHub;
- Ambiente virtual Python;
- Docker, quando necessário.

## Benefícios Esperados

Com o desenvolvimento do sistema, espera-se obter:

- Melhor controle dos equipamentos disponíveis;
- Redução de perdas e falhas de registro;
- Facilidade para solicitar equipamentos pelo celular;
- Maior agilidade no processo de aprovação;
- Histórico completo dos empréstimos;
- Relatórios para apoio à tomada de decisão;
- Integração entre sistema Web e aplicativo Mobile;
- Aplicação prática dos conceitos de desenvolvimento Web e Mobile.

## Considerações Finais

O projeto propõe uma solução simples, funcional e adequada ao contexto acadêmico, contemplando uma aplicação Web administrativa e uma aplicação Mobile desenvolvida com Flutter/Dart.

A versão Web será responsável pela gestão completa do sistema, enquanto a versão Mobile facilitará o acesso dos usuários às principais funcionalidades, especialmente solicitação, consulta e acompanhamento de empréstimos.

Dessa forma, o projeto amplia o escopo inicial da disciplina ao integrar desenvolvimento Web com desenvolvimento Mobile, mantendo uma arquitetura organizada, escalável e de fácil manutenção.
