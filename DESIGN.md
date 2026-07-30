
# Civitas Design Guide

## Philosophy

**"Native Mac Utility" — the macOS/iOS system feel.**

Civitas should feel like a serious Apple platform utility: system-gray chrome,
white grouped surfaces, native rounded controls, restrained borders, and soft
sepia as the Civitas accent. It should feel familiar like Settings, Finder, and
iOS grouped lists, while still making capture, consent, and auditability clear.

---

## Core Values

| Value | Description |
|-------|-------------|
| **Auditable & consensual** | New installs begin paused. Each capture class is explicit, visible, pausable, and auditable. Raw and derived work data stay on-device unless the user deliberately sends selected evidence to a configured provider. |
| **Open Source** | Inspect, modify, own, clean abstractions and readable codebase |
| **Simplicity** | Clean, minimal interface, powerful abstractions |
| **Radical optimism** | There is no such thing as impossible |
| **Progressive disclosure** | Easy, simple for non technical users but power users can still go deep |

---

## Typography

### Font Stack

| Purpose | Font | Fallbacks |
|---------|------|-----------|
| **Body** | System UI | -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif |
| **UI / mono** | System UI | same stack as body |

### Usage Patterns

- **Type scale — macOS-native, anchored at the 13px system body size** (NOT the
  iOS 17px). Use the tokens, never arbitrary px: `text-2xs` ≈10 (dense rows:
  menubar/notification meta, kbd hints, timestamps) · `text-xs` ≈11 (captions,
  secondary labels) · `text-sm` ≈12 (list rows, recents) · `text-base` 13 (body,
  primary sidebar nav) · `text-lg` ≈15 / `text-xl` ≈17 / `text-2xl` ≈20 /
  `text-3xl` ≈22 (titles). All derive from `--font-size-base` (default 13px) with
  unitless line-heights, so the Display setting scales everything coherently.
  Avoid `text-[NNpx]`.
- **Body text**: system font stack (applied on `<body>`)
- **Headings**: bold, sentence case preferred
- **Code/technical & `font-mono` utilities**: same system font stack; use spacing, borders, or muted surfaces for technical affordance instead of changing families
- **Buttons**: sentence case, system font, understated
- **Labels**: sentence case, medium weight
- **Brand text**: always `Civitas`, never `CIVITAS`

---

## Colors

### Palette: Native Mac

System gray chrome, white grouped surfaces, near-black ink, soft sepia accents. Tokens live in
`app/globals.css` as HSL (`H S% L%`); use the token, not a literal.

**Light Mode:**
- Background: `#F5F5F7` — Apple-like system gray (`240 11% 96%`)
- Foreground (ink): `#1D1D1F` — near-black (`240 3% 12%`)
- Surfaces/cards: `#FFFFFF` — grouped white surfaces (`0 0% 100%`)
- Muted ink: Apple secondary gray (`240 2% 44%`)
- Border: soft system gray (`240 6% 83%`)
- Accent: muted Civitas sepia (`28 26% 38%`)

**Dark Mode:**
- Background: graphite `#1C1C1E` (`240 4% 11%`)
- Foreground (ink): near-white `#F5F5F5` (`0 0% 96%`)
- Surfaces/cards: graphite steps (`240 3% 16%`, `240 3% 19%`)
- Muted ink: `240 3% 69%`
- Border: `240 3% 28%`
- Accent: warm sepia (`32 40% 60%`)

### Rule: Sepia Is the Only Accent

- No bright blue/purple/cyan/emerald/red. Status reads by weight, opacity, icon
  shape, and at most a muted sepia — never a saturated hue.
- Success/warning/error are differentiated by icon and a soft warm tint, not by
  vivid color.

---

## Surfaces & Materials

Three explicit materials, used consistently. Separate them with **hairlines +
whitespace, never boxes-inside-boxes**; one soft elevation per floating surface;
**no glass-on-glass**.

| Material | Where | Treatment |
|----------|-------|-----------|
| **App shell** (chrome + content) | sidebar · toolbar · chat thread · lists · settings panes | ONE continuous warm surface (`bg-background`). The sidebar is *not* a separate frosted panel — sidebar and content share the same fill and read as a single window; they are divided only by a **single whisper hairline** (`.vibrant-sidebar-border`, ~6–8% ink), never a material cliff. Content panes that need to lift use `--card`/`--surface` (a step more opaque), same hue family. |
| **Popover / menu** | menubar dashboard (`/tray`) · native menus · dropdowns | Light liquid glass: native `UnderWindowBackground` vibrancy + an ultra-light warm plate (`.kg-tray-panel`, ~14% tint) + a one-light specular rim. `prefers-reduced-transparency` → solid. This is the ONLY surface that goes highly transparent. |
| **Graph map** | `/graph-map` | Native vibrancy over the wallpaper (`.kg-graph-surface`, transparent plate). |

