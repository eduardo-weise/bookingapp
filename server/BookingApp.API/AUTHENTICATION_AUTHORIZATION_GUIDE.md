# Sistema de Autenticação e Autorização - BookingApp

## 📋 Resumo Executivo

O sistema funciona em **3 camadas**:

```
1. AUTENTICAÇÃO (Login) → JWT Token com Claims
           ↓
2. TOKEN VALIDATION → FastEndpoints valida o JWT
           ↓
3. AUTORIZAÇÃO (Policy) → Verifica Role via Policy
```

---

## 🔐 Fluxo Completo de Autenticação e Autorização

### 1️⃣ **LOGIN** - Geração do JWT Token

**Arquivo**: `LoginEndpoint.cs`

```
Usuário [Email + Senha]
           ↓
    ✅ Validar credenciais
           ↓
    📋 Extrair dados do usuário:
       - UserId (NameIdentifier)
       - Email
       - Role (Admin, Manager, Client)
           ↓
    🔑 Gerar JWT Token com Claims:
       {
         "sub": "userId",                    // NameIdentifier
         "email": "user@example.com",
         "http://schemas.microsoft.com/ws/2008/06/identity/claims/role": "Manager"
       }
           ↓
    💾 Armazenar RefreshToken no banco
           ↓
    ✅ Retornar JWT Token ao cliente
```

**Exemplo do que deve estar no LoginEndpoint:**
```csharp
var claims = new List<Claim>
{
    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
    new Claim(ClaimTypes.Email, user.Email),
    new Claim(ClaimTypes.Role, user.Role)  // ← IMPORTANTE: Role deve estar aqui!
};

var token = new JwtSecurityToken(
    claims: claims,
    // ... outras configurações
);
```

---

### 2️⃣ **VALIDAÇÃO DO TOKEN** - FastEndpoints Valida JWT

**Arquivo**: `Program.cs`

```csharp
.AddAuthenticationJwtBearer(o => o.SigningKey = configuration["JwtOptions:SecretKey"])
```

FastEndpoints automaticamente:
- ✅ Valida a assinatura do JWT
- ✅ Extrai os Claims
- ✅ Popula `User` (HttpContext.User)
- ✅ Disponibiliza para uso no endpoint

---

### 3️⃣ **AUTORIZAÇÃO** - Policies Verificam Roles

**Arquivo**: `AuthExtensions.cs`

```csharp
services.AddAuthorizationBuilder()
    .AddPolicy("AdminsOnly", x => x.RequireRole("Admin").RequireClaim("UserId"))
    .AddPolicy("ManagersOnly", x => x.RequireRole("Manager").RequireClaim("UserId"))
    .AddPolicy("ClientsOnly", x => x.RequireRole("Client").RequireClaim("UserId"))
    .AddPolicy("AdminOrManager", x => x.RequireRole("Admin", "Manager").RequireClaim("UserId"));
```

**Como funciona:**
1. Quando você adiciona `Policies("AdminOrManager")` em um endpoint
2. FastEndpoints intercepta a request ANTES de executar o `HandleAsync()`
3. Verifica se o usuário tem role "Admin" OU "Manager"
4. Se ✅ tem role → executa o endpoint
5. Se ❌ não tem role → retorna 403 Forbidden

---

## 🎯 Exemplo Prático: GetDebtBalancesEndpoint

### ❌ ANTES (Sem Autorização)

```csharp
public sealed class GetDebtBalancesEndpoint(ApplicationDbContext dbContext)
    : EndpointWithoutRequest<List<DebtBalanceResponse>>
{
    public override void Configure()
    {
        Get("/payments/debts");
        Tags("Payments");
        Options(x => x.WithName("GetDebtBalances"));
        // ❌ Qualquer um consegue acessar!
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        // ... executa mesmo sem autorização
    }
}
```

### ✅ DEPOIS (Com Autorização)

```csharp
public sealed class GetDebtBalancesEndpoint(ApplicationDbContext dbContext)
    : EndpointWithoutRequest<List<DebtBalanceResponse>>
{
    public override void Configure()
    {
        Get("/payments/debts");
        Tags("Payments");
        Options(x => x.WithName("GetDebtBalances"));
        Policies("AdminOrManager");  // ✅ Apenas Admin ou Manager!
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        // ... só chega aqui se for Admin ou Manager
        
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdString, out var clientId))
        {
            await Send.UnauthorizedAsync(ct);
            return;
        }

        var debts = await dbContext.DebtBalances
            .AsNoTracking()
            .Where(d => d.ClientId == clientId)
            .OrderByDescending(d => d.CreatedAt)
            .Select(d => new DebtBalanceResponse(d.Id, d.AppointmentId, d.Amount, d.Status, d.CreatedAt))
            .ToListAsync(ct);

        await Send.OkAsync(debts, cancellation: ct);
    }
}
```

