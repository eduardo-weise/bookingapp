# ☕ Agendê — Design System

> Sistema de design para aplicativo de agendamento de serviços.  
> Paleta inspirada em **Espresso** & **Pale Oak** — sofisticado, acolhedor, confiável.

---

## 🎨 Tokens de Cor

### Paleta Principal

| Nome         | Hex       | RGB             | Uso                          |
|--------------|-----------|-----------------|------------------------------|
| Espresso     | `#3C2415` | 60, 36, 21      | Primária, fundos dark, CTAs  |
| Pale Oak     | `#DDD9CE` | 221, 217, 206   | Fundos light, superfícies    |
| Espresso 80  | `#634030` | 99, 64, 48      | Hover, estados ativos        |
| Espresso 60  | `#8C5C45` | 140, 92, 69     | Ícones, bordas               |
| Espresso 20  | `#C4A891` | 196, 168, 145   | Placeholders, disabled       |
| Pale Oak 80  | `#E4E1D8` | 228, 225, 216   | Cards light                  |
| Pale Oak 60  | `#EDEAE3` | 237, 234, 227   | Fundo de inputs light        |
| Pale Oak 20  | `#F7F5F2` | 247, 245, 242   | Fundo geral light            |

### Semânticas

| Token                  | Light Mode  | Dark Mode   | Descrição                    |
|------------------------|-------------|-------------|------------------------------|
| `--color-bg`           | `#F7F5F2`   | `#1A0F09`   | Fundo principal              |
| `--color-surface`      | `#EDEAE3`   | `#2A1810`   | Cards, modais                |
| `--color-surface-alt`  | `#DDD9CE`   | `#3C2415`   | Superfície alternativa       |
| `--color-primary`      | `#3C2415`   | `#DDD9CE`   | Cor primária                 |
| `--color-primary-hover`| `#634030`   | `#E4E1D8`   | Hover do primário            |
| `--color-on-primary`   | `#DDD9CE`   | `#3C2415`   | Texto sobre primário         |
| `--color-text`         | `#3C2415`   | `#DDD9CE`   | Texto principal              |
| `--color-text-muted`   | `#8C5C45`   | `#C4A891`   | Texto secundário             |
| `--color-border`       | `#DDD9CE`   | `#634030`   | Bordas e divisores           |
| `--color-accent`       | `#8C5C45`   | `#C4A891`   | Destaques, badges            |

---

## 🔤 Tipografia

### Famílias

| Papel         | Família                    | Uso                              |
|---------------|----------------------------|----------------------------------|
| Display       | `Playfair Display`         | Títulos de tela, h1, hero        |
| Heading       | `DM Serif Display`         | H2, h3, nomes de serviços        |
| Body          | `DM Sans`                  | Texto corrido, labels, UI        |
| Mono          | `DM Mono`                  | Horários, preços, códigos        |

### Escala de Tamanho

| Token           | Tamanho | Line-height | Peso    | Uso                       |
|-----------------|---------|-------------|---------|---------------------------|
| `--text-xs`     | 11px    | 1.4         | 500     | Badges, tags, captions    |
| `--text-sm`     | 13px    | 1.5         | 400     | Labels, metadata          |
| `--text-base`   | 15px    | 1.6         | 400     | Corpo padrão              |
| `--text-md`     | 17px    | 1.5         | 500     | Subtítulos, destaques     |
| `--text-lg`     | 21px    | 1.3         | 600     | H3, nomes de card         |
| `--text-xl`     | 28px    | 1.2         | 700     | H2, títulos de seção      |
| `--text-2xl`    | 36px    | 1.1         | 700     | H1 de tela                |
| `--text-hero`   | 52px    | 1.0         | 700     | Display, hero             |

---

## 📐 Espaçamento

Sistema base 4px:

