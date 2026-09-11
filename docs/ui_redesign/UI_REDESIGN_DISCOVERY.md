# UI Redesign Discovery — toto_user

**Phase:** Discovery (Phase 0)  
**Date:** 2026-08-06  
**Status:** COMPLETE — no Dart code modified  
**Scope:** Flutter User App presentation layer only  

---

## 1. Executive Verdict

App = **Codecanyon / StackFood-derived food delivery template** with local orange brand paint (`#FF7918` / `#FF5F15`) + Poppins.

Visual DNA = marketplace template, not premium product. Dense home feed, duplicated card families (`theme1` vs default vs `new_*` vs `web_*`), hardcoded colors/spacing, weak a11y.

**Redesign goal:** complete visual separation. Same business logic. Different product feel.

---

## 2. Project Snapshot

| Metric | Count |
|--------|------:|
| Dart files (`lib/`) | 665 |
| `*widget*.dart` | 230 |
| Feature modules | 33 |
| Screen-like routes | ~70+ |
| Common widgets | 64 |
| Dialogs | 24 |
| Bottom sheets | 26 |
| Shimmer files | 9 |
| Hardcoded `Color(0x…)` | ~63 |
| `Colors.*` usages | ~838 |
| Magic `BorderRadius.circular(N)` | ~94 |
| Hardcoded `EdgeInsets` (non-Dimensions) | ~772 |
| `Semantics` / `semanticLabel` | **2** |

**Stack:** Flutter 3.4+, GetX, Drift cache (`data_source/cache_response.dart`), Firebase, Google Maps, shimmer_animation, Lottie, Iconsax.

**Font:** Poppins only (Regular/Medium/Bold/Black).

**App name:** `TastySo Food Delivery` (`AppConstants.appName`).

---

## 3. Current Design System (AS-IS)

### 3.1 Colors

| Token (implicit) | Light | Dark | Notes |
|------------------|-------|------|-------|
| Primary | `#FF5F15` / `#FF7918` | `#FF7918` | Split primary vs ColorScheme — inconsistent |
| Secondary | `#FF7918` | `#9BFF7918` | Alpha secondary in dark |
| Tertiary | `#102F9C` | `#6165D7` | Blue accent unused coherently |
| Surface | `#F5F6F8` | `#272727` | |
| Card | `Colors.white` | `#141313` | |
| Hint | `#5E6472` | `#5E6472` | Same in dark → contrast fail |
| Disabled | `#9B9B9B` | `#a2a7ad` | |
| Error | `#E84D4F` | `#dd3135` | |
| Chat bubbles | via `ColorResources` | partial | Only chat-specific |

**No** centralized `AppColors`. Themes hardcode hex. Widgets use `Colors.grey`, `Colors.white`, raw hex.

### 3.2 Typography

| Style | Weight | Base size |
|-------|--------|-----------|
| `robotoRegular` | w400 | `fontSizeDefault` (14/16) |
| `robotoMedium` | w500 | same |
| `robotoBold` | w700 | same |
| `robotoBlack` | w900 | same |

Misnamed (`roboto*` → Poppins). No display / title / caption / label scale. Size mutated ad-hoc via `.copyWith(fontSize: …)`.

### 3.3 Spacing (`Dimensions`)

| Token | Value |
|-------|------:|
| padding ExtraSmall → ExtraOverLarge | 5, 10, 15, 20, 25, 30, 35 |
| radius Small → ExtraLarge | 5, 10, 15, 20 |
| webMaxWidth | 1170 |
| Font sizes | context-width gated (≥1300) |

**Debt:** ~772 hardcoded EdgeInsets bypass tokens. Font getters use `Get.context!` → fragile.

### 3.4 Elevation / Shadows

No `AppShadows`. Ad-hoc `BoxShadow` / `Material` elevation. `shadowColor` alpha 0.03 only.

### 3.5 Theme files

- `lib/theme/light_theme.dart`
- `lib/theme/dark_theme.dart`
- Toggle: `ThemeController`

ThemeData incomplete: no `textTheme`, `inputDecorationTheme`, `elevatedButtonTheme`, `cardTheme`, `appBarTheme`, `bottomNavigationBarTheme` as full system.

### 3.6 Icons

Mix: Material Icons, Iconsax, Iconsax Plus, Icons Plus, Font Awesome, SVG assets (`assets/icons/`). No single icon set policy.

---

## 4. Current Widgets / Components

### 4.1 Common (`lib/common/widgets/`) — 64 files

**Core:** `CustomButtonWidget`, `CustomTextFieldWidget`, `MyTextFieldWidget` (duplicate input), `CustomAppBarWidget`, `CustomDialogWidget`, `CustomBottomSheetWidget`, `CustomSnackbarWidget`, `CustomToast`, `CustomLoaderWidget`

**Commerce:** `ProductWidget`, `NewProductWidget`, `WebProductWidget`, `WebItmWidget`, `ProductViewWidget`, `ProductBottomSheetWidget`, `DiscountTagWidget` (+ without image + new), `QuantityButtonWidget`, `RatingBarWidget`, `BottomCartWidget`, `CartWidget`

