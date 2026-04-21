# BookingApp — UI/UX Spec Prompt v2 (Figma)

## Meta

```
Product: BookingApp — agendamento de serviços
Platform: Mobile (iOS + Android), design system único
Style: Clean, moderno, acessível
Primary color: #E8622A (coral/laranja)
Neutral: #F5F5F5 (background), #FFFFFF (cards), #2C2C2C (texto)
Status colors: #27AE60 (confirmado), #F5A623 (pendente), #E74C3C (cancelado/débito)
Font: Inter
Corner radius padrão: 12px (cards), 24px (bottom sheets), 8px (inputs), 50px (botões primários)
Shadows: soft — 0 2px 12px rgba(0,0,0,0.08)
Bottom sheet overlay: rgba(0,0,0,0.45) com blur 2px
```

---

## 1. Design tokens

```
Colors/
  brand-primary:     #E8622A
  brand-light:       #FAE5DC
  surface:           #FFFFFF
  background:        #F5F5F5
  text-primary:      #2C2C2C
  text-secondary:    #888888
  text-inverse:      #FFFFFF
  status-confirmed:  #27AE60
  status-pending:    #F5A623
  status-cancelled:  #E74C3C
  status-debt:       #E74C3C

Spacing/ (8pt grid)
  xs: 4   sm: 8   md: 16   lg: 24   xl: 32   2xl: 48

Typography/
  heading-1: Inter Bold 24px / lh 32px
  heading-2: Inter SemiBold 18px / lh 26px
  heading-3: Inter SemiBold 16px / lh 22px
  body:      Inter Regular 14px / lh 20px
  caption:   Inter Regular 12px / lh 16px
  label:     Inter Medium 13px / lh 18px
  button:    Inter SemiBold 16px / lh 24px

Radius/
  sm: 8px   md: 12px   lg: 20px   xl: 24px   full: 50px

Elevation/
  card:  0 2px 12px rgba(0,0,0,0.08)
  sheet: 0 -4px 24px rgba(0,0,0,0.12)
```

---

## 2. Componentes base

