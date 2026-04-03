Perfeito — vou desenhar isso **totalmente alinhado com teu padrão (Vertical Slice + Result + sem ruído)**.

---

# 🧩 Feature: AcceptTerms

## 📁 Estrutura

```
Features/Users/AcceptTerms/

- Command
- Handler
- Validator
- Endpoint
```

---

# 🧠 Domínio (regra central)

## Entidade (conceito)

```csharp
public class UserTermsAcceptance
{
    public Guid UserId { get; private set; }
    public string Version { get; private set; }
    public DateTime AcceptedAt { get; private set; }

    public static UserTermsAcceptance Create(Guid userId, string version)
    {
        return new UserTermsAcceptance
        {
            UserId = userId,
            Version = version,
            AcceptedAt = DateTime.UtcNow
        };
    }
}
```

---

# 🧱 Slice completo

## Command

```csharp
public class AcceptTerms
{
    public class Command(string version)
    {
        public string Version { get; set; } = version;

        public ValidationResult Validate()
        {
            return new Validator().Validate(this);
        }

        public class Validator() : AbstractValidator<Command>
        {
            public Validator()
            {
                RuleFor(x => x.Version).NotEmpty();
            }
        }
    }
```

---

## Handler

```csharp
    public class Handler(
        ICurrentUserService currentUser,
        IUserTermsRepository repository
    )
    {
        public async Task<Result> Handle(Command request, CancellationToken cancellationToken)
        {
            var userId = currentUser.UserId;

            var acceptance = UserTermsAcceptance.Create(userId, request.Version);

            var saveResult = await repository.SaveAsync(acceptance);

            if (saveResult.IsFailure)
                return saveResult.Failure;

            return Result.Success();
        }
    }
}
```

---

## Endpoint

```csharp
app.MapPost("/terms/accept", async (
    AcceptTerms.Command command,
    AcceptTerms.Handler handler,
    CancellationToken ct) =>
{
    var result = await handler.Handle(command, ct);

    return result.IsFailure
        ? Results.BadRequest(result.Failure)
        : Results.Ok();
});
```

---

# 🔐 Enforcement (ponto mais importante)

Aqui está o diferencial do teu sistema.

## 🧠 Regra global

> Usuário NÃO pode usar o sistema sem aceitar o termo atual

---

## ✅ Melhor abordagem: Pipeline Behavior (MediatR)

### Behavior

```csharp
public class TermsAcceptanceBehavior<TRequest, TResponse>(
    ICurrentUserService currentUser,
    IUserTermsRepository repository,
    ITermsService termsService
)
{
    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId;

        var currentVersion = termsService.GetCurrentVersion();

        var acceptedVersion = await repository.GetAcceptedVersionAsync(userId);

        if (acceptedVersion != currentVersion)
        {
            return (TResponse)(object)Result.Failure("TermsNotAccepted");
        }

        return await next();
    }
}
```

---

## 📌 Onde aplicar

- Registrar no pipeline global
- Ou aplicar apenas em commands sensíveis:

### Exemplo:

- BookAppointment
- InitiatePayment
- SwapRequest

---

## 🚫 Exceções (não validar termo)

- Login
- Register
- RefreshToken
- AcceptTerms

---

# 🧠 TermsService (fonte da verdade)

```csharp
public class TermsService()
{
    public string GetCurrentVersion()
        => "v1.0";
}
```

👉 Pode evoluir depois para:

- banco
- config
- CDN

---

# 📊 Repositório

```csharp
public interface IUserTermsRepository
{
    Task<Result> SaveAsync(UserTermsAcceptance acceptance);
    Task<string?> GetAcceptedVersionAsync(Guid userId);
}
```

---

# ⚠️ Pontos importantes

## 1. Versionamento obrigatório

Mudou regra → muda versão → força novo aceite

---

## 2. Não sobrescrever histórico

- Sempre manter registros
- Último aceite pode ser consultado

---

## 3. Simples > complexo

Sem:

- scheduler
- cache
- eventos

👉 só leitura direta resolve

---

# 🚀 Fluxo final

```
Login
 ↓
Pipeline detecta Terms não aceito
 ↓
Retorna erro: TermsNotAccepted
 ↓
Frontend redireciona
 ↓
POST /terms/accept
 ↓
Libera uso
```

---

# 🔥 Resultado

Você ganha:

- ✔ proteção legal
- ✔ enforcement centralizado
- ✔ arquitetura limpa (DDD + Slice)
- ✔ zero acoplamento estranho
- ✔ fácil evolução

---

Se quiser, posso evoluir isso pra:

- resposta padronizada (`ErrorCode = TERMS_NOT_ACCEPTED`)
- integração com frontend Angular (guard/interceptor)
- versionamento dinâmico via banco/cache

Isso fecha o fluxo de ponta a ponta.