**States:** `NoDataScreen`, `NoInternetScreen`, `NotFoundWidget`, `NotLoggedInScreen`, `NotAvailableWidget`

**Web:** `WebMenuBar`, `WebPageTitleWidget`, `WebScreenTitleWidget`, `WebSearchFieldWidget`, `FooterViewWidget`, …

**Other:** favourites, dividers, dropdown, code picker, cookies, image viewer, paginated list, veg filter, tooltips

### 4.2 Home widget explosion (`features/home/widgets/`)

54+ widgets including parallel families:

| Family | Examples |
|--------|----------|
| Default | `banner_view_widget`, `item_card_widget`, `popular_foods_nearby_view_widget` |
| `new_*` | `new_item_card_widget`, `new2_item_card_widget`, `new_popular_foods_nearby_view_widget` |
| `theme1/` | `banner_view_widget1`, `category_widget1`, `popular_store_widget1`, … |
| `web/` | `web_banner_view_widget`, `web_cuisine_view_widget`, … |
| Restaurant page | `restaurant_page_new_item_card_widget`, `restaurants_card_widget` |

**Design debt:** 3–4 visual languages for same entity (food/restaurant card).

### 4.3 Navigation

- Mobile: `DashboardScreen` + custom `BottomNavItem` (SVG) — Home / Orders / Cart / Cart(dup slot) / Menu
- Web: `WebMenuBar`
- Routes: `RouteHelper` (GetX) — **DO NOT CHANGE logic**
- Drawer: `MenuDrawerWidget`

### 4.4 Feedback

- Snackbar: `custom_snackbar_widget.dart`
- Toast: `custom_toast.dart`
- Dialogs: 24 files (confirm, payment fail, cashback, auth, …)
- Sheets: 26 files (product, coupon, payment, address, account deletion, …)

---

## 5. Feature Map (UI surface)

| Feature | Screens | Widgets | Redesign priority |
|---------|--------:|--------:|-------------------|
| splash | 1 | 0 | P3 Auth |
| onboard | 1 | 0 | P3 |
| auth | 6 | 18 | P3 |
| verification | 4 | 0 | P3 |
| language | 2 | 2 | P3 |
| location | 3 | 1 | P3 |
| dashboard | 1 | 3+ | P4 |
| home | 4 | 54 | P4 |
| category | 2 | 0 | P4 |
| cuisine | 2 | 1 | P4 |
| search | 1 | 4 | P4 |
| restaurant | 6 | 5 | P5 |
| product | 2 | 0 | P6 |
| cart | 1 | 8 | P7 |
| checkout | 6 | 10 | P8 |
| order | 5 | 11 | P9 |
| menu / profile | 1+2 | 5 | P10 |
| wallet / loyalty / coupon / favourite / chat / support / notification / refer / review / business / dine_in / html / update / interest | … | … | P11 |

---

## 6. UX Problems

1. **Home overload** — banners + categories + campaigns + popular + reviewed + cuisine + dine-in + refer + all restaurants = endless scroll fatigue.
2. **Bottom nav** — duplicate Cart slot in `_screens` list; weak IA.
3. **Menu = orange header dump** — dense link list, template profile chrome.
4. **Product bottom sheet** — dense, long, hard to scan modifiers.
5. **Checkout** — long vertical form; section hierarchy weak.
6. **Duplicate card patterns** → inconsistent density/radius/shadow across lists.
7. **Empty states** — small asset + muted text; boolean flag explosion on `NoDataScreen`.
8. **Loading** — mix CircularProgressIndicator + uneven shimmers; not skeleton-system.
9. **Search** — standard template search; weak progressive disclosure.
10. **Touch targets** — badge 15×15, icons 22; some below 44×44.

---

## 7. Visual Inconsistencies

- Primary hex mismatch: `primaryColor` `#FF5F15` vs scheme `#FF7918`
- Dark hintColor identical to light → unreadable secondary text
- Radius: tokens 5–20 vs magic 500 FAB circle + random circulars
- Product card: `ProductWidget` vs `NewProductWidget` vs `ItemCard` vs `NewItemCard` vs `New2ItemCard` vs theme1 vs web
- Button radius default 10; many screens override differently
- Web vs mobile separate visual trees (expected) but no shared atoms

---

## 8. Component Duplication

| Concern | Duplicates |
|---------|------------|
| Food card | ProductWidget, NewProductWidget, WebProductWidget, WebItmWidget, ItemCardWidget, NewItemCardWidget, New2ItemCardWidget, HorizontalFoodCard, theme1 popular item |
| Restaurant card | ProductWidget(isRestaurant), RestaurantsCardWidget, theme1 RestaurantWidget, WebRestaurantWidget, PopularRestaurantsView |
| Discount tag | DiscountTagWidget, DiscountTagWithoutImageWidget, NewDiscountTagWidget |
| Text field | CustomTextFieldWidget, MyTextFieldWidget, SearchFieldWidget, WebSearchFieldWidget |
| Payment sheet | payment_method_bottom_sheet + payment_method_bottom_sheet2 |
| Home themes | HomeScreen + Theme1HomeScreen + WebHomeScreen |

