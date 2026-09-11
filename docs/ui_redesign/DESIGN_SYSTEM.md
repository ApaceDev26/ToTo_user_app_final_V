# Design System — Target (NEW)

**Codename:** **Lumen Atelier**  
**Product feel:** Quiet luxury food OS — editorial, airy, precise. Not marketplace orange. Not delivery-app clone.

> AS-IS system documented in `UI_REDESIGN_DISCOVERY.md`.  
> This file = **replacement** identity for Phase 1+.

---

## 1. Brand Principles

1. **Air first** — large whitespace; one job per section.
2. **Ink + porcelain** — near-black type on soft warm-neutral ground (not template grey `#F5F6F8`, not cliché cream `#F4F1EA`).
3. **Single accent** — deep teal-forest, used sparingly for CTA / active / price emphasis.
4. **Soft elevation** — diffuse shadows, minimal borders.
5. **Editorial type** — display serif for brand moments + geometric sans for UI.
6. **Glass accents** — only on overlays / floating nav / sheets (subtle).
7. **Motion = feedback** — short, purposeful; never decorative spam.

**Avoid (hard ban):** FoodPanda pink, Uber green, Talabat orange, purple-glow AI slop, dense newspaper columns, full-pill chip clusters, multi-layer neon shadows.

---

## 2. AppColors

### Light

| Token | Hex | Role |
|-------|-----|------|
| `ink` | `#0E1412` | Primary text |
| `inkMuted` | `#5C6B66` | Secondary text |
| `inkFaint` | `#8A9A94` | Tertiary / hints |
| `canvas` | `#F3F6F4` | Scaffold (cool porcelain-mint) |
| `surface` | `#FFFFFF` | Cards / sheets |
| `surfaceElevated` | `#FAFCFA` | Nested surfaces |
| `line` | `#D7E0DC` | Hairline borders |
| `lineStrong` | `#B7C5BF` | Emphasized dividers |
| `accent` | `#0F6B5C` | Primary CTA / links / active |
| `accentSoft` | `#E3F2EE` | Accent wash / chips |
| `accentHover` | `#0B5549` | Pressed |
| `warm` | `#C45C26` | Discount / urgency (sparingly) |
| `warmSoft` | `#F8E8DE` | Warm wash |
| `success` | `#1F7A4C` | Success |
| `warning` | `#B58100` | Warning |
| `danger` | `#C0392B` | Error / destructive |
| `rating` | `#D4A017` | Stars |
| `overlay` | `#0E1412` @ 45% | Scrim |
| `glass` | `#FFFFFF` @ 72% | Glass fill |

### Dark

| Token | Hex | Role |
|-------|-----|------|
| `ink` | `#F2F7F5` | Primary text |
| `inkMuted` | `#A7B5B0` | Secondary |
| `inkFaint` | `#7A8A84` | Tertiary |
| `canvas` | `#0C1210` | Scaffold |
| `surface` | `#161D1B` | Cards |
| `surfaceElevated` | `#1E2724` | Elevated |
| `line` | `#2A3531` | Borders |
| `accent` | `#3DCFB6` | CTA (brighter for contrast) |
| `accentSoft` | `#14352F` | Wash |
| `warm` | `#E8915A` | Discount |
| `danger` | `#E57373` | Error |
| `overlay` | `#000000` @ 55% | Scrim |
| `glass` | `#161D1B` @ 80% | Glass |

**Rule:** Zero raw `Color(0x…)` / `Colors.*` in feature UI. Use `AppColors.of(context)` or `Theme.colorScheme` extensions.

---

## 3. AppTypography

### Families

| Role | Family | Fallback |
|------|--------|----------|
| Display / brand | **Fraunces** (or **Newsreader**) | serif |
| UI / body | **Satoshi** (or **DM Sans** if license simpler) | sans |

> Phase 1: ship with bundled fonts under `assets/font/`. Replace Poppins entirely in ThemeData. Keep `AppConstants.fontFamily` pointed at UI sans for GetX compatibility, or introduce `fontFamilyDisplay` + `fontFamilyUi`.

### Scale

| Token | Size | Weight | Line height | Use |
|-------|-----:|--------|------------:|-----|
| `displayLg` | 40 | 600 display | 1.15 | Splash / empty hero |
| `displayMd` | 32 | 600 display | 1.2 | Onboarding titles |
| `titleLg` | 24 | 600 sans | 1.25 | Screen titles |
| `titleMd` | 20 | 600 sans | 1.3 | Section titles |
| `titleSm` | 17 | 600 sans | 1.35 | Card titles |
| `bodyLg` | 16 | 400 | 1.5 | Primary body |
| `bodyMd` | 14 | 400 | 1.5 | Default body |
| `bodySm` | 12 | 400 | 1.45 | Meta |
| `labelLg` | 14 | 600 | 1.2 | Buttons |
| `labelMd` | 12 | 600 | 1.2 | Chips / tabs |
| `labelSm` | 11 | 500 | 1.2 | Badges |
| `price` | 16–20 | 700 | 1.2 | Prices |
| `priceStrike` | 13 | 400 | 1.2 | Old price |

Scale with `MediaQuery.textScaler`; clamp 0.85–1.3.

---

## 4. AppSpacing

4pt base grid.

| Token | dp |
|-------|---:|
| `xxs` | 2 |
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |
| `x2l` | 24 |
| `x3l` | 32 |
| `x4l` | 40 |
| `x5l` | 48 |
| `x6l` | 64 |
| `page` | 20 (mobile) / 32 (tablet) / 40 (desktop inset) |
| `section` | 32–48 |
| `cardGap` | 12–16 |

**Ban:** magic `5/10/15` template paddings as primary system (migrate off `Dimensions` gradually).

---

## 5. AppRadius