---

## 🔧 Passo a Passo: Aplicar Autorização a um Novo Endpoint

### 1. Identifique qual role(s) pode acessar o endpoint

```
Exemplo: "GetUserProfile" → Apenas o usuário (Client) pode ver seu próprio perfil
         "GetDebtBalances" → Admin e Manager podem acessar
         "CreateSwapRequest" → Apenas Client
         "ApproveAppointment" → Apenas Manager/Admin
```

### 2. Escolha a Policy correta

| Policy | Quem acessa |
|--------|-------------|
| `AdminsOnly` | Apenas Admin |
| `ManagersOnly` | Apenas Manager |
| `ClientsOnly` | Apenas Client |
| `AdminOrManager` | Admin ou Manager |
| `AdminOrClient` | Admin ou Client (precisa criar) |
| `AnyAuthenticated` | Qualquer usuário autenticado (sem Policies) |

### 3. Adicione ao seu endpoint

```csharp
public override void Configure()
{
    Get("/your-endpoint");
    Policies("AdminOrManager");  // ← Aqui!
}
```

### 4. Se nenhuma policy existente encaixa, crie uma em AuthExtensions.cs

```csharp
.AddPolicy("AdminOrClient", x => x.RequireRole("Admin", "Client").RequireClaim("UserId"))
```

---

## 📝 Checklist: O que você precisa fazer em cada endpoint

```
[ ] 1. Identificar qual role(s) pode acessar
[ ] 2. Adicionar a Policy no Configure()
[ ] 3. Testar com token de cada role
     - Admin token → deve funcionar ✅
     - Manager token → deve funcionar (se na policy) ✅
     - Client token → deve negar (se não na policy) ❌
```

---

## 🔑 Como Acessar dados do usuário dentro do endpoint

```csharp
// NameIdentifier = UserId
var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
var userId = Guid.Parse(userIdString);

// Email
var email = User.FindFirstValue(ClaimTypes.Email);

// Role
var role = User.FindFirstValue(ClaimTypes.Role);

// Verificar se tem claim
var hasClaim = User.HasClaim(c => c.Type == "UserId");

// Obter claims do usuário
var claims = User.Claims;
```

---

## 🚀 Resumo das Mudanças Realizadas

### 1. **AuthExtensions.cs**
✅ Corrigida sintaxe  
✅ Adicionada extension method correta  
✅ Adicionada policy "AdminOrManager"

### 2. **User.cs (Domain)**
✅ Adicionada propriedade `Role` (string)  
✅ Adicionado método `AssignRole()`  
✅ Construtor agora aceita role (padrão: "Client")

### 3. **Program.cs**
✅ Adicionado `.AddAuth()` na cadeia de registros

### 4. **GetDebtBalancesEndpoint.cs** (Exemplo)
✅ Adicionado `Policies("AdminOrManager")`

---

## 🎓 Próximos Passos

1. **Garantir que LoginEndpoint coloca o Role no JWT** - Verificar se está incluindo `ClaimTypes.Role`
2. **Aplicar autorização em todos os endpoints** seguindo o padrão
3. **Testar cada endpoint** com tokens de diferentes roles
4. **Documentar permissões** em cada endpoint (qual role pode acessar)

---

## ❓ Dúvidas Frequentes

### P: Por que um usuário precisa ter APENAS UM role?
**R:** Para manter simplicidade. Se precisar de permissões granulares no futuro, pode-se usar a classe `Role` (não comentada) com permissões.

### P: Posso ter múltiplos roles por usuário?
**R:** Sim! Você precisaria:
1. Criar tabela `UserRole` (relação many-to-many)
2. Adicionar Claims múltiplos no JWT login
3. Ajustar as policies conforme necessário

### P: O que acontece se um Client tentar acessar GetDebtBalances?
**R:** FastEndpoints intercepta antes do `HandleAsync()` e retorna **403 Forbidden**.

### P: Preciso incluir a classe `Role` comentada?
**R:** Não por enquanto. Você está usando apenas string roles. Se precisar de permissões granulares no futuro, pode usar.

---

## 📚 Arquivos Modificados

```
✅ BookingApp.API/Extentions/AuthExtensions.cs
✅ BookingApp.Domain/Entities/User.cs
✅ BookingApp.API/Program.cs
✅ BookingApp.API/Features/Payments/GetDebtBalances/GetDebtBalancesEndpoint.cs
```
