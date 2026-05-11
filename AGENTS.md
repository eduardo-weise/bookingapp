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

## Regras de Negócio (fonte: `BUSINESS_RULES.md`)

> Antes de implementar qualquer feature que toque em agendamentos, pagamentos, autenticação ou permissões, **ler `BUSINESS_RULES.md` na raiz**.

### Estados de Agendamento (máquina de estados)

```
Scheduled → Canceled | Rescheduled | NoShow | Completed
Rescheduled → Canceled | Rescheduled | NoShow | Completed
```

- **Ativo**: `Scheduled` ou `Rescheduled` → únicos que podem ser cancelados, reagendados ou marcados como no-show.
- **Final**: `Canceled`, `Completed`, `NoShow` → sem ação posterior.

### Taxas e Multas

| Ação | Prazo | Taxa Cliente | Taxa Admin |
|---|---|---|---|
| Cancelamento | ≤ 24h | **35% obrigatória** | 35% opcional |
| Reagendamento | ≤ 24h | **15% obrigatória** | 15% opcional |
| No-Show | após horário | — | 50% opcional |

### Autorização por Role

- `Admin` / `Manager` → policy `AdminOrManager` (mesmas permissões).
- `Client` → policy `All`, só pode operar no próprio `ClientId`.
- Admin pode agendar em nome de outro cliente (`ClientId` opcional em `POST /appointments`).

### Regras de Tempo (Agendamentos)

- **Cancelamento tardio**: < 24h do horário.
- **Reagendamento bloqueado (cliente)**: < 1h do horário.
- **No-show**: só pode ser marcado **após** o horário do agendamento (`UtcNow > StartTime`).
- **Janelas de atendimento**: 08:00–11:00 e 14:00–21:00.
- **Slots**: gerados a cada 30 minutos dentro das janelas.

### Regras de Conflito

- Não pode haver overlap com outro agendamento ativo (`Scheduled` ou `Rescheduled`).
- Não pode agendar em dia de ausência programada.
- Swap request: ambos agendamentos devem estar ativos; TTL 24h.

### MFA e Auth

- MFA via TOTP (Google Authenticator); secret 20 bytes Base32.
- Login com MFA → retorna `TempToken` → cliente chama `POST /auth/mfa/verify` com código 6 dígitos.
- Recuperação de senha: PIN de 6 dígitos, válido por **15 minutos**.
- Refresh tokens: revogados em massa no soft delete ou novo login.

### Flutter — Regras de UI Críticas

- **Login**: email **não é limpo** em erro; senha **é limpa** automaticamente.
- **Cadastro**: senha mínimo **6 caracteres** (inconsistência: backend exige 8).
- **Cliente**: no-show **nunca é exibido** na visão do cliente.
- **Cliente**: remarcar **desabilitado** se < 1h do horário.
- **Admin**: no-show só aparece se data do agendamento ≤ hoje (`_isTodayOrBefore`).
- **Admin**: remarcar sem confirmação se > 24h do horário.
- **Booking flow**: `minDate = hoje`, `maxDate = hoje + 90 dias`; domingo/segunda bloqueados para cliente.
