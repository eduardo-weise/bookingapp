# ☕ Design System (v2.0)

> Paleta baseada em **Espresso (#4A2C2A)** & **Cream (#F3E6D4)** — mais quente, sofisticado e premium.

---

## 🎨 Tokens de Cor

### Paleta Principal (atualizada)

| Nome        | Hex       | RGB           | Uso                        |
| ----------- | --------- | ------------- | -------------------------- |
| Espresso    | `#4A2C2A` | 74, 44, 42    | Primária, CTAs, texto dark |
| Espresso 80 | `#6A3E3B` | 106, 62, 59   | Hover                      |
| Espresso 60 | `#92615D` | 146, 97, 93   | Bordas, ícones             |
| Espresso 20 | `#D1B3AF` | 209, 179, 175 | Disabled / placeholders    |
| Cream       | `#F5EFE6` | 245, 239, 230 | Fundo principal            |
| Cream 80    | `#F0E7DC` | 240, 231, 220 | Superfícies                |
| Cream 60    | `#FAF6F0` | 250, 246, 240 | Inputs / cards leves       |
| Cream 20    | `#FFFCF8` | 255, 252, 248 | Fundo geral                |

---

### Semânticas (ajustadas)

| Token                   | Light Mode | Dark Mode |
| ----------------------- | ---------- | --------- |
| `--color-bg`            | `#FFFCF8`  | `#1F1413` |
| `--color-surface`       | `#FAF6F0`  | `#2B1B19` |
| `--color-surface-alt`   | `#F5EFE6`  | `#4A2C2A` |
| `--color-primary`       | `#4A2C2A`  | `#F5EFE6` |
| `--color-primary-hover` | `#6A3E3B`  | `#F0E7DC` |
| `--color-on-primary`    | `#F5EFE6`  | `#4A2C2A` |
| `--color-text`          | `#4A2C2A`  | `#F5EFE6` |
| `--color-text-muted`    | `#92615D`  | `#D1B3AF` |
| `--color-border`        | `#F0E7DC`  | `#6A3E3B` |
| `--color-accent`        | `#92615D`  | `#D1B3AF` |

---

## 📂 Estrutura (corrigida)

Separação clara entre **core tokens** e **temas**:

```
src/
├── styles/
│   ├── tokens/
│   │   ├── colors.css
│   │   ├── typography.css
│   │   ├── spacing.css
│   │   ├── radius.css
│   │   ├── shadows.css
│   │   └── motion.css
│   ├── themes/
│   │   ├── light.css
│   │   └── dark.css
│   └── index.css
├── components/
│ ├── button/ 
│ ├── input/ 
│ ├── card/ 
│ ├── badge/ 
│ ├── avatar/ 
│ └── bottom-sheet/ 
├── layouts/ 
│ ├── home/ 
│ ├── booking/ 
│ └── profile/
```

✔️ **Regra:**

* `tokens/*` → valores primitivos (semântica ZERO)
* `themes/*` → mapeamento semântico (`--color-bg`, etc)

---

# 🎯 tokens.css (refatorado corretamente)

Agora separado em **tokens base (agnósticos de tema)**

```css
@import url('https://fonts.googleapis.com/css2?family=DM+Mono:ital,wght@0,300;0,400;0,500&family=DM+Sans:ital,opsz,wght@0,9..40,100..1000;1,9..40,100..1000&family=DM+Serif+Display:ital@0;1&family=Playfair+Display:ital,wght@0,400..900;1,400..900&display=swap');

:root {
  /* ================= COLORS (RAW) ================= */
  --espresso: #4A2C2A;
  --espresso-80: #6A3E3B;
  --espresso-60: #92615D;
  --espresso-20: #D1B3AF;

  --cream: #F5EFE6;
  --cream-80: #F0E7DC;
  --cream-60: #FAF6F0;
  --cream-20: #FFFCF8;

  /* ================= TYPOGRAPHY ================= */
  --font-display: 'Playfair Display', serif;
  --font-heading: 'DM Serif Display', serif;
  --font-body: 'DM Sans', sans-serif;
  --font-mono: 'DM Mono', monospace;

  --text-xs: 11px;
  --text-sm: 13px;
  --text-base: 15px;
  --text-md: 17px;
  --text-lg: 21px;
  --text-xl: 28px;
  --text-2xl: 36px;
  --text-hero: 52px;

  /* ================= SPACING ================= */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 20px;
  --space-6: 24px;
  --space-8: 32px;
  --space-10: 40px;
  --space-12: 48px;
  --space-16: 64px;

  /* ================= RADIUS ================= */
  --radius-sm: 6px;
  --radius-md: 12px;
  --radius-lg: 18px;
  --radius-xl: 28px;
  --radius-full: 9999px;

  /* ================= SHADOW BASE ================= */
  --shadow-color: 74,44,42;

  /* ================= MOTION ================= */
  --ease-out: cubic-bezier(0.0, 0, 0.2, 1);
  --ease-in: cubic-bezier(0.4, 0, 1, 1);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);

  --duration-fast: 120ms;
  --duration-base: 220ms;
  --duration-slow: 380ms;
  --duration-enter: 480ms;
}
```

---

# 🌞 light.css (semântico)

```css
:root {
  --color-bg: var(--cream-20);
  --color-surface: var(--cream-60);
  --color-surface-alt: var(--cream);
  --color-primary: var(--espresso);
  --color-primary-hover: var(--espresso-80);
  --color-on-primary: var(--cream);

  --color-text: var(--espresso);
  --color-text-muted: var(--espresso-60);
  --color-border: var(--cream-80);
  --color-accent: var(--espresso-60);

  --shadow-sm: 0 1px 4px rgba(var(--shadow-color), .08);
  --shadow-md: 0 4px 16px rgba(var(--shadow-color), .12);
  --shadow-lg: 0 12px 40px rgba(var(--shadow-color), .18);
}
```

---

# 🌙 dark.css

```css
[data-theme="dark"] {
  --color-bg: #1F1413;
  --color-surface: #2B1B19;
  --color-surface-alt: var(--espresso);

  --color-primary: var(--cream);
  --color-primary-hover: var(--cream-80);
  --color-on-primary: var(--espresso);

  --color-text: var(--cream);
  --color-text-muted: var(--espresso-20);
  --color-border: var(--espresso-80);
  --color-accent: var(--espresso-20);

  --shadow-sm: 0 1px 4px rgba(0,0,0,.3);
  --shadow-md: 0 4px 16px rgba(0,0,0,.4);
  --shadow-lg: 0 12px 40px rgba(0,0,0,.6);
}
```