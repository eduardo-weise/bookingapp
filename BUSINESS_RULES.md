# Regras de Negócio — BookingApp

## Sumário

1. [Visão Geral](#1-visão-geral)
2. [Autenticação e Autorização](#2-autenticação-e-autorização)
3. [Usuários](#3-usuários)
4. [Agendamentos](#4-agendamentos)
5. [Serviços](#5-serviços)
6. [Pagamentos e Débitos](#6-pagamentos-e-débitos)
7. [Swap Requests (Troca de Horários)](#7-swap-requests-troca-de-horários)
8. [Ausências](#8-ausências)
9. [Infraestrutura e Ambiente](#9-infraestrutura-e-ambiente)
10. [Frontend — Regras de UI/UX](#10-frontend--regras-de-uiux)
11. [Frontend — Regras do Cliente](#11-frontend--regras-do-cliente)
12. [Frontend — Regras do Admin](#12-frontend--regras-do-admin)

---

## 1. Visão Geral

O BookingApp é um sistema de agendamento de serviços com 3 perfis de usuário: **Admin**, **Manager** e **Client**.

- **Backend**: .NET 10 + FastEndpoints + EF Core + PostgreSQL.
- **Frontend**: Flutter + Riverpod (code-gen) + Dio.
- **Comunicação**: REST API com JWT Bearer tokens, refresh tokens e idempotência global.
- **Email**: SMTP local via MailDev (dev: `localhost:1025`).
- **CORS (dev)**: `AllowAnyOrigin() + AllowAnyMethod() + AllowAnyHeader()`.

---

## 2. Autenticação e Autorização

### 2.1 Perfis (Roles)

| Role      | Endpoint Policy           | Permissões                 |
| --------- | ------------------------- | -------------------------- |
| `Admin`   | `AdminOrManager` ou `All` | Acesso total               |
| `Manager` | `AdminOrManager` ou `All` | Mesmas permissões de Admin |
| `Client`  | `All`                     | Apenas próprios dados      |

- `All`: qualquer usuário autenticado.
- `AdminOrManager`: apenas Admin ou Manager.
- Roles são armazenadas no claim `role` do JWT.

### 2.2 Login (`POST /auth/login`)

- E-mail + senha; senha verificada via `PasswordHasher.Verify`.
- Se MFA habilitado (`IsMfaEnabled = true`): retorna `TempToken` (JWT). Cliente deve chamar `POST /auth/mfa/verify` com código TOTP de 6 dígitos.
- Se MFA desabilitado: retorna token de acesso + refresh token.
- Resposta 401 em caso de credenciais inválidas.

### 2.3 Registro (`POST /auth/register`)

- E-mail deve ser único (`EmailAlreadyExistsException`).
- Senha mínimo **8 caracteres**.
- Campos obrigatórios: `Email`, `Password`, `Name`, `Phone`, `Cpf`.
- Role default: `"Client"`.
- Em sucesso, faz login automático (retorna token + refresh token).

### 2.4 Recuperação de Senha

1. **Forgot Password** (`POST /auth/forgot-password`):
   - Gera PIN de **6 dígitos** (100000–999999).
   - Válido por **15 minutos**.
   - Envia e-mail via FluentEmail (SMTP `localhost:1025`).
   - Resposta sempre genérica para evitar enumeração de e-mails.
2. **Validar Token** (`POST /auth/validate-reset-token`):
   - Verifica se PIN corresponde ao e-mail e não expirou.
3. **Redefinir Senha** (`POST /auth/reset-password`):
   - Nova senha mínimo **8 caracteres**.
   - Limpa `ResetPasswordToken` e `ResetPasswordExpiry` após sucesso.

### 2.5 MFA (Multi-Fator)

- Setup via TOTP (Google Authenticator); secret de 20 bytes Base32.
- Endpoint `POST /auth/mfa/setup`: gera QR Code e secret.
- **Não é possível configurar MFA 2x** para o mesmo usuário (`ConflictException`).
- Verify: recebe `TempToken` (JWT) + código TOTP de 6 dígitos → retorna token final.

### 2.6 Refresh Tokens

- Armazenados como **hash** no banco.
- `IsActive = !IsRevoked && !IsExpired`.
- Ao login bem-sucedido, todos os refresh tokens ativos do usuário são revogados.
- Soft delete de usuário revoga todos os refresh tokens ativos.

### 2.7 Idempotência

- Global via `AddIdempotency()` no `Program.cs`.

---

## 3. Usuários

### 3.1 Campos

| Campo                  | Regras                                            |
| ---------------------- | ------------------------------------------------- |
| `Email`                | Único, validado como formato de e-mail            |
| `PasswordHash`         | Hash seguro, senha em texto mínimo 8 chars        |
| `Name`                 | Max 150 chars                                     |
| `PhoneNumber`          | Max 20 chars                                      |
| `Cpf`                  | Obrigatório no registro                           |
| `Role`                 | `Admin` / `Manager` / `Client` (default)          |
| `ExtraServiceDuration` | `TimeSpan`, default `Zero`, não pode ser negativo |
| `IsMfaEnabled`         | Boolean                                           |
| `IsDeleted`            | Soft delete                                       |

### 3.2 Soft Delete (`DELETE /users`)

- Apenas Admin/Manager.
- `IsDeleted = true`.
- Revoga todos os refresh tokens ativos.

### 3.3 Perfil

- `GET /users`: retorna `UserProfileDto` (Id, Email, Name, Phone, IsMfaEnabled).
- `PATCH /users`: atualiza `Name` (max 150) e `PhoneNumber` (max 20).

### 3.4 Listagem de Clientes (`GET /users/clients`)

- Apenas Admin/Manager.
- Filtra `Role == "Client" && !IsDeleted`.
- Ordena por `Name ?? Email`.
- `DisplayName`: `Name` se preenchido, senão `Email`.

### 3.5 Duração Extra de Serviço

- Admin/Manager podem ajustar `ExtraServiceDuration` por cliente (`POST /services/{serviceId}/clients/{clientId}/duration`).
- Não pode ser negativa.

---

## 4. Agendamentos

### 4.1 Estados

```
Scheduled → Canceled
Scheduled → Rescheduled
Scheduled → NoShow
Scheduled → Completed
Rescheduled → Canceled
Rescheduled → Rescheduled
Rescheduled → NoShow
Rescheduled → Completed
```

Estados finais (sem ação): `Canceled`, `Completed`, `NoShow`.

### 4.2 Regra de Atividade (`IsActive`)

Agendamento está ativo se status for `Scheduled` **ou** `Rescheduled`. Apenas agendamentos ativos podem ser:

- Cancelados
- Reagendados
- Marcados como no-show

### 4.3 Criação (`POST /appointments`)

- Admin pode agendar em nome de outro cliente (`ClientId` opcional).
- Cliente comum só pode agendar para si mesmo.
- **Conflito de horário**: não pode haver overlap com outro agendamento ativo (`Scheduled` ou `Rescheduled`).
- **Ausência**: não pode agendar em dia de ausência programada.
- **Duração**: `Service.DefaultDuration + Client.ExtraServiceDuration`.
- Agendamento inicial nasce como `Scheduled`.

### 4.4 Cancelamento (`POST /appointments/{id}/cancel`)

- Cliente só pode cancelar o próprio agendamento.
- Admin/Manager podem cancelar qualquer um.
- **Regra das 24h**: se faltam menos de 24h para o horário, é cancelamento tardio.
  - **Cliente**: taxa de **35% obrigatória**.
  - **Admin/Manager**: pode optar por aplicar ou não (`ApplyLateCancellationFee`).
- Taxa só gerada se não houver débito pendente já vinculado ao mesmo agendamento.
- Tipo de débito: `LateCancellation` (35%).

### 4.5 Reagendamento (`POST /appointments/{id}/reschedule`)

- Cliente só pode reagendar o próprio.
- Admin/Manager podem reagendar qualquer um.
- **Regra das 1h (cliente)**: cliente não pode reagendar com menos de 1h de antecedência.
- **Regra das 24h (taxa)**: se faltam menos de 24h, é reagendamento tardio.
  - **Cliente**: taxa de **15% obrigatória**.
  - **Admin/Manager**: pode optar por aplicar ou não (`ApplyLateRescheduleFee`).
- Conflitos de horário e ausências verificados no novo horário.
- Status passa para `Rescheduled`.

### 4.6 No-Show (`POST /appointments/{id}/noshow`)

- Admin/Manager podem marcar no-show.
- Só é possível marcar **após** o horário do agendamento (`DateTime.UtcNow > StartTime`).
- Somente agendamentos ativos (`IsActive`) podem receber no-show.
- **Taxa**: **50%** do valor do serviço (`DebtType.NoShow`).
- Admin pode optar por **não aplicar** a taxa (`ApplyNoShowFee = false`).

### 4.7 Listagem (`GET /appointments`)

- **Admin/Manager**: obrigatório query param `date`. Retorna agendamentos ativos daquele dia com nome do cliente.
- **Client**: retorna apenas seus agendamentos ativos a partir de hoje (inclusive), ordenados por horário.

### 4.8 Janelas de Horário (SchedulingWindows)

Dia dividido em 2 blocos fixos:

- Manhã: `08:00` → `11:00`
- Tarde: `14:00` → `21:00`

Slots gerados a cada **30 minutos** dentro de cada bloco, respeitando a duração total do serviço.

### 4.9 Slots Disponíveis (`GET /appointments/available-slots`)

- Retorna horários livres em uma data para um serviço.
- Considera agendamentos ativos + ausências do dia.
- Se `ClientId` informado, adiciona `ExtraServiceDuration`.

### 4.10 Datas Indisponíveis (`GET /appointments/unavailable-dates`)

- Retorna dias no intervalo `[StartDate, EndDate]` onde não existe nenhum slot livre.
- Considera agendamentos ativos + ausências.
- `EndDate >= StartDate`.

---

## 5. Serviços

- `Name`, `DefaultDuration`, `Price`.
- Listagem pública (`GET /services`).
- Detalhe por ID (`GET /services/{id}`).
- Admin/Manager ajustam `ExtraServiceDuration` por cliente.

---

## 6. Pagamentos e Débitos

### 6.1 Estados

- `Pending` — pendente
- `Paid` — pago
- `Canceled` — cancelado/perdoado

### 6.2 Tipos de Débito

| Tipo               | Taxa | Descrição                            |
| ------------------ | ---- | ------------------------------------ |
| `LateCancellation` | 35%  | Cancelamento tardio (dentro de 24h)  |
| `LateReschedule`   | 15%  | Reagendamento tardio (dentro de 24h) |
| `NoShow`           | 50%  | Ausência (no-show)                   |

### 6.3 Regras

- Só é possível marcar como pago (`MarkAsPaid`) ou cancelar (`Cancel`) se status for `Pending`.
- **Listagem** (`GET /payments/debts`):
  - Admin/Manager: vê todos os débitos pendentes de todos os clientes.
  - Cliente: vê apenas os próprios débitos pendentes.
- **Pagamento** (`POST /payments/debts/pay`):
  - Recebe `ClientId + List<DebtIds>`.
  - Marca todos os débitos pendentes da lista como `Paid`.
- **Cancelamento de débito** (`POST /payments/debts/cancel`):
  - Apenas Admin/Manager.
  - Cancela (perdoa) débitos pendentes do cliente informado.

---

## 7. Swap Requests (Troca de Horários)

### 7.1 Estados

```
Pending → Accepted | Declined | Expired
```

### 7.2 Regras

- Cliente cria swap request informando agendamento de origem (próprio) e destino.
- Ambos agendamentos devem estar ativos (`IsActive`).
- Agendamento de origem deve pertencer ao cliente criador.
- TTL padrão: **24 horas**.
- **Aceitar** (`POST /appointments/swaps/{id}/accept`):
  - Apenas dono do agendamento de destino pode aceitar.
  - Solicitação deve estar `Pending` e não expirada.
  - Troca-se o `ClientId` dos dois agendamentos.
- **Recusar** (`POST /appointments/swaps/{id}/decline`):
  - Apenas dono do agendamento de destino pode recusar.
  - Se `Pending`, muda para `Declined`.

---

## 8. Ausências

- Representa dias em que o estabelecimento não atende.
- Admin/Manager podem criar (`POST /absences`) e deletar (`DELETE /absences/{id}`).
- **Regra de overlap**: não pode haver overlap com outra ausência existente.
- **Regra de data**: `EndDate >= StartDate`.
- Listagem (`GET /absences`):
  - Apenas Admin/Manager.
  - Query params: `Future` (default `true`), `Page`, `PageSize`.
  - `Future=true`: ausências com `EndDate >= hoje`, ordenadas por `StartDate` ascendente.
  - `Future=false`: ausências passadas, ordenadas por `StartDate` descendente.

---

## 9. Infraestrutura e Ambiente

### 9.1 Docker Compose

| Serviço        | Imagem               | Portas                   |
| -------------- | -------------------- | ------------------------ |
| `database`     | `postgres:16-alpine` | `5432:5432`              |
| `api`          | Build local          | `18000:8080`             |
| `email-server` | `maildev/maildev`    | `1080:1080`, `1025:1025` |

- Network: `booking_network` (bridge).
- Volume: `postgres_data` em `/var/lib/postgresql/data`.
- Creds dev: `postgres/postgres`.
- SMTP dev: `localhost:1025`.

### 9.2 Banco de Dados

- **Inicialização**: `EnsureCreatedAsync()` no startup (não `MigrateAsync()`).
- Mudanças de modelo exigem `dotnet ef database update` manual.
- Connection string aponta para `database` (host interno Docker).

### 9.3 API (Backend)

- Porta dev: `18001` (launchSettings.json → `localhost:18001`).
- Para acesso externo (rede local), deve ser configurado para `0.0.0.0:18001`.
- Idempotência global ativa.
- CORS aberto em dev.

---

## 10. Frontend — Regras de UI/UX

### 10.1 Design System

- **Cores**: definidas em `app_colors.dart`.
  - `brandPrimary` → ações primárias, seleção, foco.
  - `statusConfirmed` → sucesso, ativo.
  - `statusCancelled` → erro, perigo, cancelado.
  - `statusPending` → alerta, pendente.
- **Tipografia**: `AppTextStyles` — heading1, heading2, heading3, body, caption, label.
- **Espaçamento**: `AppTheme.spacingXs` a `spacing2Xl`.
- **Border radius**: `radiusSm`, `radiusMd`, `radiusLg`, `radiusXl`, `radiusFull`.
- **Sombras**: `shadowSm`, `shadowMd`, `shadowCard`, `shadowLg`.

### 10.2 Bottom Sheets

- **Alturas**: `small` (45%), `medium` (65%), `large` (80%), `flexible` (max 70%).
- **Animação**: abertura 320ms, fechamento 240ms.
- **Comportamento**: sempre possui botão de voltar (seta no canto superior esquerdo); se `onBack` não fornecido, executa `Navigator.pop`.
- **Título**: aceita `String` ou `ValueNotifier<String>` para atualização dinâmica.
- **Handle bar**: 36×4px no topo como indicador visual.
- **Padding inferior**: respeita `viewInsets.bottom` (teclado virtual).

### 10.3 Snackbars

- **Posição**: topo da tela (`Positioned(top: 0)`).
- **Tipos**: erro (cor `statusCancelled`) e sucesso (cor `statusConfirmed`).
- **Duração**: 4 segundos, auto-dismiss via `Timer`.
- **Fallback**: se não houver `Overlay`, usa `ScaffoldMessenger` com `SnackBarBehavior.floating`.
- Prefixo `"Exception: "` é removido antes de exibir.

### 10.4 Botões (`AppButton`)

- **Variantes**: `primary`, `secondary`, `ghost`, `danger`.
- **Tamanhos**: `small` = 32px altura / fonte 13px; padrão = 48px / fonte 15px.
- **Estado desabilitado**: opacidade 50%.
- **Loading**: exibe `CircularProgressIndicator` no lugar do texto.

### 10.5 Inputs (`AppInput`)

- Campo obrigatório exibe asterisco vermelho (`statusCancelled`) e mensagem `"Campo obrigatório"` se vazio após blur.
- Validação dispara `AutovalidateMode.always` após primeiro blur em campo obrigatório vazio.
- Bordas: `focused` = `brandPrimary` 1.5px; `error` = `statusCancelled` 1.5px.
- Ícone trailing: alinhado à direita, cor `textSecondary`, tamanho 18px.

### 10.6 Badges (`AppBadge`)

- Altura 22px, formato pill (`radiusFull`).
- Variantes: `confirmed` (verde), `pending` (amarelo/laranja), `cancelled` (vermelho).

### 10.7 Date Picker (`AppDatePicker`)

- Biblioteca: `syncfusion_flutter_datepicker`.
- Altura fixa: 340px.
- Blackout dates: texto vermelho com `lineThrough` + círculo de fundo `cancelledBg`.
- Hoje: texto em `brandPrimary` com negrito.
- Seleção única/faixa: círculo `brandPrimary`; faixa preenchida com `brandLight`.

### 10.8 Appointment Card

- **Variantes**: `full` (cliente) e `compact` (admin) — atualmente ambos renderizam `full`.
- Layout full: ícone de calendário 56×56, nome do serviço, subtítulo, badge de status com data/hora.
- **Ações** (sempre visíveis no full):
  - _Reagendar_ — botão secundário.
  - _No Show_ — botão primário (só aparece se `onNoShowPressed != null`).
  - _Cancelar_ — botão danger.

### 10.9 Debt Card

- Visual: gradiente escuro (`#1A1A1A` → `#2D2D2D`).
- Valor: fonte 28px branca, ajusta via `FittedBox`.
- Layout responsivo: abaixo de 340px de largura, área de botões reduz para 170px (ao invés de 200px).
- Ações: _Pagar_ (secondary) e _Cancelar_ (danger).

---

## 11. Frontend — Regras do Cliente

### 11.1 Login

- Campo **email não é limpo** em caso de erro de login.
- Campo **senha é limpo** automaticamente em caso de erro.
- Checkbox "Lembrar-me" é puramente visual/local; não persiste token.
- Toggle de visibilidade da senha via ícone olho.
- Navegação pós-login: role extraída do JWT claim `role`; case-insensitive.
  - `admin` → rota `/admin`.
  - Qualquer outro → rota `/client`.

### 11.2 Cadastro

- Validação client-side:
  - Nome: obrigatório.
  - CPF: obrigatório, máscara `###.###.###-##`, exatamente 14 caracteres.
  - Email: obrigatório, deve conter `@`.
  - Telefone: obrigatório, máscara `(##) #####-####`, mínimo 14 caracteres.
  - Senha: obrigatório, mínimo **6 caracteres**.
  - Confirmar senha: deve coincidir com campo senha.
- Em sucesso, faz login implícito (salva tokens e navega para `/client`).

> **Inconsistência**: cadastro exige mínimo 6 caracteres de senha; recuperação de senha exige mínimo 8.

### 11.3 Recuperação de Senha (4 Etapas)

- **Persistência**: `SharedPreferences` com chaves `recovery_email`, `recovery_expiry`, `recovery_validated_token`.
- **Expiração**: **15 minutos** fixos.
- **Decisão de entrada**:
  - Se `recovery_validated_token` e `recovery_email` existem → pula para tela de nova senha.
  - Senão, se `recovery_expiry` e `recovery_email` existem e não expiraram → vai para tela de validação de token.
  - Senão → vai para tela de solicitação de email.
- **Email propagado**: email digitado no login é copiado para o sheet de recuperação (`initialEmail`).
- **Etapa 3 (Nova Senha)**:
  - Nova senha: mínimo 8 caracteres (regex `^.{8,}$`).
  - Confirmar senha: deve coincidir.
  - Em sucesso: limpa todas as chaves de recuperação do `SharedPreferences`.

### 11.4 Agendamentos do Cliente

- **Data source**: `GET /appointments`; sem filtro client-side de data.
- **Ordenação**: por `startTime` ascendente.
- **Status → badge**:
  - `scheduled`, `rescheduled`, `completed` → `BadgeVariant.confirmed` (label "Confirmado").
  - `canceled` → `BadgeVariant.cancelled` (label "Cancelado").
  - `noshow` → label "No-show".
  - Outros → `BadgeVariant.pending` (label "Pendente").
- **Reagendar**: botão sempre visível, mas **desabilitado** se `startTime` estiver dentro de 1h (`isBefore(now + 1h)`).
- **Cancelar**: sempre habilitado.
- **No-show**: **nunca exibido** na visão do cliente.

### 11.5 Booking Flow (Novo Agendamento)

- **Wizard**: Seleção de Cliente (admin) → Serviço → Data → Horário.
- **Restrição de datas**:
  - `minDate` = hoje.
  - `maxDate` = hoje + **90 dias**.
  - **Cliente**: domingo e segunda-feira são bloqueados no seletor de data.
  - **Admin**: sem filtro de dia da semana.
- **Datas indisponíveis**: carregadas por mês visível, com cache (`_loadedMonths`).
- **Slots de horário**: exibidos em grid de 3 colunas.
- **Seleção de horário**: borda 2px `brandPrimary` + fundo `muted` quando selecionado.
- **Confirmação**: monta `DateTime` a partir da data + `HH:MM` do slot.
- **Mensagens de sucesso**:
  - Reagendamento: "Agendamento reagendado com sucesso!"
  - Auto-agendamento: "Agendamento confirmado com sucesso!"
  - Admin para cliente: "Agendamento para {nome} confirmado com sucesso!"

### 11.6 Débitos do Cliente

- **Banner**: só aparece se houver débitos pendentes (`debts.isNotEmpty`).
- **Total**: soma dos `amount` de todos os débitos pendentes; formatado como `R$`.
- **Truncamento**: se > 2 débitos, mostra apenas os primeiros 2 com toggle "Ver todos".
- **Layout responsivo**: se largura < 360px, entra em modo compacto (fonte menor, botão menor).
- **CTA**: "Pagar tudo" navega para `/client/finances`.

### 11.7 Perfil do Cliente

- **Display name**: primeira palavra de `name`; se vazio, parte antes do `@` no `email`.
- **Iniciais**: até 2 caracteres derivados de `name` ou `email`.
- **Editar perfil**: campos editáveis `Name` e `Phone` (obrigatórios); `Email` e `CPF` desabilitados.
- **Logout**: desfoca campo, chama `AuthService().logout()`, navega para `/` removendo toda a pilha.

---

## 12. Frontend — Regras do Admin

### 12.1 Dashboard

- **Estatísticas** (valores estáticos/hardcoded no momento):
  - Clientes: `48`
  - Receita (mês): `8.5k`
- **Seção de Débitos Pendentes**: lista horizontal de cards por cliente.
  - Card: avatar com primeira letra do nome, primeiro nome, quantidade de débitos, badge "Pendente", valor total.
  - Toque abre detalhe de todos os débitos daquele cliente.
  - "Ver todos" abre lista de todos os clientes com débitos.
- **Seção de Agendamentos de Hoje**: carrega via `adminTodayAppointmentsProvider`.

### 12.2 Agendamentos de Hoje

- Badge de data: `"Hoje, {displayDateLong}"`.
- Para cada agendamento, card exibe `"${clientName} • ${serviceName}"`.
- **Regras de botões**:
  - **Reagendar**: desabilitado se `_isPastStartTime` (horário já passou).
  - **No-show**: sempre visível e habilitado.
  - **Cancelar**: sempre visível e habilitado.
- Status mapeados: `scheduled`/`rescheduled` → "Confirmado"; outros → "Pendente".

### 12.3 Agenda por Data (FAB)

- **Date picker**: seleciona uma data → após 100ms abre lista de agendamentos daquela data.
- **Sheet de data**: título `"Agenda: {dd/MM/yyyy}"`. Botão voltar retorna ao date picker após 100ms.
- **Regra de no-show por data**: botão no-show só é mostrado se `_isTodayOrBefore(startTime)`.
  - Condição: `local.year < now.year` ou mesmo ano/mês e `day <= now.day`.
- **Regra de remarcação por data**: botão desabilitado se `_isPastStartTime`.
- **Comportamento de reopen**: ao tocar em remarcar/no-show/cancelar, o sheet fecha, a ação executa, e no `finally` (sempre) reabre o sheet da mesma data após 100ms.

### 12.4 Remarcação (Admin)

- **Verificação de 24h**: `isWithin24Hours = startTime.toUtc().isBefore(now.toUtc() + 24h)`.
  - **Se NÃO estiver dentro de 24h**: abre `BookingFlow.startReschedule` diretamente com `applyFee: false`, sem mostrar action sheet.
  - **Se ESTIVER dentro de 24h**: mostra `showAppointmentActionSheet` com toggle de taxa (15%).
- **Pré-seleção de serviço**: busca lista de serviços e encontra o primeiro cujo `name == appointment.serviceName`; se não encontrar, usa `services.first`.
- Após sucesso: refresh em `adminTodayAppointmentsProvider`; se `applyFee`, também refresh em `adminPendingDebtsProvider`.

### 12.5 Cancelamento (Admin)

- Exibe `showCancelAppointmentSheet` com `isAdmin: true`.
- Toggle de taxa (35%) visível se dentro de 24h.
- Ao confirmar: `POST /appointments/{id}/cancel` com `applyLateCancellationFee`.
- Se data for hoje, refresh em `adminTodayAppointmentsProvider`.
- Se `applyLateCancellationFee`, refresh em `adminPendingDebtsProvider`.

### 12.6 No-Show (Admin)

- Exibe `showAppointmentActionSheet` com `action: noShow`, `isAdmin: true`.
- Toggle de taxa (50%) sempre visível para admin.
- Ao confirmar: `POST /appointments/{id}/noshow` com `applyNoShowFee`.
- Se data for hoje, refresh em `adminTodayAppointmentsProvider`.
- **Sempre** faz refresh em `adminPendingDebtsProvider`.
- Mensagem de sucesso:
  - Com multa: "No-show registrado com sucesso. Multa de 50% aplicada ao cliente."
  - Sem multa: "No-show registrado sem multa."

### 12.7 FABs do Admin

Coluna de 3 FABs, do topo para base:

1. **Débitos** (`attach_money`, vermelho): abre lista de clientes com débitos.
2. **Futuros** (`calendar_month`, primária): abre date picker de agendamentos futuros.
3. **Novo Agendamento** (`add`, primária): abre `BookingFlow.start`.

### 12.8 Novo Agendamento (Admin via FAB)

- Carrega lista de clientes via `AdminClientsService.getClients()`.
- Regra de subtítulo do cliente: se `email == displayName`, subtítulo é `null`; senão, exibe `email`.
- Após confirmação, refresh em `adminTodayAppointmentsProvider`.

### 12.9 Profile Sheet (Admin)

- Título "Editar Perfil", altura flexível.
- Avatar com iniciais e badge de edição.
- Botão "Férias e Ausências": fecha sheet e inicia `AdminAbsencesFlow`.
- Botão "Sair da Conta": chama `AuthService().logout()` e navega para `/`.

### 12.10 Ausências (Admin)

- **Criar**: `POST /absences` com `StartDate` e `EndDate`.
  - Validação client-side: `EndDate >= StartDate`.
  - Validação de overlap: não pode haver ausência existente no mesmo período.
- **Listar**: `GET /absences` com paginação (`Page`, `PageSize`) e filtro `Future`.
- **Deletar**: `DELETE /absences/{id}`.

---

## 13. Tabela de Taxas e Multas

| Ação          | Prazo        | Taxa Cliente    | Taxa Admin/Manager |
| ------------- | ------------ | --------------- | ------------------ |
| Cancelamento  | > 24h        | 0%              | 0%                 |
| Cancelamento  | ≤ 24h        | 35% obrigatória | 35% opcional       |
| Reagendamento | > 24h        | 0%              | 0%                 |
| Reagendamento | ≤ 24h        | 15% obrigatória | 15% opcional       |
| No-Show       | Após horário | —               | 50% opcional       |

---

## 14. Regras Transversais

### 14.1 Tratamento de Erros (Frontend)

- Todos os erros exibem `AppSnackBar` com prefixo `"Exception: "` removido.
- Todo `async` operation verifica `context.mounted` (ou `mounted` em `StatefulWidget`) antes de mostrar UI.
- Erro de conexão: "Erro de conexão. Verifique sua internet ou tente mais tarde."

### 14.2 Tratamento de Erros (Backend)

- `DioException` → extrai mensagens do campo `errors[]` (prioriza `reason` ou `message`), depois `message`, fallback por status code.

### 14.3 Navegação

- 3 rotas principais: `/` (login), `/client` (home cliente), `/admin` (home admin).
- Sem GoRouter; usa `MaterialApp.routes` simples.
- Logout sempre navega para `/` removendo toda a pilha (`pushNamedAndRemoveUntil`).

### 14.4 Providers e Estado

- Riverpod code-gen: `@riverpod` + `part '*.g.dart'`.
- `*.g.dart` commitados; devem ser regenerados após mudar providers (`dart run build_runner build --delete-conflicting-outputs`).

---

_Fim do documento._