| Token       | Valor | Uso                                  |
|-------------|-------|--------------------------------------|
| `--space-1` | 4px   | Gaps internos mínimos                |
| `--space-2` | 8px   | Padding de tags, ícones              |
| `--space-3` | 12px  | Gap de elementos inline              |
| `--space-4` | 16px  | Padding padrão de componentes        |
| `--space-5` | 20px  | Margens internas de cards            |
| `--space-6` | 24px  | Seções internas                      |
| `--space-8` | 32px  | Entre componentes                    |
| `--space-10`| 40px  | Seções de página                     |
| `--space-12`| 48px  | Espaço entre seções grandes          |
| `--space-16`| 64px  | Hero, header                         |

---

## 🔲 Bordas e Sombras

### Border Radius

| Token        | Valor  | Uso                              |
|--------------|--------|----------------------------------|
| `--radius-sm`| 6px    | Tags, badges, inputs pequenos    |
| `--radius-md`| 12px   | Buttons, inputs padrão           |
| `--radius-lg`| 18px   | Cards, modais                    |
| `--radius-xl`| 28px   | Cards hero, bottom sheets        |
| `--radius-full`| 9999px | Pills, avatares, FABs          |

### Sombras (Light Mode)

| Token           | Valor                                       | Uso                 |
|-----------------|---------------------------------------------|---------------------|
| `--shadow-sm`   | `0 1px 4px rgba(60,36,21,.08)`              | Inputs              |
| `--shadow-md`   | `0 4px 16px rgba(60,36,21,.12)`             | Cards               |
| `--shadow-lg`   | `0 12px 40px rgba(60,36,21,.18)`            | Modais, FAB         |
| `--shadow-inset`| `inset 0 1px 4px rgba(60,36,21,.08)`        | Inputs focados      |

### Sombras (Dark Mode)

| Token           | Valor                                       |
|-----------------|---------------------------------------------|
| `--shadow-sm`   | `0 1px 4px rgba(0,0,0,.3)`                  |
| `--shadow-md`   | `0 4px 16px rgba(0,0,0,.4)`                 |
| `--shadow-lg`   | `0 12px 40px rgba(0,0,0,.6)`                |

---

## 🧩 Componentes

### Button

**Variantes:** `primary` | `secondary` | `ghost` | `danger`  
**Tamanhos:** `sm` | `md` | `lg`

```html
<!-- Primary -->
<button class="btn btn-primary btn-md">Agendar agora</button>

<!-- Secondary -->
<button class="btn btn-secondary btn-md">Ver horários</button>

<!-- Ghost -->
<button class="btn btn-ghost btn-md">Cancelar</button>
```

**Estados:** default → hover → active → focus → disabled → loading

---

### Input / Campo de texto

```html
<div class="field">
  <label class="field-label">Nome completo</label>
  <input class="field-input" type="text" placeholder="Ex: Maria Silva" />
  <span class="field-hint">Como está no seu documento</span>
</div>
```

**Estados:** default | focused | filled | error | disabled

---

### Card de Serviço

```html
<div class="service-card">
  <div class="service-card__image">...</div>
  <div class="service-card__body">
    <span class="badge badge-accent">Mais agendado</span>
    <h3 class="service-card__title">Corte + Barba</h3>
    <p class="service-card__desc">45 min · com Rodrigo</p>
    <div class="service-card__footer">
      <span class="service-card__price">R$ 65,00</span>
      <button class="btn btn-primary btn-sm">Agendar</button>
    </div>
  </div>
</div>
```

---

### Card de Agendamento

```html
<div class="appointment-card">
  <div class="appointment-card__date">
    <span class="date-day">14</span>
    <span class="date-month">ABR</span>
  </div>
  <div class="appointment-card__info">
    <h4>Corte masculino</h4>
    <p>14:30 · Barbearia Nobre</p>
    <span class="status status-confirmed">Confirmado</span>
  </div>
  <button class="btn btn-ghost btn-sm">Detalhes</button>
</div>
```