---

## 9. Design Debt Summary

| Debt | Severity |
|------|----------|
| Template orange + Poppins marketplace look | Critical (identity) |
| No AppColors / AppTypography / AppShadows | Critical |
| Widget family explosion (theme1/new/web) | Critical |
| Hardcoded Colors / EdgeInsets | High |
| Incomplete ThemeData | High |
| Empty/error state flag soup | Medium |
| Icon library sprawl | Medium |
| Misnamed roboto* styles | Low |
| Dimensions.font* needs Get.context | Medium (runtime risk) |

---

## 10. Accessibility Problems

- Semantics ≈ **2** usages across entire lib
- Dark mode hint/disabled contrast insufficient
- Many InkWell/GestureDetector without labels
- Text scale: fixed sizes; limited TextScaler awareness
- Tap targets often < 44dp
- Focus order / keyboard: web partial via TextFields only
- RTL: GetX localization present; visual RTL polish unverified

---

## 11. Dark Mode Readiness

| Area | Status |
|------|--------|
| Theme toggle | Exists |
| Surface/card | Defined |
| Hint/disabled | **Broken contrast** |
| Hardcoded `Colors.white` / `Colors.grey[200]` | Widespread → light-only islands |
| Images/SVGs | Some tinted; many assume light |
| Shimmer grey indices | Theme-branched in places; inconsistent |

**Verdict:** Dark mode present but not production-quality.

---

## 12. Performance Risks (UI-related)

- Home `loadData` fires many controllers at once (logic untouched; UI must not add rebuild weight)
- Large `GetBuilder` trees in home/restaurant/cart
- Nested list builders + shimmer packs
- `ProductWidget` ~680 lines — heavy build
- Image hover scale animations on web
- Avoid new nested builders / non-const churn in redesign
- Keep Drift / cache / API paths untouched

**DO NOT TOUCH (logic/cache):**

- `lib/data_source/cache_response.dart` (+ `.g.dart`)
- Controllers / services / repositories / models (behavior)
- `RouteHelper` navigation rules
- Auth / order / checkout / payment / notification **logic**
- Laravel / APIs

---

## 13. Responsive Issues

Breakpoints (`ResponsiveHelper`):

| Mode | Width |
|------|-------|
| Mobile | `< 650` or non-web |
| Tablet | `650–1299` |
| Desktop | `≥ 1300` |

Issues:

- Binary mobile/desktop forks → tablet often gets mobile layout stretched
- Fixed heights in cards/headers
- `webMaxWidth: 1170` only constraint; foldables/landscape under-specified
- Theme1 vs default home switch adds responsive complexity
- Overflow risk in long Text (restaurant names, addresses) — classic template issue

---

## 14. Animations (AS-IS)

Present: Lottie splash, shimmer, favourite scale, dialog scale, running-order pulse, carousel, animated_text_kit, expandable bottom sheet, page indicators.

Missing system: no `AppDurations`, no shared page transition theme, inconsistent curves, no list stagger language.

---

## 15. Untouchable Boundary Map

```
PRESENTATION (rewrite)          BUSINESS (freeze)
─────────────────────           ─────────────────
theme/*, util/styles,           controllers/
  dimensions, colors            domain/services|
common/widgets/*                domain/repositories|
features/*/screens              domain/models|
features/*/widgets              api/|
assets visual                   data_source/cache*
RouteHelper presentation only   RouteHelper paths/args
                                Auth/Order/Cart logic
                                Laravel backend
```

---

## 16. Phase Plan (locked)

| Phase | Focus | Gate |
|------:|-------|------|
| 0 | Discovery docs | DONE |
| 1 | Design System tokens + Theme | analyze clean |
| 2 | Reusable components | analyze clean |
| 3 | Auth / splash / onboard | … |
| 4 | Home / dashboard / category / search | |
| 5 | Restaurant | |
| 6 | Food / product | |
| 7 | Cart | |
| 8 | Checkout | |
| 9 | Orders | |
| 10 | Profile / menu / settings | |
| 11 | Remaining screens | |
| 12 | Animations | |
| 13 | Responsive polish | |
| 14 | Accessibility | |
| 15 | Production polish | |

---

## 17. Success Check (reminder)

Side-by-side screenshots vs old app → must read as **different product**.  
Business flows identical. Visual identity new.

---

## 18. Related Docs

- [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) — target tokens
- [COMPONENT_LIBRARY.md](./COMPONENT_LIBRARY.md)
- [SCREEN_AUDIT.md](./SCREEN_AUDIT.md)
- [RESPONSIVE_GUIDE.md](./RESPONSIVE_GUIDE.md)
- [ANIMATION_GUIDE.md](./ANIMATION_GUIDE.md)
- [ACCESSIBILITY_REPORT.md](./ACCESSIBILITY_REPORT.md)
- [UI_REDESIGN_CHANGELOG.md](./UI_REDESIGN_CHANGELOG.md)
