# 📌 Propósito deste arquivo

Este documento define o **contexto oficial do projeto BookingApp** para uso por assistentes de IA (Claude, Cursor, etc).

Ele contém:

- Regras arquiteturais **obrigatórias**
- Padrões de implementação
- Restrições técnicas
- Convenções de código

⚠️ Tudo aqui deve ser seguido rigorosamente ao gerar código.

---

# 🧠 Contexto do Sistema

O BookingApp é um sistema de agendamento baseado em:

- Vertical Slice Architecture
- Domain-Driven Design (DDD)
- Clean Code + SOLID
- Result Pattern (sem exceptions para fluxo)

Stack:

- .NET 9 (ASP.NET Core Minimal API)
- Angular
- PostgreSQL
- Redis + FusionCache
- Docker + Kubernetes

---

# 🚫 Regras Críticas (NÃO QUEBRAR)

## 1. Regra de dependência

```

API → Domain ← Infrastructure

```

- ❌ API NÃO acessa Infrastructure diretamente
- ❌ Domain NÃO conhece nenhuma outra camada
- ✔ Infrastructure implementa interfaces do Domain

---

## 2. Vertical Slice obrigatório

Toda feature DEVE seguir:

```

Feature/
├── Command.cs
├── Handler.cs
├── Endpoint.cs
└── Validator.cs

```

❌ Proibido criar Services genéricos ou camadas extras desnecessárias  
❌ Proibido lógica fora do Handler/Domain  

---

## 3. Result Pattern

- ❌ NÃO usar exceptions para fluxo de negócio
- ✔ Sempre retornar `Result<T>`
- ✔ Falhas devem ser explícitas

---

## 4. Sem acesso direto ao banco

- ❌ Nada de DbContext fora da Infrastructure
- ✔ Sempre via interfaces do Domain (Repository)

---

## 5. Sem lógica no Endpoint

- Endpoint apenas:
  - recebe request
  - chama MediatR
  - retorna response

---

## 6. Validação obrigatória

- ✔ FluentValidation em TODOS os commands
- ✔ Nunca validar manualmente no handler (exceto regra de negócio)

---

## 7. Return First

- Evitar if aninhado
- Validar e retornar erro imediatamente

---

# 🏗️ Estrutura do Projeto

```

server/
├── BookingApp.API
├── BookingApp.Domain
└── BookingApp.Infrastructure
└──tests/
├──├── UnitTests
├──├── IntegrationTests
└──└── ArchTests

```

---

# 🧩 Padrão de Implementação

## Command

- Representa intenção
- Imutável

## Handler

Responsável por:

- Orquestrar domínio
- Aplicar regras de negócio
- Persistir via repository
- Retornar Result

## Validator

- Validação estrutural (não regra de negócio)

## Endpoint

- Minimal API
- Sem lógica

---

# 🧬 Domínio

## Aggregates principais

- Appointment
- SwapRequest
- User
- Service
- Payment
- DebtBalance

---

## Regras importantes

### Appointment

- Cancelamento só com 24h
- NoShow gera multa (35%)

### Swap

- Anônimo
- Expiração via lazy evaluation
- Sem scheduler

### Debt

- Pode bloquear agendamento (configurável)
- Pode ser perdoado pelo admin (com auditoria)

---

# 🔐 Autenticação

- JWT próprio
- MFA com TOTP
- Refresh token com rotação

❌ Não usar Identity externo

---

# 💾 Persistência

- PostgreSQL via EF Core
- Migrations obrigatórias

---

# ⚡ Cache

- FusionCache (L1 + L2 Redis)

## Regras:

- Sempre usar cache para leitura de slots
- Invalidar por TAG (nunca manual key)

---

# 📡 Mensageria

- Redis Pub/Sub
- Usado apenas para Swap

---

# 💰 Pagamentos

- Webhook obrigatório
- Idempotência obrigatória
- Validação de assinatura obrigatória

---

# 🧪 Testes

## Unit

- Testa domínio

## Integration

- Testa slices com banco real (Testcontainers)

## Architecture

- Garante regras de dependência

---

# 🧱 Infraestrutura

## Docker

- Multi-stage build
- Nunca rodar como root

## Kubernetes

- HPA ativo
- Health checks obrigatórios:
  - `/health/live`
  - `/health/ready`

---

# 🧭 Diretrizes para geração de código

## Sempre:

- Criar código dentro de um slice
- Usar MediatR
- Usar FluentValidation
- Retornar Result<T>
- Seguir DDD

---

## Nunca:

- Criar Service layer genérica
- Acessar banco direto
- Usar exception como fluxo
- Misturar responsabilidades
- Criar lógica fora do domínio

---

# 🧠 Padrões de decisão

## Quando usar Domain

- Regra de negócio
- Estado
- Transição

## Quando usar Handler

- Orquestração
- Integração entre componentes

## Quando usar Infrastructure

- Banco
- Cache
- APIs externas

---

# ⚠️ Anti-patterns proibidos

- God classes
- Services genéricos tipo `UserService`
- Lógica no Controller/Endpoint
- Regras espalhadas fora do domínio
- Uso excessivo de static
- DTO sendo usado como entidade

