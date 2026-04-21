Aqui está o prompt spec-driven para o Figma:

---

# BookingApp — UI/UX Spec Prompt (Figma)

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
Defina os seguintes tokens antes de criar qualquer frame:

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

## 2. Componentes base (criar como componentes reutilizáveis)

```
Button/
  Primary:   fill brand-primary, text-inverse, radius full, height 52px, padding h 24px
  Secondary: border 1.5px brand-primary, text brand-primary, mesmo shape
  Ghost:     sem borda, text brand-primary
  Danger:    fill #FFF0F0, text status-cancelled, border status-cancelled

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
  heights definidos por conteúdo — mínimo 40% tela, máximo 85%

Section Header/
  título heading-2 text-primary + link "Ver todos" / ação à direita em brand-primary body

Calendar/
  header: mês/ano heading-2 + chevrons
  dias da semana: caption text-secondary, uppercase
  dia normal: 36x36px, body
  dia hoje: bg brand-light, text brand-primary, bold
  dia selecionado: bg brand-primary, text-inverse, radius full
  dia sem vagas: bg #F5F5F5, text text-secondary, com ponto vermelho embaixo
  dia passado: text #CCCCCC

Time Slot/
  width: (container - gaps) / 3 colunas
  height: 44px, radius md, border 1px #E0E0E0, body text-primary
  selected: border 2px brand-primary, bg brand-light, text brand-primary
  unavailable: bg #F5F5F5, text #CCCCCC, sem interação

Appointment Card/
  layout: ícone serviço (40px) | info | badge status | menu (⋮)
  info: heading-3 nome do serviço + caption localização/cliente
  metadata row: ícone calendário + data · ícone relógio + hora · ícone ampulheta + duração
  action row: botão Secondary "Reagendar" + botão Danger "Cancelar"
  separator: 1px #F0F0F0

Debt Banner/
  bg status-cancelled, radius md, padding md
  layout: ícone alerta (24px branco) | textos | botão "Pagar" (bg white, text status-cancelled)
  título: body bold text-inverse
  valor: heading-2 bold text-inverse
  subtítulo: caption text-inverse opacity 0.8
```

---

## 3. Fluxo — Autenticação

```
Frame: Login (375x812px)

Background:
  - Metade superior (40% altura): fill brand-primary
    - círculos decorativos grandes, opacity 0.15, brand-light
    - ícone calendário centralizado: 64px, bg white, radius lg, shadow card
    - título "ServiçoApp" heading-1 text-inverse
    - subtítulo "Agende seus serviços com facilidade" body text-inverse opacity 0.85

Card branco flutuando sobre o background:
  - inicia em y 35% da tela, radius xl top, sem radius embaixo
  - padding lg
  - título "Entrar na sua conta" heading-2 text-primary, margin-bottom lg
  - Input email (trailing: ícone envelope)
  - Input senha (trailing: ícone olho toggle)
  - Row: checkbox "Lembrar-me" body | link "Esqueceu a senha?" brand-primary body
  - Button Primary "Entrar" full-width, margin-top md
  - Divider com linha + "ou" caption text-secondary, margin v md
  - Row centralizado: "Não tem uma conta?" body text-secondary + "Cadastre-se" brand-primary SemiBold

---

Bottom Sheet — Criar Conta (cobre 75% da tela):
  handle bar
  título "Criar Conta" heading-2 + ícone X ghost à direita
  Input "Nome Completo" (trailing: ícone pessoa)
  Input "Email" (trailing: ícone envelope)
  Input "Telefone" placeholder "(11) 99999-9999" (trailing: ícone telefone)
  Input "Senha" (trailing: olho toggle)
  Input "Confirmar Senha" (trailing: olho toggle)
  Button Primary "Criar Conta" full-width, margin-top lg

---

Bottom Sheet — Recuperar Senha (cobre 50% da tela):
  handle bar
  ícone chave 48px, bg brand-light, radius full, centralizado, margin-bottom md
  título "Recuperar Senha" heading-2 centralizado
  body text-secondary centralizado "Digite seu email abaixo e enviaremos um link para redefinir sua senha"
  Input "Email" margin-top md
  Button Primary "Enviar Link de Recuperação" full-width, margin-top md
  Row centralizado: ← link ghost "Voltar ao login" brand-primary
```

---

## 4. Fluxo — Área do cliente