---

### Badge / Status

| Variante      | Cor de fundo     | Uso                         |
|---------------|------------------|-----------------------------|
| `default`     | Pale Oak 60      | Tags genéricas              |
| `accent`      | Espresso 20      | Destaque, populares         |
| `confirmed`   | Verde suave      | Agendamentos confirmados    |
| `pending`     | Âmbar suave      | Aguardando confirmação      |
| `cancelled`   | Vermelho suave   | Cancelados                  |

---

### Avatar

```html
<!-- Com imagem -->
<div class="avatar avatar-md">
  <img src="foto.jpg" alt="João Silva" />
</div>

<!-- Iniciais fallback -->
<div class="avatar avatar-md avatar-initials">JS</div>

<!-- Com indicador online -->
<div class="avatar avatar-md avatar-online">...</div>
```

**Tamanhos:** `sm` (28px) | `md` (40px) | `lg` (56px) | `xl` (80px)

---

### Bottom Sheet / Modal

```html
<div class="bottom-sheet">
  <div class="bottom-sheet__handle"></div>
  <div class="bottom-sheet__content">
    ...
  </div>
</div>
```

---

### Time Picker (Seleção de Horário)

```html
<div class="time-grid">
  <button class="time-slot">09:00</button>
  <button class="time-slot time-slot--selected">10:00</button>
  <button class="time-slot" disabled>11:00</button>
</div>
```

---

## 🎬 Animações e Transições

| Token              | Valor                          | Uso                        |
|--------------------|--------------------------------|----------------------------|
| `--ease-out`       | `cubic-bezier(0.0, 0, 0.2, 1)`| Entradas, expansões        |
| `--ease-in`        | `cubic-bezier(0.4, 0, 1, 1)`  | Saídas, colapsos           |
| `--ease-spring`    | `cubic-bezier(0.34,1.56,0.64,1)` | Botões, micro-interações |
| `--duration-fast`  | `120ms`                        | Hover, focus               |
| `--duration-base`  | `220ms`                        | Transições padrão          |
| `--duration-slow`  | `380ms`                        | Modais, bottom sheets      |
| `--duration-enter` | `480ms`                        | Entradas de tela           |

---

## 📱 Breakpoints

| Token    | Valor  | Dispositivo          |
|----------|--------|----------------------|
| `sm`     | 375px  | Mobile pequeno       |
| `md`     | 430px  | Mobile padrão        |
| `lg`     | 768px  | Tablet               |
| `xl`     | 1024px | Desktop              |

---

## ♿ Acessibilidade

- Contraste mínimo **4.5:1** em todos os textos (WCAG AA)
- Área tátil mínima de **44×44px** em elementos interativos
- Focus visible em todos os elementos (`outline` customizado em Espresso)
- `aria-label` obrigatório em botões sem texto visível
- Suporte a `prefers-reduced-motion` — animações desativadas quando necessário
- Suporte a `prefers-color-scheme` — alternância automática de tema

---

## 🌙 Modo Escuro

O sistema suporta modo escuro via:

1. **Automático** — `@media (prefers-color-scheme: dark)`  
2. **Manual** — atributo `data-theme="dark"` no `<html>`

Todos os tokens semânticos já possuem valores para ambos os modos. Nunca usar cores fixas nos componentes — sempre via variável CSS.

---

## 📂 Estrutura de Arquivos Sugerida

```
src/
├── tokens/
│   ├── colors.css
│   ├── typography.css
│   ├── spacing.css
│   └── animation.css
├── components/
│   ├── button/
│   ├── input/
│   ├── card/
│   ├── badge/
│   ├── avatar/
│   └── bottom-sheet/
├── layouts/
│   ├── home/
│   ├── booking/
│   └── profile/
└── themes/
    ├── light.css
    └── dark.css
```

---

*Agendê Design System v1.0 — baseado na paleta Espresso × Pale Oak*