---

# 📌 Pendências do projeto

- Definir TTL do Swap (sugestão: 2h)
- Definir comportamento do AbsenceDay
- Escolher gateway de pagamento
- Definir política de logs
- Avaliar notificações (email/push)

---

# 📎 Observação final

Este projeto prioriza:

- Simplicidade
- Clareza
- Baixo acoplamento
- Alta manutenibilidade

Se houver dúvida na implementação:

👉 Prefira a solução **mais simples, explícita e orientada ao domínio**

---

# 🏷️ Convenções de Nomeação (Clean Code)

A nomeação no projeto deve seguir rigorosamente os princípios de **Clean Code**, priorizando clareza, intenção e legibilidade.

## Princípios gerais

- Nomes devem **explicar o propósito**, não a implementação
- Evitar abreviações desnecessárias
- Evitar nomes genéricos (`data`, `info`, `manager`, `helper`)
- Código deve ser **autoexplicativo** (sem necessidade de comentários)
- Preferir nomes mais longos e claros ao invés de curtos e ambíguos

---

## Commands

- Devem representar uma **ação clara**
- Sempre iniciar com verbo

✅ Exemplos:

- `BookAppointmentCommand`
- `CancelAppointmentCommand`
- `CreateSwapRequestCommand`

❌ Evitar:

- `AppointmentCommand`
- `DoBooking`
- `ProcessData`

---

## Handlers

- Nome deve corresponder exatamente ao Command

✅ Padrão:

```

<CommandName>Handler

```

Exemplo:

- `BookAppointmentCommandHandler`

---

## Validators

- Nome deve corresponder ao Command

✅ Padrão:

```

<CommandName>Validator

```

---

## Endpoints

- Nome deve refletir a ação exposta

✅ Exemplos:

- `BookAppointmentEndpoint`
- `CancelAppointmentEndpoint`

---

## Métodos

- Devem ser verbos claros
- Devem expressar intenção

✅ Exemplos:

- `ValidateAvailability`
- `CalculateDebtAmount`
- `CanBeCancelled`

❌ Evitar:

- `Process`
- `Handle`
- `DoStuff`

---

## Variáveis

- Nome deve representar claramente o conteúdo

✅ Exemplos:

- `appointmentDate`
- `availableSlots`
- `clientDebtBalance`

❌ Evitar:

- `data`
- `list`
- `obj`

---

## Booleans

- Devem ser perguntas claras (true/false)

✅ Exemplos:

- `isAvailable`
- `hasPendingDebt`
- `canBeCancelled`

---

## Classes de domínio

- Nomeadas por **conceitos de negócio**, não técnicos

✅ Exemplos:

- `Appointment`
- `SwapRequest`
- `DebtBalance`

❌ Evitar:

- `AppointmentEntity`
- `SwapModel`
- `DebtDTO`

---

## Interfaces

- Devem representar comportamento

✅ Exemplos:

- `IAppointmentRepository`
- `IPaymentGateway`
- `ICurrentUserService`

---

## Evitar completamente

- Hungarian notation (`strName`, `intId`)
- Prefixos desnecessários (`tbl_`, `obj_`)
- Sufixos genéricos (`Helper`, `Manager`, `Utils`)
- Nomes que não agregam contexto (`Common`, `Base`, `Core`)

---

## 📦 Contexto e Evitação de Redundância

Quando classes estiverem **aninhadas em um mesmo contexto (feature/pasta)**, deve-se evitar repetição desnecessária de nomes.

O contexto já é definido pela pasta/feature — não deve ser duplicado nos nomes.

---

### Regra

👉 **Não repetir o nome do contexto no nome das classes internas**

---

### Exemplo incorreto

```

Features/Users/GetUser/

* GetUserCommand
* GetUserCommandHandler
* GetUserValidator

```

Ou:

```

UserHandler
UserValidator

```

---

### Exemplo correto

```

Features/Users/GetUser/

* Command
* Handler
* Validator
* Endpoint

```

👉 O contexto **GetUser** já define a intenção

---

### Para casos mais específicos

Quando houver variação dentro da mesma feature:

#### ❌ Evitar:

```

GetUser/
GetUserById/
GetUserByEmail/

```

#### ✅ Preferir:

```

GetUser/
├── ById/
├── ByEmail/

```

Ou nomes mais diretos:

```

GetUser/
├── GetById/
├── GetByEmail/

```

---

### Classes dentro dessas variações

```

GetUser/ById/

* Command
* Handler
* Validator

```

---

### Benefícios

- Reduz poluição visual
- Evita nomes gigantes
- Melhora navegação no código
- Mantém consistência com Vertical Slice

---

## 📌 Regra complementar

Se a leitura completa (pasta + classe) fizer sentido:

```

Users/GetUser/Handler

```

👉 então o nome está correto

Se precisar repetir contexto para entender:

👉 o design está errado

---

## Regra final

Se o nome não deixa claro:

👉 **o que é**
👉 **o que faz**
👉 **por que existe**

então ele está errado.