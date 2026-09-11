# Accessibility Report — Discovery Baseline

**Date:** 2026-08-06  
**Phase:** 0 (baseline) + Phase 14 (execution)

---

## 1. Baseline Score (honest)

| Area | Score | Notes |
|------|------:|-------|
| Semantics / screen reader | 1/10 | ~2 Semantics usages in 665 dart files |
| Contrast (light) | 5/10 | Orange on white OK for CTA; meta greys weak |
| Contrast (dark) | 2/10 | `hintColor` same as light `#5E6472` on dark surfaces |
| Touch targets | 4/10 | 15px badges, 22px nav icons, dense lists |
| Text scaling | 4/10 | Fixed sizes; overflow risk |
| Keyboard (web) | 4/10 | Forms OK; custom GestureDetector gaps |
| RTL | 5/10 | GetX i18n present; mirror polish incomplete |
| Motion sensitivity | 3/10 | No `disableAnimations` gating observed systematically |

**Overall baseline: ~3.5/10** — not production a11y.

---

## 2. Critical Issues

1. **Dark hint/disabled contrast** — unreadable secondary copy  
2. **Missing semantics** on icon-only buttons (fav, cart, back, filters)  
3. **Bottom nav** — `GestureDetector` without `Semantics(button: true, label: …)`  
4. **Images** — network food/resto images often no `semanticLabel`  
5. **Decorative icons** exposed to AT as unlabeled  
6. **Color-only status** (open/closed, order state) without text/icon redundancy  
7. **Snackbar** may lack live-region announcement consistency  
8. **Product sheet** dense controls — focus order unclear  

---

## 3. Contrast Targets (Phase 1 tokens)

| Pair | Min ratio |
|------|----------:|
| `ink` on `canvas` / `surface` | 7:1 body, 4.5:1 large |
| `inkMuted` on `surface` | ≥ 4.5:1 |
| `accent` on white / on accent text | ≥ 4.5:1 |
| Dark `accent` `#3DCFB6` on `surface` | verify ≥ 4.5:1 |
| Error text on surface | ≥ 4.5:1 |

Validate with contrast checker when implementing `AppColors`.

---

## 4. Touch Target Policy

- Minimum **44×44** interactive area
- Visual icon may be 24; pad hit box
- List rows min height 56
- Stepper buttons 44

---

## 5. Semantics Policy (Phase 2+)

Every interactive widget:

```dart
Semantics(
  button: true,
  label: 'Add ${product.name} to cart',
  child: ...
)
```

- Images: label = product/restaurant name  
- Decorative: `ExcludeSemantics` or `explicitChildNodes`  
- Badges: include count in parent label (`Cart, 3 items`)  
- Tabs: `selected: true/false`  

---

## 6. Text Scaling

- Use theme text styles; avoid absolute overflow Rows  
- Test `textScaler: 1.3`  
- Clamp display sizes if layout breaks; never clip body text  

---

## 7. Screen Reader Flows to Test (Phase 14)

1. Sign in with phone  
2. Search → open restaurant → add item → cart → checkout  
3. Track order  
4. Toggle favourite  
5. Switch language + RTL locale  
6. Dark mode profile settings  

---

## 8. Keyboard / Web

- Visible focus ring using `accent`  
- Tab order follows visual order  
- Esc closes dialogs/sheets  
- No focus trap outside modal  

---

## 9. Phase 14 Deliverables

- [ ] Semantics on App* components  
- [ ] Contrast audit pass light+dark  
- [ ] Touch target audit  
- [ ] `MediaQuery.disableAnimations` respected  
- [ ] RTL smoke on Home, Cart, Checkout, Profile  
- [ ] Update this report with after scores  

---

## 10. Out of Scope

Changing auth/checkout **logic** for a11y — only presentation labels, focus, contrast, hit areas.