```
Button/
  Primary:   fill brand-primary, text-inverse, radius full, height 52px, padding h 24px
  Secondary: border 1.5px brand-primary, text brand-primary, mesmo shape
  Ghost:     sem borda, text brand-primary
  Danger:    fill #FFF0F0, text status-cancelled, border status-cancelled
  Icon:      circle 44px, bg brand-light, ícone brand-primary 20px — usado para ações rápidas

Input/
  height: 52px, bg #F5F5F5, radius md, padding h 16px
  label acima (label token), placeholder text-secondary
  trailing icon: 20x20, text-secondary
  state focus: border 1.5px brand-primary, bg white
  state error: border 1.5px status-cancelled

Avatar/
  sizes: 40px, 56px, 80px
  shape: circular
  edit badge: 20px circle, brand-primary, ícone lápis branco 10px, posição bottom-right

Card/
  bg surface, radius md, padding md, shadow card
  full-width por padrão

Badge/
  height 22px, padding h 8px, radius full, caption token
  variants: confirmed (bg #E8F5E9, text status-confirmed)
            pending   (bg #FFF8E1, text status-pending)
            cancelled (bg #FFF0F0, text status-cancelled)

Bottom Sheet/
  bg surface, radius xl apenas no topo (top-left + top-right)
  handle: 4x36px, #E0E0E0, centrado, margin-top 12px
  padding interno: lg
  overlay atrás: rgba(0,0,0,0.45) blur 2px
  altura definida pelo conteúdo — sem altura fixa global
  exceção: sheet de calendário = altura exata do datepicker + handle + padding

Section Header/
  título heading-2 text-primary + ação à direita brand-primary body

Service Card/ ← NOVO
  layout horizontal full-width
  lado esquerdo (flex 1):
    heading-3 nome do serviço
    caption text-secondary descrição breve (max 2 linhas, truncate)
    Row metadata: ícone relógio 14px + duração · ícone tag 14px + valor em bold brand-primary
  lado direito:
    Button Icon "Agendar" — circle 44px bg brand-light, ícone calendário brand-primary
  separador 1px #F0F0F0 entre cards

Appointment Card/
  layout: ícone serviço (40px bg brand-light radius md) | info | badge | menu ⋮
  info: heading-3 nome serviço + caption cliente ou localização
  metadata row: ícone calendário + data · ícone relógio + hora · ícone ampulheta + duração
  action row: Button Secondary "Reagendar" + Button Danger "Cancelar"

Admin Appointment Card/ ← NOVO
  layout: faixa colorida esquerda (4px, cor do status) | info | badge | menu ⋮
  info: heading-3 nome serviço + caption nome do cliente
  metadata row: ícone relógio + hora início-fim · ícone ampulheta + duração
  sem action row — ações via menu ⋮

Debt Card/ (scroll horizontal na home admin)
  width: 160px, radius md, shadow card, padding md
  Avatar 32px + nome body bold + serviço caption
  Badge status + valor body bold text-primary
  card inteiro clicável

Calendar/
  header: mês/ano heading-2 + chevrons
  dias da semana: caption text-secondary uppercase
  dia normal: 36x36px body
  dia hoje: bg brand-light text brand-primary bold
  dia selecionado: bg brand-primary text-inverse radius full
  dia sem vagas: ponto vermelho abaixo do número
  dia passado: text #CCCCCC
  legenda: • vermelho = sem vagas · • cinza = passado (caption abaixo do calendário)

Time Slot/
  grid 3 colunas, height 44px, radius md, border 1px #E0E0E0
  selected: border 2px brand-primary, bg brand-light, text brand-primary
  unavailable: bg #F5F5F5, text #CCCCCC

Debt Banner/
  bg status-cancelled, radius md, padding md
  ícone alerta 24px branco | textos | botão "Pagar" bg white text status-cancelled
  título body bold text-inverse · valor heading-2 bold text-inverse · subtítulo caption opacity 0.8

Quick Action Row/ ← NOVO (usado nas homes sem bottom nav)
  Row horizontal centralizado de ações principais
  cada ação: coluna com Button Icon (56px) + label caption text-secondary abaixo
  gap entre ações: xl
  bg surface, padding v md, shadow card, radius md
```

---

## 3. Fluxo — Autenticação

```
Frame: Login (375x812px)

Background superior (40% altura):
  fill brand-primary
  círculos decorativos opacity 0.15
  ícone calendário 64px bg white radius lg shadow
  "ServiçoApp" heading-1 text-inverse
  "Agende seus serviços com facilidade" body text-inverse opacity 0.85

Card branco (y 35% da tela, radius xl top):
  padding lg
  "Entrar na sua conta" heading-2, margin-bottom lg
  Input email (trailing envelope)
  Input senha (trailing olho toggle)
  Row: checkbox "Lembrar-me" | link "Esqueceu a senha?" brand-primary
  Button Primary "Entrar" full-width margin-top md
  Divider "ou" margin v md
  Row: "Não tem uma conta?" body text-secondary + "Cadastre-se" brand-primary SemiBold

---

Bottom Sheet — Criar Conta (altura: conteúdo, ~75% tela):
  handle bar
  Row: "Criar Conta" heading-2 | X ghost
  Input "Nome Completo" (trailing pessoa)
  Input "Email" (trailing envelope)
  Input "Telefone" (trailing telefone)
  Input "Senha" (trailing olho toggle)
  Input "Confirmar Senha" (trailing olho toggle)
  Button Primary "Criar Conta" full-width margin-top lg

---

Bottom Sheet — Recuperar Senha (altura: conteúdo, ~50% tela):
  handle bar
  ícone chave 48px bg brand-light radius full centralizado margin-bottom md
  "Recuperar Senha" heading-2 centralizado
  body text-secondary centralizado (instrução de envio de link)
  Input "Email" margin-top md
  Button Primary "Enviar Link de Recuperação" full-width margin-top md
  Row centralizado: ← link ghost "Voltar ao login"
```

---

## 4. Fluxo — Área do cliente

