# Responsive Guide — Target

---

## 1. Breakpoints (revise helper in Phase 13; bridge in Phase 1)

| Name | Min width | Max | Layout intent |
|------|----------:|----:|---------------|
| `compact` | 0 | 599 | Phone portrait |
| `medium` | 600 | 899 | Large phone / small tablet / fold cover |
| `expanded` | 900 | 1199 | Tablet / fold open |
| `large` | 1200 | ∞ | Desktop / web |

**Legacy map (temporary):**

| Old `ResponsiveHelper` | Approx new |
|------------------------|------------|
| `isMobile` (<650 or !web) | compact (+ some medium on native) |
| `isTab` (650–1299) | medium + expanded |
| `isDesktop` (≥1300) | large |

Do not break existing `isDesktop` call sites in Phase 1 — migrate gradually.

---

## 2. Layout Rules

### Compact
- Single column
- Page padding `AppSpacing.page` = 20
- Bottom nav island + optional cart dock
- Sheets = full width, `xl` top radius

### Medium
- Single column with wider cards
- Optional 2-col food grids
- Padding 24–32

### Expanded
- 2-pane where useful (orders list | detail; chat list | thread)
- Restaurant menu: sticky category rail
- Padding 32

### Large
- Max content width **1120–1200** (replace rigid 1170-only thinking with centered canvas)
- Top `AppWebNav`
- Multi-column home modules (still airy — max 2 content columns + margin)
- Footer `AppFooter`

---

## 3. Forbidden Patterns

- Fixed `height:` that clips text at large text scale
- `Positioned` badges outside hit targets without padding
- Assuming landscape = desktop
- Duplicate entire screen files per breakpoint when `LayoutBuilder` / adaptive widgets suffice
- Hardcoded `Get.context!.width >= 1300` inside Dimensions font getters long-term

---

## 4. Adaptive Components

| Component | Compact | Large |
|-----------|---------|-------|
| Food card | vertical grid 2-col | horizontal / 3–4 col |
| Restaurant card | full-bleed image | denser grid |
| Checkout | stacked sections | 2-col (form \| summary sticky) |
| Cart | list + bottom CTA | list \| summary |
| Profile | stacked groups | centered max 720 |
| Search | full-screen | centered panel |

---

## 5. Foldables / Landscape

- Use `MediaQuery.orientation` + shortestSide
- Avoid permanent bottom sheet covering >45% on landscape phone — use side sheet or push route
- Map screens: split list/map when `expanded+`

---

## 6. Overflow Hardening Checklist

Per screen:

- [ ] Long restaurant / food names → maxLines + ellipsis
- [ ] Currency strings → no overflow Row without Flexible
- [ ] Address lines → wrap
- [ ] Keyboard insets → `resizeToAvoidBottomInset` / padded CTA
- [ ] TextScaler 1.3 smoke test
- [ ] Smallest device ~320–360 width smoke test

---

## 7. AS-IS Issues to Fix

1. Tablet often gets phone layout stretched (650–1299 treated poorly)
2. Theme1 + default + web triple maintenance
3. Home modules not reflowing — same vertical stack everywhere
4. Checkout not using sticky summary on wide
5. Magic heights in shimmers ≠ real cards after redesign (sync skeletons)

---

## 8. Verification Matrix

| Device class | Portrait | Landscape |
|--------------|----------|-----------|
| Small Android (360) | required | required |
| Medium Android (411) | required | required |
| Large Android (480+) | required | required |
| Tablet 10" | required | required |
| Foldable | required | required |
| Web 1280 / 1440 / 1920 | — | required |
