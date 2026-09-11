# Card Visual Language — Cohesion Spec

**Status:** Binding for card redesigns  
**Date:** 2026-08-06  
**Source of truth:** Home header, island nav, Cart, Menu/Profile, Checkout chrome, `TitleWidget`, `PortionWidget`, `PricingViewWidget`  
**Out of scope this pass:** `product_widget.dart` (user freeze)

---

## 1. Principle

Cards must **disappear into the system**.  
Not creative experiments. Not glass docks. Not cinematic overlays.

If a card attracts attention for styling → fail.

---

## 2. Extracted system (from screens that work)

### Colors
| Token | Use |
|-------|-----|
| `canvas` | Scaffold / page bg |
| `surface` | Card fill |
| `ink` | Titles / primary text |
| `inkMuted` | Secondary (address, meta) |
| `inkFaint` | Tertiary / captions |
| `accent` | Price, selected, CTA fill |
| `accentSoft` | Soft CTA / selected wash |
| `line` | Hairline borders |
| `rating` | Star icon only |
| `warm` / `warmSoft` | Discount tag only (max 1) |
| `success` / `danger` | Open/closed status only |

**Ban on cards:** glass fills, gradient scrims, multi-color pill stacks.

### Spacing
| Token | dp | Card use |
|-------|---:|----------|
| `xs` | 4 | Tight icon gaps |
| `sm` | 8 | Meta gaps |
| `md` | 12 | Image↔text gap, cardGap |
| `lg` | 16 | Card inner padding |
| `xl` | 20 | Section / page edge |

Rhythm: **padding `lg`**, gaps `sm`/`md`, list gap `cardGap` (12).

### Radius
| Token | dp | Allowed on cards |
|------|---:|------------------|
| `sm` | 12 | Buttons, fav hit, status pill |
| `md` | 16 | **Default card** |
| `xs` | 8 | Tiny tags only |
| `pill` | 999 | Status / count badge only |

**Ban:** `lg` / `xl` as default card radius. One radius per card shell = `md`.

### Elevation / border
| Level | When |
|------:|------|
| Shadow **1** | Default card lift |
| Shadow **2** | Rare floating chrome (search, sticky CTA) — **not** list cards |
| Hairline `line` | Optional with shadow 1, or alone on dense lists |

**Ban:** shadow 3–4 on cards. **Ban:** dual heavy shadow + thick border.

### Typography
| Role | Style |
|------|-------|
| Card title | `titleSm` (`ink`) |
| Meta / address | `bodySm` (`inkMuted`) |
| Price | `labelLg` or `price` (`accent`) |
| Strike | `priceStrike` (`inkFaint`) |
| Rating number | `labelMd` (`ink`) |
| Status | `labelSm` |

**Ban:** display/Fraunces inside dense cards. Section titles keep Fraunces via `TitleWidget` only.

### Icons
| Size | Use |
|-----:|-----|
| 14 | Star / inline meta |
| 18–20 (`AppIcons.sm`) | Fav, add |
| 22 | Nav only |

### Image ratios
| Card | Image treatment |
|------|-----------------|
| Food rail | **1:1** top, clipped to card `md` top corners |
| Restaurant list | Cover **~112–120** tall, full width, top `md` |
| Popular store rail | Cover **~100** tall, full width, top `md` |

**Ban:** full-bleed image with text painted on gradient.  
**Ban:** floating overlapping logos.  
**Ban:** oversized portrait media that dominates the row (leave that to frozen `product_widget`).

### Buttons / chips
- Add: `accentSoft` square/`sm` radius, 36×36, accent icon — or compact qty stepper
- Fav: plain icon on transparent / light surface circle, **no glass**
- Status: one small pill (`sm` radius or pill), `labelSm`
- Discount: **at most one** `AppTag.discount`
- Meta: **plain text** with ` · ` separators — **not** a row of chips

### Hierarchy (one only)
1. Image  
2. Name  
3. One secondary line  
4. Price / rating / ETA as single quiet footer row  

Max **one** badge on image. Max **one** fav control. No nested cards.

---

## 3. Anti-patterns (failed redesign)

- Giant / mixed radii (`xl` shells + random pills)
- Glassmorphism + gradient scrims
- Floating logo overlapping cover
- Chip wraps (rating + km + time as 3 pills)
- Shadow 3 + border + nested containers
- Text on top of darkened photo
- Experimental split layouts that ignore Home/Menu rhythm

---

## 4. Target recipes

### A. Food rail (`NewItemCardWidget`)
```
┌──────────────┐
│ image 1:1    │  optional: small discount top-left, fav top-right
├──────────────┤
│ Name         │  titleSm
│ Restaurant   │  bodySm muted
│ $ · ★  [+]   │  one footer row
└──────────────┘
surface · radius md · shadow 1 · padding lg
```

### B. Restaurant list (`RestaurantWidget`)
```
┌────────────────────┐
│ cover ~118         │  status pill TL, fav TR (quiet)
├────────────────────┤
│ Name               │
│ Address            │
│ ★ 4.5 · 2.1 km · 25m│  text meta, no chips
└────────────────────┘
surface · radius md · shadow 1 · padding lg
```

### C. Popular store rail (`NewPopularStoreWidget1` tile)
Same as B, narrower (~200w), cover ~100, height ~188. Shared visual DNA with B.

---

## 5. Consistency checks

Before merge:
- [ ] Same radius as search field / menu cards (`md` / `sm`)
- [ ] Same shadow as cart/desktop summary (`1`)
- [ ] Same padding language as menu groups (`lg`)
- [ ] Meta not louder than title
- [ ] Side-by-side with Home header: no clash
- [ ] Side-by-side with Menu: same calm

---

## 6. Frozen

`lib/common/widgets/product_widget.dart` — do not modify this pass.