```
Frame: Home Cliente (375x812px)

Safe area top padding

─── Seção 1 — Header ──────────────────────────────
  Row: "Olá, {Nome}" heading-1 | ícone sino direita (badge ponto vermelho)
  caption "Bem-vindo ao seu painel" text-secondary
  Avatar 80px centralizado + edit badge

─── Quick Action Row ──────────────────────────────
  3 ações em row centralizado:
    [Agendar]  ícone calendário-plus
    [Histórico] ícone lista
    [Perfil]   ícone pessoa
  cada ação abre um bottom sheet correspondente (ver abaixo)

─── Seção 2 — Debt Banner ─────────────────────────
  Exibir apenas se houver débito pendente
  Componente Debt Banner

─── Seção 3 — Próximos Agendamentos ───────────────
  Section Header "Próximos Agendamentos" + "Ver todos"
  Lista vertical de Appointment Cards
  cada card: badge status + metadata + ações (Reagendar | Cancelar)
  estado vazio: ilustração + "Nenhum agendamento" caption + Button Primary "Agendar agora"

---

Bottom Sheet — Agendar (acionado pelo Quick Action "Agendar" ou estado vazio):
  altura: conteúdo (lista de serviços + padding)
  handle bar
  Row: "Agendar Serviço" heading-2 | X ghost
  Busca (opcional): Input com ícone lupa, placeholder "Buscar serviço..."
  Lista vertical de Service Cards (scroll interno):
    cada card: nome + descrição (2 linhas) + duração + valor + Button Icon "Agendar" direita
    ao tap no Button Icon → dismiss este sheet → abre Sheet Calendário

---

Bottom Sheet — Calendário (altura: exata do datepicker + handle + padding):
  handle bar
  Row: "Selecione a Data" heading-2 | X ghost
  Componente Calendar (sem scroll, tamanho fixo do calendário mensal)
  Legenda abaixo do calendário
  ao tap em data disponível → abre Sheet Horários (replace ou stack)

---

Bottom Sheet — Horários (altura: conteúdo, ~45% tela):
  handle bar
  Row: "Horários em {data}" heading-2 | X ghost (volta ao calendário via chevron ←)
  Grid 3 colunas Time Slots
  Button Primary "Confirmar Agendamento" full-width sticky bottom
  margin-top md

---

Bottom Sheet — Opções do Agendamento (altura: conteúdo, ~35% tela):
  acionado pelo ⋮ no Appointment Card
  handle bar
  "Opções" heading-2
  Lista de opções com ícone + label (padding v md, separador entre cada):
    Reagendar  (ícone calendário, text-primary)
    Pagar      (ícone cartão, text-primary) — apenas se débito pendente
    Cancelar   (ícone lixo, text status-cancelled)

---

Bottom Sheet — Reagendar (mesmo stack do agendamento):
  Sheet Calendário → Sheet Horários
  título "Reagendar Serviço"
  serviço pré-selecionado read-only no topo (card compacto bloqueado)
  botão "Confirmar Reagendamento"

---

Bottom Sheet — Histórico (acionado pelo Quick Action):
  altura: 85% tela
  handle bar
  "Histórico" heading-2
  lista de Appointment Cards passados, badge status terminal
  filtro por status (row de pills: Todos | Concluídos | Cancelados)

---

Bottom Sheet — Perfil (acionado pelo Quick Action):
  altura: 85% tela
  handle bar
  Avatar 80px + edit badge centralizado
  nome heading-2 + email caption text-secondary centralizados
  lista de opções:
    Editar dados pessoais
    Alterar senha
    Notificações
    Sair da conta (text status-cancelled)
```

---

## 5. Fluxo — Área do administrador

