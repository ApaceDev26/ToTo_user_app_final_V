# Component Library — Audit & Target Map

**Status:** Discovery  
**Rule:** One component per concern. Delete duplicate families after migration.

---

## 1. Inventory — Common Widgets (AS-IS)

| Widget | Role | Target replacement | Action |
|--------|------|--------------------|--------|
| CustomButtonWidget | Primary CTA | `AppButton` | Rewrite |
| CustomTextFieldWidget | Form input | `AppTextField` | Rewrite |
| MyTextFieldWidget | Legacy input | — | Delete after migrate |
| SearchFieldWidget | Search | `AppSearchBar` | Rewrite |
| WebSearchFieldWidget | Web search | merge into `AppSearchBar` | Merge |
| CustomAppBarWidget | App bar | `AppTopBar` | Rewrite |
| WebMenuBar | Web nav | `AppWebNav` | Rewrite |
| CustomDialogWidget | Dialog host | `AppDialog` | Rewrite |
| ConfirmationDialogWidget | Confirm | `AppConfirmDialog` | Rewrite |
| CustomBottomSheetWidget | Sheet host | `AppSheet` | Rewrite |
| ProductBottomSheetWidget | Food configure | `AppProductSheet` | Redesign layout |
| CustomSnackbarWidget | Snackbar | `AppSnack` | Rewrite |
| CustomToast | Toast | merge `AppSnack` | Merge |
| CustomLoaderWidget | Spinner | `AppLoader` | Rewrite |
| ProductShimmerWidget | Skeleton | `AppSkeleton` family | Systemize |
| ProductWidget | Food/resto row | `AppFoodCard` / `AppRestaurantCard` | Split + redesign |
| NewProductWidget | Alt card | — | Delete after migrate |
| WebProductWidget / WebItmWidget | Web cards | responsive variants of App*Card | Merge |
| DiscountTag* (×3) | Discount | `AppTag.discount` | Merge |
| QuantityButtonWidget | Qty | `AppQtyStepper` | Rewrite |
| RatingBarWidget | Stars | `AppRating` | Rewrite |
| CustomFavouriteWidget | Fav heart | `AppFavoriteToggle` | Keep anim, restyle |
| BottomCartWidget | Sticky cart | `AppCartDock` | Redesign |
| CartWidget | Cart icon badge | `AppCartBadge` | Rewrite |
| NoDataScreen | Empty | `AppEmptyState` | Rewrite |
| NoInternetScreen | Offline | `AppErrorState.offline` | Rewrite |
| NotFoundWidget | 404 | `AppErrorState.notFound` | Rewrite |
| NotLoggedInScreen | Guest gate | `AppAuthGate` | Redesign |
| PaginatedListViewWidget | Infinite list | keep logic, wrap chrome | Presentation only |
| CustomImageWidget | Net image | `AppImage` | Soften placeholders |
| CodePickerWidget | Country | keep behavior, restyle | Presentation |
| FooterViewWidget | Web footer | `AppFooter` | Redesign |
| MenuDrawerWidget | Drawer | likely remove / replace IA | Redesign |

---

## 2. Home Cards — Collapse Plan

| AS-IS | → Target |
|-------|----------|
| item_card_widget | `AppFoodCard.vertical` |
| new_item_card_widget | delete |
| new2_item_card_widget | delete |
| horizontal_food_card | `AppFoodCard.horizontal` |
| restaurant_page_new_item_card_widget | `AppFoodCard` variant |
| restaurants_card_widget | `AppRestaurantCard` |
| theme1/restaurant_widget | delete after theme unify |
| popular_* views | section composers using App*Card |
| banner_view / banner_view_widget1 / web_banner | `AppHeroBanner` |
| cuisine_card / theme1 cuisine | `AppCuisineTile` |
| what_on_your_mind_view | `AppCategoryRail` |

**Home composition (new):** fewer sections; config flags still respected (logic), presentation curated.

---

## 3. Feature Components Map

### Auth
Sign-in/up widgets, social login, OTP fields → `AppAuthScaffold`, `AppOtpField`, `AppSocialButton`

### Cart
`cart_product_widget`, `new_cart_product_widget` → single `AppCartLine`  
`pricing_view_widget` → `AppPriceSummary`  
`checkout_button_widget` → `AppButton` + dock

### Checkout
Section widgets keep structure/logic; chrome → `AppCheckoutSection`, `AppPaymentTile`, `AppAddressTile`

### Orders
Order cards / track views → `AppOrderCard`, `AppTrackTimeline`

### Wallet / Loyalty / Coupon
Card widgets → `AppWalletHero`, `AppLoyaltyCard`, `AppCouponCard`

### Chat
Bubbles → `AppChatBubble` using ColorResources replacement tokens

### Profile / Menu
`portion_widget`, `profile_button_widget` → `AppSettingsGroup`, `AppSettingsTile`

---

## 4. Overlays Inventory

### Dialogs (24) → AppDialog variants
confirmation, custom, demo reset, in-app message, address confirm, auth, image, address, congratulation, offline success, order successful, partial pay, payment failed, cashback, location search, permission, pick map, notification, cancellation, log, offline info edit, subscription pause, review, add fund, fund payment

### Bottom sheets (26) → AppSheet variants
product, existing user, business payment, not available, coupon, delivery instruction, dine-in date, payment method (+2), time slot, address, registration success, dine-in filter, refer, language, loyalty, add fund, notification, log, account deletion, notification status, bottom sheet view, withdraw request

**Rule:** shared shell (handle, radius, padding, CTA row); content slots only differ.

---

## 5. State Components

| State | AS-IS | Target |
|-------|-------|--------|
| Loading page | CustomLoader / CircularProgress | `AppLoader` + optional branded mark |
| List loading | per-feature shimmer | `AppSkeleton.*` matching cards |
| Empty | NoDataScreen flags | `AppEmptyState(type:)` enum |
| Error | scattered snackbars | `AppErrorState` + `AppSnack.error` |
| Offline | NoInternetScreen | `AppErrorState.offline` |
| Guest | NotLoggedInScreen | `AppAuthGate` |

---

## 6. Phase 2 Deliverables (components/)

```
lib/design_system/components/
  app_button.dart
  app_text_field.dart
  app_search_bar.dart
  app_top_bar.dart
  app_card.dart
  app_food_card.dart
  app_restaurant_card.dart
  app_category_tile.dart
  app_chip.dart
  app_badge.dart
  app_tag.dart
  app_divider.dart
  app_qty_stepper.dart
  app_rating.dart
  app_favorite_toggle.dart
  app_sheet.dart
  app_dialog.dart
  app_snack.dart
  app_loader.dart
  app_skeleton.dart
  app_empty_state.dart
  app_error_state.dart
  app_price_text.dart
  app_status_chip.dart
  app_nav_island.dart
  app_cart_dock.dart
```

Each: documented props, theme-driven, const where possible, a11y labels.

---

## 7. Acceptance for Components

- [ ] No feature imports old `CustomButtonWidget` after Phase 11
- [ ] Single food card API
- [ ] Single restaurant card API
- [ ] Zero duplicate discount tags
- [ ] All colors from AppColors
- [ ] All spacing from AppSpacing
- [ ] Analyze clean
