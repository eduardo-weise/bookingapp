# AGENTS.md

STACK: .NET 10 + FastEndpoints / Flutter ^3.11.4 + Riverpod / tool: figma-export → skip

## Regras para agentes de IA

### Bootstrap de sessão (obrigatório)

No início de toda nova sessão, antes de responder ao usuário:

1. Carregar a skill `dotnet-design-pattern-review`.
2. Carregar a skill `dotnet-best-practices`.
3. Carregar a skill `caveman`.
4. Definir o modo caveman como `ultra`.
   Não aguardar solicitação do usuário.

### Gatilho manual

Se o usuário digitar `ultra`, garantir que a skill `caveman` está carregada e o modo está em `ultra`.

## Estrutura

```
server/
  BookingApp.API/           # FastEndpoints vertical slices (NOT MVC)
  BookingApp.Domain/        # Entities, AggregateRoot, DomainEvents, exceptions
  BookingApp.Infrastructure/# DbContext, configs, migrations
  BookingApp.slnx           # .slnx (não .sln)
  docker-compose.yml        # postgres:16 + api + maildev
client/
  lib/  core/               # API client, theme, extensions
        features/{admin,auth,client}/  # providers/ services/ sheets/ widgets/
        widgets/             # Shared UI
figma-export/                # React/Vite/Tailwind prototype → ignorar
```

## Server

### Arquitetura — Vertical Slice + FastEndpoints

Endpoints → `Endpoint<TReq,TResp>` com `Configure()`+`HandleAsync()`. Business logic inline. Sem MediatR, sem handler layer.

```
Features/  Auth/ Payments/ Scheduling/  Services/ Users/
```

FluentValidation auto-discovered. Domain events → FastEndpoints `IEvent` (não MediatR).

### Comandos

```bash
# Rodar
docker compose up -d
dotnet run --project BookingApp.API
# EF migrations
dotnet ef migrations add <Name> --project BookingApp.Infrastructure --startup-project BookingApp.API
dotnet ef database update --project BookingApp.Infrastructure --startup-project BookingApp.API
```

### Cuidados

- `EnsureCreatedAsync()` não `MigrateAsync()` → mudanças de modelo precisam de `database update` manual
- `.slnx` → `dotnet build server/BookingApp.slnx`
- Pasta extensions escrita errado `Extentions` → preservar!
- 3 roles: `Admin`/`Manager`/`Client` → FastEndpoints policy auth
- Idempotency global (`AddIdempotency()`)
- Creds dev hardcoded (postgres/postgres, localhost:1025 SMTP)

### Estilo de código (.editorconfig → errors)

- File-scoped namespaces, `var`, primary ctors
- Campos privados `_camelCase`, interfaces prefixo `I`
- Tabs para indentação
- Braces → `when_multiline`
- Unused usings & nullable violations → errors

## Client

### Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome   # web
flutter run              # default device
```

### Arquitetura

- Riverpod code-gen: `@riverpod` + `part '*.g.dart'` → re-rodar `build_runner` após mudar providers
- Navegação: `MaterialApp.routes` simples (3 rotas: `/`, `/client`, `/admin`). Sem GoRouter.
- Pastas de feature: `features/{admin,auth,client}/` com `providers/` `services/` `sheets/` `widgets/`
- Models: Dart puro (sem Freezed)
- API: Dio + interceptors (`core/services/api_client.dart`)

### Cuidados

- `client/` = entrypoint web; `client/mobile/` = entrypoint mobile separado
- `*.g.dart` commitado → regenerar após mudar providers

## Geral

- Docs & comments → Português Brasileiro
- Sem CI/CD, sem testes
- `TERMS_OF_USE.md` = design doc da feature AcceptTerms (não é legal)
- Ver `.github/copilot-instructions.md` (estilo de pensamento PT-BR)