```
Frame: Home Admin (375x812px)

Safe area top padding

─── Seção 1 — Header ──────────────────────────────
  Row: "Bem-vindo de volta" caption text-secondary | sino direita
       "Admin {Nome}" heading-1
  "Visão Geral" heading-1 margin-top sm

─── Quick Action Row ──────────────────────────────
  4 ações em row centralizado:
    [Agenda]    ícone calendário
    [Clientes]  ícone pessoas
    [Serviços]  ícone lista-check
    [Relatórios] ícone gráfico
  cada ação abre bottom sheet correspondente

─── Seção 2 — Débitos Pendentes ───────────────────
  Section Header "Débitos Pendentes" + "Ver todos"
  Scroll horizontal de Debt Cards (160px cada)
  tap em card → Bottom Sheet Detalhe do Débito

Bottom Sheet — Detalhe do Débito (altura: conteúdo ~55%):
  handle bar
  Avatar 56px + nome cliente heading-2 centralizados
  caption "Débito pendente" text-secondary centralizado
  Divider
  Rows de detalhe (ícone | label caption | valor body):
    Serviço · Data · Valor (bold brand-primary)
  Divider
  Button Primary "Marcar como Pago" full-width
  Button Ghost "Cancelar Cobrança" full-width text status-cancelled margin-top sm

─── Seção 3 — Agendamentos do Dia ─────────────────
  Section Header "Agendamentos de Hoje" + Row de ações:
    link "Ver outro dia" brand-primary | Button Icon "+" bg brand-light (novo agendamento)
  Data atual em destaque: badge brand-primary "Hoje, {dia} de {mês}"
  Lista vertical de Admin Appointment Cards (serviço + cliente + horário + badge)
  cada card: menu ⋮ → Sheet Opções Admin
  estado vazio: "Nenhum agendamento hoje" caption centralizado

---

Bottom Sheet — Ver outro dia (altura: exata do datepicker):
  handle bar
  Row: "Selecionar Data" heading-2 | X ghost
  Componente Calendar
  tap em data → dismiss este sheet → abre Sheet Agendamentos da Data

---

Bottom Sheet — Agendamentos da Data (altura: 85% tela):
  handle bar
  Row: ← | "{dia} de {mês}" heading-2 | X ghost
  badge da data selecionada
  Lista vertical de Admin Appointment Cards
  estado vazio: "Nenhum agendamento neste dia" caption

---

Bottom Sheet — Novo Agendamento / Editar Agendamento (altura: 80% tela):
  handle bar
  título "Novo Agendamento" ou "Editar Agendamento" heading-2 | X ghost
  Busca/select cliente: Input com autocomplete "Selecionar cliente"
  Lista de Service Cards (mesmo padrão da área cliente, mas sem botão agendar lateral —
    tap no card inteiro seleciona o serviço, estado selected: border brand-primary)
  serviço selecionado aparece como card compacto confirmado abaixo
  Input "Data" (abre datepicker inline ao focar)
  Grid Time Slots após data selecionada
  Input "Observações" multiline height 80px (opcional)
  Button Primary "Confirmar Agendamento" full-width sticky bottom

---

Bottom Sheet — Opções Admin (altura: conteúdo ~35%):
  acionado pelo ⋮ no Admin Appointment Card
  handle bar
  "Opções" heading-2
  Editar agendamento   (ícone lápis, text-primary)
  Marcar como No-show  (ícone alerta, text status-pending)
  Cancelar agendamento (ícone lixo, text status-cancelled)

---

Bottom Sheet — Serviços (acionado pelo Quick Action "Serviços", altura 85%):
  handle bar
  Row: "Serviços" heading-2 | Button Primary pequeno "+ Novo" height 32px
  Lista de Service Cards (admin view):
    mesmo layout do cliente + ações: ícone lápis | ícone lixo
    tap lápis → Sheet Editar Serviço
    tap lixo → alert inline no card (expand com Confirmar | Cancelar)

---

Bottom Sheet — Criar / Editar Serviço (altura: conteúdo ~70%):
  handle bar
  título "Novo Serviço" ou "Editar Serviço" heading-2 | X ghost
  Input "Nome do Serviço"
  Input "Descrição" multiline height 88px
  Row 2 col: Input "Duração (min)" | Input "Preço (R$)"
  Toggle "Ativo" label + switch
  Button Primary "Salvar Serviço" full-width sticky bottom
```

---

## 6. Instruções de prototipagem