| Token | dp | Use |
|------|---:|-----|
| `xs` | 8 | chips, inputs compact |
| `sm` | 12 | buttons, small cards |
| `md` | 16 | standard cards |
| `lg` | 20 | sheets, large cards |
| `xl` | 28 | hero media, bottom sheets top |
| `pill` | 999 | only status pills / avatars |

Default card = `md` (16). Not template 5/10.

---

## 6. AppElevation & AppShadows

| Level | Y | Blur | Spread | Opacity (light) | Use |
|-------|--:|-----:|-------:|----------------:|-----|
| `0` | 0 | 0 | 0 | 0 | flat |
| `1` | 1 | 2 | 0 | 0.04 | list rows |
| `2` | 4 | 12 | 0 | 0.06 | cards |
| `3` | 8 | 24 | 0 | 0.08 | floating bars |
| `4` | 16 | 40 | 0 | 0.10 | modals |

Dark: lower opacity, slightly brighter surface instead of heavy shadow.

---

## 7. AppDurations

| Token | ms | Use |
|------|---:|-----|
| `instant` | 100 | press opacity |
| `fast` | 180 | toggles, chips |
| `normal` | 280 | sheet / dialog |
| `emphasis` | 400 | page hero |
| `slow` | 600 | onboarding |

Curves: `easeOutCubic` default; `easeInOut` for reciprocal; spring only for favourite/cart badge.

---

## 8. AppIcons

**Primary set:** Iconsax (outline default, bold when selected).  
**Ban new:** Font Awesome sprawl, mixed Material unless system.

Sizes: 16 / 20 / 24 / 28. Nav icons 24. Touch target min 44.

---

## 9. Component Tokens (summary)

### AppButtons

| Variant | Fill | Text | Radius | Height |
|---------|------|------|--------|-------:|
| Primary | `accent` | white/ink-on-dark | `sm` | 52 |
| Secondary | `surface` + line | `ink` | `sm` | 52 |
| Ghost | transparent | `accent` | `sm` | 52 |
| Destructive | `danger` | white | `sm` | 52 |
| Soft | `accentSoft` | `accent` | `sm` | 44 |

Loading: accent spinner on button, label → “…” / keep width.

### AppInputs

- Height 52, radius `xs`/`sm`, fill `surface`, border `line` → focus `accent`
- Label above (not floating clutter) OR floating with large quiet style
- Error: `danger` border + `bodySm` message
- Phone: dial code as prefix chip, not cramped picker

### AppCards

- Radius `md`, shadow `2`, padding `lg`, no harsh border (optional `line` 0.5)
- Restaurant: image-led 4:3 or 16:10 full-bleed top, meta below (not left-thumb template)
- Food: horizontal editorial row OR vertical tile — pick one family, delete rest

### AppBottomSheets

- Top radius `xl`, handle 36×4, scrim `overlay`, glass optional
- Drag + confirm CTA pinned

### AppDialogs

- Radius `lg`, max width 340 mobile / 400 desktop
- Icon/illustration optional top; 1–2 actions

### AppBadges / Chips / Tags

- Badge: min 18, `labelSm`, accent or warm
- Chip: height 36, `accentSoft` selected
- Tag: discount uses `warmSoft`/`warm` — never loud pink

### AppDividers

- 1px `line`, inset optional `lg`

### AppNavigation

- **Mobile:** floating island nav OR soft top+bottom split — **not** stock 5-icon Material bar clone of StackFood
- Proposed: 4 destinations — Home / Browse / Orders / You; Cart as floating pill when non-empty
- **Web:** slim top rail + content max-width 1120–1200, lots of air

### AppSkeletons

- Bone color `line` → highlight `surfaceElevated`
- Match final card geometry exactly

### AppEmpty / Error / Illustrations

- Large display line + 1 sentence + 1 CTA
- Custom Lottie/SVG in accent palette (replace tiny empty_* icons)

---

## 10. AppTheme Wiring

```
ThemeData
  ├── colorScheme from AppColors
  ├── textTheme from AppTypography
  ├── appBarTheme
  ├── cardTheme
  ├── inputDecorationTheme
  ├── elevatedButtonTheme / textButtonTheme / outlinedButtonTheme
  ├── bottomSheetTheme
  ├── dialogTheme
  ├── chipTheme
  ├── dividerTheme
  ├── pageTransitionsTheme
  └── extensions: AppSpacing, AppShadows, AppRadii
```

Files (Phase 1 target layout):

```
lib/design_system/
  app_colors.dart
  app_typography.dart
  app_spacing.dart
  app_radius.dart
  app_elevation.dart
  app_shadows.dart
  app_durations.dart
  app_icons.dart
  app_theme.dart
  components/   # Phase 2
```

Deprecate gradual: `util/styles.dart` roboto*, raw theme hex, duplicate product cards.

---

## 11. Visual Differentiation Checklist (identity)

| Old | New |
|-----|-----|
| Orange `#FF7918` | Teal-forest `#0F6B5C` |
| Poppins everywhere | Display serif + Satoshi/DM Sans |
| Grey `#F5F6F8` scaffold | Cool porcelain-mint `#F3F6F4` |
| Radius 5–10 | Radius 12–20 |
| Dense home modules | Curated sections, fewer simultaneous modules |
| Template bottom bar | Island / 4-tab + cart pill |
| Left-image food row | Editorial media-first cards |
| Loud discount ribbons | Soft warm tags |

---

## 12. Implementation Notes

- Phase 1 adds design_system + rewires `light_theme`/`dark_theme` to consume it.
- Feature screens migrate in Phases 3–11; temporary bridge adapters allowed (`LegacyDimensions` → `AppSpacing`).
- `flutter analyze` / `dart analyze` green after each phase.
- Business logic / cache / routes / APIs untouched.
