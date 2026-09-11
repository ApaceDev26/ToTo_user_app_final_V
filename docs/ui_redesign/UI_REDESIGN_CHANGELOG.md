# UI Redesign Changelog

Track presentation-only changes. Business logic / APIs / cache / Laravel = untouched.

---

## Phase 0 — Discovery (2026-08-06)

### Added docs
- All docs under `docs/ui_redesign/`

### Code
- No Dart changes in Phase 0

---

## Phase 1 — Design System (2026-08-06)

### Added
- `lib/design_system/app_colors.dart` — Lumen Atelier light/dark tokens
- `lib/design_system/app_typography.dart` — Fraunces display + DM Sans UI (`google_fonts`)
- `lib/design_system/app_spacing.dart`
- `lib/design_system/app_radius.dart`
- `lib/design_system/app_shadows.dart` + elevation levels
- `lib/design_system/app_durations.dart`
- `lib/design_system/app_icons.dart`
- `lib/design_system/app_theme.dart`
- `lib/design_system/design_system.dart` barrel

### Changed
- `lib/theme/light_theme.dart` / `dark_theme.dart` → `AppTheme.light/dark`
- `lib/util/app_constants.dart` — fontFamily → `DM Sans`
- `lib/util/styles.dart` — roboto* aliases → AppTypography bridge
- `lib/main.dart` — font prefetch
- `pubspec.yaml` — `google_fonts` dependency

### Identity shift
- Orange `#FF7918` → teal-forest `#0F6B5C`
- Poppins → DM Sans + Fraunces
- Grey scaffold → porcelain-mint `#F3F6F4`

---

## Phase 2 — Components (2026-08-06)

### Added under `lib/design_system/components/`
- `app_button.dart`, `app_text_field.dart`, `app_top_bar.dart`, `app_card.dart`
- `app_states.dart` (skeleton / empty / error)
- `app_feedback.dart` (sheet / dialog / snack)
- `app_primitives.dart` (badge / chip / tag / price / qty / rating / divider)
- `app_commerce_cards.dart` (restaurant + food cards)
- `app_navigation.dart` (nav island + cart dock)

### Rewired legacy
- `CustomButtonWidget` → Atelier tokens
- `NoDataScreen` → `AppEmptyState`
- `BottomNavItem` → Atelier colors + semantics
- `CustomAppBarWidget` → canvas / ink (via auth agent)

---

## Phase 3 — Auth / Splash / Onboard (2026-08-06)

- Splash — brand wordmark + calm canvas + Lottie
- Onboarding — editorial PageView + AppButton
- Sign-in / Sign-up chrome — no orange header
- `primary_header_container` — soft accent orbs
- Verification / forget-pass — in progress via agents

---

## Phase 4 — Home / Dashboard (2026-08-06)

- Dashboard — floating island bottom nav
- Home header / search / titles / category rail / banners — Atelier
- Categories moved above banner (calmer hierarchy)

---

## Phase 5–6 — Restaurant / Food (2026-08-06)

- Restaurant screen header / info section chrome
- `ProductWidget` outer shell restyle

---

## Phase 7–8 — Cart / Checkout (2026-08-06)

- Cart screen + pricing + checkout CTA
- Checkout chrome — agent pass

---

## Phase 9–10 — Orders / Profile (2026-08-06)

- Order list / cards / history tabs
- Menu — orange header removed; calm profile hero
- Profile / wallet / coupon / favourite / notification — agent pass

---

## Graphify (2026-08-06)

- Full corpus 1143 files → narrowed to `lib/common`
- Output: `graphify-out/` — 1165 nodes, 1752 edges, 55 communities
- God hubs: StatelessWidget, Product, Restaurant

---

## Phase 11 — Remaining Screens (2026-08-06)

- Product bottom sheet shell
- Chat conversation + chat screen chrome
- Loyalty, refer, support, address, access location
- Order details header, category
- Cuisine, dine-in, interest, language, update
- Order successful celebration
- Custom loader, bottom sheet shell, ColorResources chat bubbles

---

## Quiet card cohesion pass (2026-08-06)

Discarded experimental glass/cinematic cards.

### Spec
- `docs/ui_redesign/CARD_VISUAL_LANGUAGE.md` — extracted from Home/Nav/Cart/Menu

### Redesigned (cohesion, not uniqueness)
- `new_item_card_widget.dart` — 1:1 image + text below, radius md, shadow 1
- `theme1/restaurant_widget.dart` — cover 118 + text meta with middots, no floating logo
- `theme1/new_popular_store_widget1.dart` — same DNA, rail height 188

### Frozen
- `product_widget.dart` — untouched this pass


### Four critical widgets rebuilt from first principles
| Widget | New architecture |
|--------|------------------|
| `product_widget.dart` | Food: content-left + portrait media-right. Restaurant: full-bleed cover + glass dock + floating logo |
| `new_item_card_widget.dart` | Full-bleed media + gradient scrim + glass metadata dock (no orange border / split column) |
| `theme1/restaurant_widget.dart` | Cinematic cover, status pill, floating logo overlap, accentSoft meta chips |
| `theme1/new_popular_store_widget1.dart` | Tall horizontal glass-dock tiles (height 220), not 80px cover strip |

### Parallel family aligned
- `new_product_widget.dart`, `web_product_widget.dart`, `web_restaurant_widget.dart`
- `item_card_widget.dart`, `new2_item_card_widget.dart` → delegates to NewItemCardWidget
- `product_view_widget.dart` grid extents updated (156 / 292)

### Graphify
- `graphify-out/home-widgets/` — 454 nodes, 1162 edges, 19 communities

### Still remaining (honest)
- Delete dead theme1 folders after all imports point to single App* cards
- `restaurant_page_new_item_card_widget`, horizontal_food_card, popular_* legacy views
- Full purge of `Colors.*` / `Dimensions` decoration elsewhere


| Phase | Status | Notes |
|------:|--------|-------|
| 12 Animations | Partial | Theme page transitions set; hero/list stagger TBD |
| 13 Responsive | Partial | Breakpoints unchanged; Atelier padding helpers ready |
| 14 Accessibility | Partial | Semantics on nav/buttons/empty; full sweep TBD |
| 15 Production polish | Partial | design_system analyze clean; app-wide analyze TBD |

### Still owed (honest)
- Deep interiors: theme1/`new_*` food cards not fully deleted
- Product sheet variation/addon tiles
- Web-only layouts (`web_home`, `web_menu_bar`) full pass
- Business/subscription registration forms
- Full a11y + tablet matrix
- Purge remaining hardcoded `Colors.*` in feature widgets

---

## Graphify (2026-08-06)

- Full corpus 1143 files → narrowed to `lib/common`
- Output: `graphify-out/` — 1165 nodes, 1752 edges, 55 communities
- God hubs: StatelessWidget, Product, Restaurant