**Sidebar ↔ content harmony (make-or-break).** The shell must read as one window:
shared warm tone, shared type scale / row rhythm / ink tiers / the one sepia
accent, a single hairline seam. Never let the sidebar look like a frosted panel
bolted onto a white slab.

---

## Geometry

### Border Radius

```
--radius: 0.875rem   /* 14px */
```

Use the native radius tiers (the tokens, not arbitrary px):

| Token | Value | Use |
|-------|-------|-----|
| `rounded-lg` | 14px (`--radius`) | cards, dialogs, large panes |
| `rounded-md` | 12px | buttons, inputs, list rows |
| `rounded-sm` | 10px | compact controls, chips, kbd |
| `rounded-control` | 4.8px | 16px checkboxes and similarly tiny native controls |
| `rounded-full` | pill | toggles, avatars, status dots |

The menubar dashboard's 20px outer corner is the one sanctioned exception (a
large floating popover). Avoid ad-hoc `rounded-[NNpx]` elsewhere.

### Borders

- Width: 1px solid
- Style: Subtle system separation
- Avoid decorative gradients and heavy shadows

### Shadows

Subtle and functional only. Use borders for separation first, then soft native
elevation for popovers, modals, and floating controls.

---

## Components

### Buttons

```
- Font: system, sentence case
- Border: 1px solid
- Corners: rounded native control radius
- Transition: 150ms
- Hover: subtle surface or fill shift
```

### Cards

```
- Border: 1px solid
- Shadow: subtle only when needed for native elevation
- Corners: rounded native card radius
- Padding: 24px (p-6)
```

### Inputs

```
- Style: native input field
- Font: system
- Border: 1px solid
- Height: 40px (h-10)
- Focus: Border color change
```

### Dialogs

```
- Border: 1px solid
- Shadow: subtle native modal elevation
- Animation: 150ms fade
- Title: sentence case
```

---

## Motion & Animation

### Principles

- **Fast**: 150ms standard duration
- **Minimal**: Only essential state changes
- **Binary**: On/off, no elaborate easing
- **Responsive**: Press feedback begins on pointer-down; commits happen on
  release
- **Interruptible**: Rapidly repeated interactions retarget from their current
  state instead of replaying a keyframe sequence
- **Spatially honest**: Popovers originate at their trigger; enter and exit use
  the same path
- **Accessible**: Reduced motion keeps useful color/opacity feedback while
  removing decorative movement; reduced transparency and increased contrast
  use solid, legible materials

### Timing

| Animation | Duration |
|-----------|----------|
| Button hover | 150ms |
| Dialog open/close | 150ms |
| Accordion | 200ms |
| Page transitions | 150ms |

Use `--ease-out` for entry, exit, and press response;
`--ease-in-out` for a visible element moving between positions; and
`--ease-drawer` only for an actual drawer or sheet. Never use `ease-in` for an
interactive response, `transition-all`, or a `scale(0)` entrance. Predetermined
motion should animate only `transform` and `opacity`; color, border, and shadow
transitions may accompany state feedback.

Frequency decides whether motion belongs at all. Keyboard-driven and
high-frequency navigation should be immediate. Ordinary controls get only a
subtle 150ms press/color response. Occasional dialogs and disclosure panels may
use restrained spatial motion. Delight is reserved for rare onboarding or
completion moments and must never delay interaction.

These review heuristics are informed by
[`emilkowalski/skills`](https://github.com/emilkowalski/skills/tree/70744e3816f1d93eafb697161a8b880a7384c5ff)
(MIT), especially its Apple-design and animation-review material. Civitas's
privacy, accessibility, native-utility character, and the rules in this
document remain authoritative.

### Iteration

Do at least 10 iterations on your animations, at every turn criticise your own design and improve it until it matches the unique brand style

---

## Brand Voice

### Tone

- Lowercase, casual, direct
- Technical and still very accessible
- No marketing fluff

---

## Design Checklist

When creating new UI components:

- [ ] One system font family across body, controls, metadata, and technical UI
- [ ] Native Mac tokens only (`bg-background`, `text-foreground`, `border-border`, …) — never literal hex/Tailwind color utilities
- [ ] Sepia is the only accent; no bright hues
- [ ] 1px solid border
- [ ] Shadows are subtle and functional only
- [ ] Native radius tiers; no default sharp-corner surfaces
- [ ] 150ms transitions
- [ ] no all-caps branding or forced uppercase labels; technical acronyms like API/OCR/PDF are allowed
- [ ] sentence case for titles; understated buttons
- [ ] Hover state: subtle native surface shift
- [ ] Focus ring: 1px solid with offset

---

## Key Files

| Purpose | Location |
|---------|----------|
| Design tokens | `civitas-app-tauri/app/globals.css` |
| Tailwind config | `civitas-app-tauri/tailwind.config.ts` |
| Color constants | `civitas-app-tauri/lib/constants/colors.ts` |
| UI components | `civitas-app-tauri/components/ui/*.tsx` |

---