```
─── Autenticação ──────────────────────────────────
Login → tap "Cadastre-se"
  → Bottom Sheet Criar Conta (slide up)
Login → tap "Esqueceu a senha?"
  → Bottom Sheet Recuperar Senha (slide up)
Login → tap "Entrar"
  → Home Cliente

─── Área do cliente ───────────────────────────────
Home Cliente → tap Quick Action "Agendar" ou botão "Agendar agora" (estado vazio)
  → Bottom Sheet Agendar (slide up, lista de serviços)

Bottom Sheet Agendar → tap Button Icon no Service Card
  → dismiss Sheet Agendar → Bottom Sheet Calendário (slide up)

Bottom Sheet Calendário → tap data disponível
  → Bottom Sheet Horários (replace, slide up)

Bottom Sheet Horários → tap Time Slot
  → estado selected (smart animate) → botão "Confirmar" ativo
  → tap "Confirmar Agendamento"
  → dismiss todos os sheets → card aparece na lista (smart animate)

Bottom Sheet Horários → tap ←
  → volta para Bottom Sheet Calendário (slide down / pop)

Home Cliente → tap ⋮ no Appointment Card
  → Bottom Sheet Opções (slide up)

Bottom Sheet Opções → tap "Reagendar"
  → dismiss Opções → Bottom Sheet Calendário (slide up, modo reagendamento)
  → selecionar data → Bottom Sheet Horários
  → confirmar → dismiss → card atualizado (smart animate)

Bottom Sheet Opções → tap "Cancelar"
  → dismiss → badge do card muda para Cancelled (smart animate)

Bottom Sheet Opções → tap "Pagar"
  → dismiss → Bottom Sheet Pagamento (slide up)

Home Cliente → tap Quick Action "Histórico"
  → Bottom Sheet Histórico (slide up)

Home Cliente → tap Quick Action "Perfil"
  → Bottom Sheet Perfil (slide up)

─── Área do administrador ─────────────────────────
Home Admin → tap Debt Card
  → Bottom Sheet Detalhe do Débito (slide up)

Bottom Sheet Detalhe → tap "Marcar como Pago"
  → dismiss → card some da lista (smart animate)

Bottom Sheet Detalhe → tap "Cancelar Cobrança"
  → dismiss → card some da lista (smart animate)

Home Admin → tap "Ver outro dia"
  → Bottom Sheet Calendário Admin (slide up, tamanho datepicker)

Bottom Sheet Calendário Admin → tap data
  → dismiss Calendário → Bottom Sheet Agendamentos da Data (slide up)

Bottom Sheet Agendamentos da Data → tap ←
  → volta para Bottom Sheet Calendário Admin (pop)

Home Admin → tap Button Icon "+" (novo agendamento)
  → Bottom Sheet Novo Agendamento (slide up)

Bottom Sheet Novo Agendamento → tap Service Card
  → estado selected no card (smart animate)
  → datepicker aparece abaixo (smart animate)
  → selecionar data → time slots aparecem (smart animate)
  → tap "Confirmar" → dismiss → card aparece na lista (smart animate)

Home Admin → tap ⋮ no Admin Appointment Card
  → Bottom Sheet Opções Admin (slide up)

Bottom Sheet Opções Admin → tap "Editar agendamento"
  → Bottom Sheet Editar Agendamento (replace, dados preenchidos)

Bottom Sheet Opções Admin → tap "Marcar como No-show"
  → dismiss → badge do card muda para status-pending alerta (smart animate)

Bottom Sheet Opções Admin → tap "Cancelar agendamento"
  → dismiss → card some ou badge muda para Cancelled (smart animate)

Home Admin → tap Quick Action "Serviços"
  → Bottom Sheet Serviços (slide up)

Bottom Sheet Serviços → tap "+ Novo"
  → Bottom Sheet Criar Serviço (slide up, sobre o anterior)

Bottom Sheet Serviços → tap lápis no Service Card
  → Bottom Sheet Editar Serviço (slide up, dados preenchidos)

Bottom Sheet Serviços → tap lixo no Service Card
  → card expande inline com Confirmar | Cancelar (smart animate)
  → tap "Confirmar" → card some (smart animate)
```