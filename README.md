# Gestão de Empréstimos Mobile

Aplicativo mobile em Flutter para gestão de empréstimos de equipamentos de TI.

O app permite acessar uma base local de usuários, equipamentos e solicitações sem depender de API no momento. A integração com o sistema Web/Flask poderá ser feita futuramente por meio de API REST.

## Funcionalidades

- Login local por perfil de usuário.
- Recuperação/alteração de senha local.
- Dashboard com acesso às áreas principais.
- Listagem de equipamentos disponíveis.
- Criação de solicitações de empréstimo.
- Acompanhamento de solicitações por status.
- Tela de relatórios com cards resumo e barras por status.
- Gestão de usuários para perfil administrador.
- Design system mobile com paleta corporativa, componentes consistentes e layout responsivo.

## Design System

Paleta principal:

- Azul corporativo: `#1E3A8A`
- Branco: `#FFFFFF`
- Fundo cinza claro: `#F8FAFC`

Cores de status:

| Status | Cor |
| --- | --- |
| Pendente | `#D97706` |
| Aprovada | `#16A34A` |
| Em análise | `#2563EB` |
| Concluída | `#059669` |
| Em manutenção | `#DC2626` |

## Usuários de Acesso

Todos os usuários locais iniciam com a senha:

```text
123456
```

| Perfil | E-mail | Senha |
| --- | --- | --- |
| Cliente | cliente@uab.edu | 123456 |
| Cliente | maria@uab.edu | 123456 |
| Cliente | joao@uab.edu | 123456 |
| Atendente | atendente@uab.edu | 123456 |
| Atendente | suporte@uab.edu | 123456 |
| Administrador | admin@uab.edu | 123456 |

## Equipamentos Locais

O aplicativo possui equipamentos cadastrados localmente para testes:

- Notebook Dell Latitude
- Projetor Epson PowerLite
- Tablet Samsung Galaxy Tab
- Câmera Logitech C920
- Microfone Fifine USB
- Kit Adaptadores HDMI/USB-C

## Como Executar no Celular

Com o celular conectado via USB e o modo depuração ativado:

```powershell
cd C:\develop\projeto_uab_mobile\gestao_emprestimos_mobile
$env:PUB_CACHE="C:\Users\diego.vieira\AppData\Local\Pub\Cache"
C:\develop\flutter\bin\flutter.bat run -d ZF523KMM7P
```

Caso o ID do aparelho seja diferente, liste os dispositivos:

```powershell
C:\develop\flutter\bin\flutter.bat devices
```

Depois execute substituindo o ID:

```powershell
C:\develop\flutter\bin\flutter.bat run -d ID_DO_DISPOSITIVO
```

## Gerar APK para Instalar

Para gerar o APK release:

```powershell
cd C:\develop\projeto_uab_mobile\gestao_emprestimos_mobile
C:\develop\flutter\bin\flutter.bat build apk --release
```

Arquivo gerado:

```text
build\app\outputs\flutter-apk\app-release.apk
```

Para instalar no celular via ADB:

```powershell
C:\DevPrograms\android_sdk\platform-tools\adb.exe install -r C:\develop\projeto_uab_mobile\gestao_emprestimos_mobile\build\app\outputs\flutter-apk\app-release.apk
```

## Comandos Úteis

Instalar dependências:

```powershell
C:\develop\flutter\bin\flutter.bat pub get
```

Analisar o código:

```powershell
C:\develop\flutter\bin\cache\dart-sdk\bin\dart.exe analyze
```

Rodar testes:

```powershell
C:\develop\flutter\bin\flutter.bat test
```

Gerar APK debug:

```powershell
C:\develop\flutter\bin\flutter.bat build apk --debug
```

## Tecnologias

- Flutter
- Dart
- Material Design 3
- Flutter Secure Storage
- HTTP

## Integração Futura com API

Atualmente o app funciona em modo offline/local. A integração futura com o sistema Web deverá consumir endpoints REST para:

- Autenticação de usuários.
- Listagem de equipamentos.
- Criação e consulta de solicitações.
- Atualização de status.
- Gestão de usuários.
- Relatórios.

## Estrutura Principal

```text
lib/
  core/
    theme/
    utils/
  models/
  repositories/
  screens/
```

## Status Atual

Versão mobile funcional em modo offline, com telas principais implementadas, dados locais cadastrados, design system aplicado e APK Android gerável para instalação em celular.