```
Frame: Home Cliente (375x812px)

Safe area top padding

─── Seção 1 — Header ───────────────────────────────
  Row: saudação "Olá, {Nome}" heading-1 | ícone sino à direita (24px, badge ponto vermelho se notificação)
  caption "Bem-vindo ao seu painel" text-secondary
  Avatar 80px centralizado, edit badge

─── Seção 2 — Debt Banner ──────────────────────────
  Exibir apenas se houver débito pendente
  Componente Debt Banner (ver tokens acima)

─── Seção 3 — Próximos Agendamentos ────────────────
  Section Header "Próximos Agendamentos" + "Ver todos"
  Lista vertical de Appointment Cards
  Cada card: nome serviço + badge status + metadata row + action row (Reagendar | Cancelar)
  
  FAB (+) fixo bottom-right: 56px circle, bg brand-primary, ícone + branco, shadow elevation/card

─── Bottom Navigation ──────────────────────────────
  4 tabs: Início (casa) | Agenda (calendário) | Finanças (carteira) | Perfil (pessoa)
  ativo: ícone + label brand-primary | inativo: text-secondary
  height 64px, bg white, border-top 1px #F0F0F0

---

Bottom Sheet — Agendar Serviço (cobre 80% da tela):
  handle bar
  Row: "Agendar Serviço" heading-2 | X ghost
  
  Label "Selecione o Serviço"
  Dropdown/Select: bg #F5F5F5, radius md, height 52px, chevron direita
  
  Label "Selecione a Data" margin-top md
  Componente Calendar inline (ver tokens)
  Legenda abaixo do calendário: • vermelho = sem vagas · • cinza = passado
  
  Ao selecionar data → animar abertura da seção de horários logo abaixo (não abre novo sheet)
  Label "Horários Disponíveis — {data formatada}" caption brand-primary
  Grid 3 colunas de Time Slots
  
  Button Primary "Confirmar Agendamento" full-width, sticky no bottom do sheet

---

Bottom Sheet — Horários (alternativa separada, cobre 45%):
  handle bar
  Row: "Horários em {data}" heading-2 | X ghost
  Grid 3 colunas Time Slots
  Button Primary "Confirmar Horário" full-width margin-top md

---

Bottom Sheet — Opções do Agendamento (cobre 35%):
  handle bar
  título "Opções" heading-2
  Lista de opções com ícones:
    → Reagendar (ícone calendário, text-primary)
    → Pagar (ícone cartão, text-primary) — exibir apenas se houver valor pendente
    → Cancelar Agendamento (ícone lixo, text status-cancelled)
  Separador 1px entre cada opção, padding v md

---

Bottom Sheet — Reagendar (mesmo layout de Agendar Serviço, mas:
  título "Reagendar Serviço"
  serviço já pré-selecionado e bloqueado (read-only)
  botão "Confirmar Reagendamento")
```

---

## 5. Fluxo — Área do administrador

```
Frame: Home Admin (375x812px)

Safe area top padding

─── Seção 1 — Header ───────────────────────────────
  Row: "Bem-vindo de volta" caption text-secondary | sino à direita
       "Admin {Nome}" heading-1 text-primary
  título da seção "Visão Geral" heading-1, margin-top sm

─── Seção 2 — Débitos Pendentes ────────────────────
  Section Header "Débitos Pendentes" + "Ver todos"
  Scroll horizontal de cards de débito:
    Card 140px largura, radius md, shadow card
    Avatar cliente 32px + nome body bold + serviço caption text-secondary
    Badge "Pendente" + valor "R$ 000,00" body bold text-primary
  Cada card é clicável → abre Bottom Sheet de Detalhe

Bottom Sheet — Detalhe do Débito (cobre 55%):
  handle bar
  Avatar 56px + nome cliente heading-2 centralizado
  caption text-secondary "Débito pendente"
  Divider
  Rows de detalhe (ícone | label caption text-secondary | valor body text-primary):
    → Serviço: {nome}
    → Data: {data}
    → Valor: R$ {valor} (bold brand-primary)
  Divider
  Button Primary "Marcar como Pago" full-width
  Button Ghost "Cancelar Cobrança" full-width text status-cancelled margin-top sm

─── Seção 3 — Serviços Cadastrados ─────────────────
  Section Header "Serviços" + Button Primary pequeno "+ Novo Serviço" (height 32px, padding h 12px)
  Lista vertical de Service Cards:
    Row: ícone serviço 40px bg brand-light radius md | info | ações
    info: heading-3 nome + caption duração padrão + caption preço
    ações: ícone lápis (text-secondary 20px) | ícone lixo (status-cancelled 20px)

Bottom Sheet — Criar / Editar Serviço (cobre 70%):
  handle bar
  título "Novo Serviço" ou "Editar Serviço" heading-2 + X
  Input "Nome do Serviço"
  Input "Descrição" (multiline, height 88px)
  Row 2 colunas: Input "Duração (min)" | Input "Preço (R$)"
  Toggle "Ativo" label + switch
  Button Primary "Salvar Serviço" full-width sticky bottom

─── Bottom Navigation Admin ────────────────────────
  3 tabs: Visão Geral (grid) | Agenda (calendário) | Clientes (pessoas)
```

---

## 6. Instruções de prototipagem

```
Conecte os seguintes fluxos no Figma Prototype:

Login → tap "Cadastre-se" → Bottom Sheet Criar Conta (slide up)
Login → tap "Esqueceu a senha?" → Bottom Sheet Recuperar Senha (slide up)
Login → tap "Entrar" → Home Cliente

Home Cliente → tap FAB (+) → Bottom Sheet Agendar (slide up)
  → selecionar data no calendário → horários aparecem inline (smart animate)
  → tap horário → estado selected → botão Confirmar ativo
  → tap "Confirmar Agendamento" → dismiss sheet → card aparece na lista

Home Cliente → tap ⋮ no card → Bottom Sheet Opções (slide up)
  → tap "Reagendar" → Bottom Sheet Reagendar (replace)
  → tap "Cancelar" → estado do card muda para Cancelled (smart animate)

Home Cliente → tap Debt Banner "Pagar" → tela Finanças

Home Admin → tap card de débito → Bottom Sheet Detalhe
  → tap "Marcar como Pago" → dismiss → card some da lista (smart animate)

Home Admin → tap lápis no serviço → Bottom Sheet Editar Serviço
Home Admin → tap "+ Novo Serviço" → Bottom Sheet Criar Serviço
Home Admin → tap lixo → alert de confirmação inline no card (expand com botões Confirmar/Cancelar)
```

---

Cole esse prompt diretamente no **FigJam** ou use como briefing no **Anima**, **Galileo AI** ou qualquer ferramenta de geração de UI a partir de spec. Se for trabalhar manualmente no Figma, siga a ordem: tokens → componentes base → frames → protótipo.