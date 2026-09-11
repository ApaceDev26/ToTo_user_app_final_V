# Screen Audit — toto_user

**Legend:** P = redesign phase · Risk = visual debt severity · Logic = freeze

---

## Auth & Entry

| Screen | Path | Phase | Risk | Notes |
|--------|------|------:|------|-------|
| Splash | `features/splash/screens/splash_screen.dart` | 3 | Med | Lottie OK; rebrand motion/colors |
| Onboarding | `features/onboard/screens/onboarding_screen.dart` | 3 | High | Template slides → editorial |
| Language | `features/language/screens/language_screen.dart` | 3 | Med | |
| Web Language | `…/web_language_screen.dart` | 3 | Med | |
| Sign In | `features/auth/screens/sign_in_screen.dart` | 3 | High | |
| Sign Up | `…/sign_up_screen.dart` | 3 | High | |
| New User Setup | `…/new_user_setup_screen.dart` | 3 | Med | |
| Restaurant Registration | `…/restaurant_registration_screen.dart` | 11 | Med | Heavy form |
| Deliveryman Registration | `…/delivery_man_registration_screen.dart` | 11 | Med | |
| Deliveryman Web Reg | `…/web/deliveryman_registration_web_screen.dart` | 11 | Med | |
| Verification / OTP | `features/verification/screens/verification_screen.dart` | 3 | High | |
| Forget Pass | `…/forget_pass_screen.dart` | 3 | Med | |
| Forget Pass Phone | `…/forget_pass_screen_phone.dart` | 3 | Med | |
| New Pass | `…/new_pass_screen.dart` | 3 | Med | |
| Access Location | `features/location/screens/access_location_screen.dart` | 3 | High | |
| Pick Map | `…/pick_map_screen.dart` | 3/8 | High | Shared address flow |
| Map | `…/map_screen.dart` | 5/9 | Med | |
| Interest | `features/interest/screens/interest_screen.dart` | 3 | Med | |
| Update App | `features/update/screens/update_screen.dart` | 11 | Low | |

---

## Shell & Home

| Screen | Path | Phase | Risk | Notes |
|--------|------|------:|------|-------|
| Dashboard | `features/dashboard/screens/dashboard_screen.dart` | 4 | Critical | Nav shell rewrite; keep page index logic |
| Home | `features/home/screens/home_screen.dart` | 4 | Critical | Biggest visual change |
| Theme1 Home | `…/theme1_home_screen.dart` | 4 | Critical | Unify into one home language |
| Web Home | `…/web_home_screen.dart` | 4 | Critical | |
| Map View | `…/map_view_screen.dart` | 4 | Med | |
| Category | `features/category/screens/category_screen.dart` | 4 | High | |
| Category Products | `…/category_product_screen.dart` | 4 | High | |
| Cuisine | `features/cuisine/screens/cuisine_screen.dart` | 4 | Med | |
| Cuisine Restaurants | `…/cuisine_restaurant_screen.dart` | 4 | Med | |
| Search | `features/search/screens/search_screen.dart` | 4 | High | Filters UX |
| Dine-In Restaurants | `features/dine_in/screens/dine_in_restaurant_screen.dart` | 4 | Med | |

---

## Restaurant & Food

| Screen | Path | Phase | Risk | Notes |
|--------|------|------:|------|-------|
| Restaurant | `features/restaurant/screens/restaurant_screen.dart` | 5 | Critical | |
| All Restaurants | `…/all_restaurant_screen.dart` | 5 | High | |
| Campaign | `…/campaign_screen.dart` | 5 | Med | |
| Web Campaign | `…/web_campaign_screen.dart` | 5 | Med | |
| Restaurant Product Search | `…/restaurant_product_search_screen.dart` | 5 | Med | |
| Popular Food | `features/product/screens/popular_food_screen.dart` | 6 | High | |
| Item Campaign | `…/item_campaign_screen.dart` | 6 | Med | |
| Product Bottom Sheet | widget (modal) | 6 | Critical | Primary food details UX |

---

## Cart & Checkout

| Screen | Path | Phase | Risk | Notes |
|--------|------|------:|------|-------|
| Cart | `features/cart/screens/cart_screen.dart` | 7 | Critical | |
| Checkout | `features/checkout/screens/checkout_screen.dart` | 8 | Critical | |
| Payment | `…/payment_screen.dart` | 8 | High | |
| Payment WebView | `…/payment_webview_screen.dart` | 8 | Med | Chrome only |
| Offline Payment | `…/offline_payment_screen.dart` | 8 | Med | |
| Order Successful | `…/order_successful_screen.dart` | 8 | High | Celebration redesign |
| Address List | `features/address/screens/address_screen.dart` | 8 | High | |
| Add Address | `…/add_address_screen.dart` | 8 | High | |

---

## Orders

| Screen | Path | Phase | Risk | Notes |
|--------|------|------:|------|-------|
| Orders | `features/order/screens/order_screen.dart` | 9 | Critical | |
| Order Details | `…/order_details_screen.dart` | 9 | Critical | |
| Order Tracking | `…/order_tracking_screen.dart` | 9 | High | |
| Guest Track | `…/guest_track_order_screen.dart` | 9 | Med | |
| Refund Request | `…/refund_request_screen.dart` | 9 | Med | |

---

## Profile & Account

| Screen | Path | Phase | Risk | Notes |
|--------|------|------:|------|-------|
| Menu | `features/menu/screens/menu_screen.dart` | 10 | Critical | Orange header dump |
| Profile | `features/profile/screens/profile_screen.dart` | 10 | High | |
| Update Profile | `…/update_profile_screen.dart` | 10 | Med | |
| Favourites | `features/favourite/screens/favourite_screen.dart` | 10 | Med | |
| Coupons | `features/coupon/screens/coupon_screen.dart` | 10 | Med | |
| Wallet | `features/wallet/screens/wallet_screen.dart` | 10 | High | |
| Withdraw History | `…/withdraw_history_screen.dart` | 10 | Med | |
| Loyalty | `features/loyalty/screens/loyalty_screen.dart` | 10 | Med | |
| Refer & Earn | `features/refer and earn/screens/refer_and_earn_screen.dart` | 10 | Med | |
| Notification | `features/notification/screens/notification_screen.dart` | 10 | Med | |
| Support | `features/support/screens/support_screen.dart` | 11 | Med | |
| HTML Viewer | `features/html/screens/html_viewer_screen.dart` | 11 | Low | |
| Review | `features/review/screens/review_screen.dart` | 11 | Med | |
| Rate Review | `…/rate_review_screen.dart` | 11 | Med | |

---

## Chat & Business

| Screen | Path | Phase | Risk | Notes |
|--------|------|------:|------|-------|
| Conversation | `features/chat/screens/conversation_screen.dart` | 11 | High | |
| Chat | `…/chat_screen.dart` | 11 | High | |
| Preview | `…/preview_screen.dart` | 11 | Low | |
| Subscription Payment | `features/business/screens/subscription_payment_screen.dart` | 11 | Med | |
| Subscription Result | `…/subscription_success_or_failed_screen.dart` | 11 | Med | |

---

## Shared / Utility Surfaces

| Surface | Path | Phase | Notes |
|---------|------|------:|-------|
| Image Viewer | `common/widgets/image_viewer_screen_widget.dart` | 11 | |
| Not Logged In | `common/widgets/not_logged_in_screen.dart` | 3/10 | |
| No Data | `common/widgets/no_data_screen_widget.dart` | 2 | |
| No Internet | `common/widgets/no_internet_screen_widget.dart` | 2 | |
| Example Nav | `examples/navigation_bar_example_screen.dart` | — | Dead? remove or ignore |

---

## Overlays (every popup)

All dialogs & bottom sheets listed in `COMPONENT_LIBRARY.md` — redesign shells in Phase 2; content pass with owning feature phase.

Dashboard popups (keep triggers):
- Registration success sheet
- Address suggest sheet
- Delivery success popup
- Refund success popup
- Congratulation dialogue (loyalty)
- Running order expandable sheet

---

## Per-Screen Differentiation Checklist

For each screen before marking done:

- [ ] Layout ≠ old
- [ ] Hierarchy ≠ old
- [ ] Spacing system = AppSpacing
- [ ] Type = AppTypography
- [ ] Components = App* only
- [ ] Nav pattern matches new shell
- [ ] Cards new structure
- [ ] Interactions new microcopy/feedback where presentation-only
- [ ] Loading = AppSkeleton
- [ ] Empty = AppEmptyState
- [ ] ≤20% visual structure retained vs old

---

## Count

| Category | Approx screens |
|----------|---------------:|
| Entry/Auth/Location | 18 |
| Shell/Home/Browse | 11 |
| Restaurant/Food | 8 |
| Cart/Checkout/Address | 8 |
| Orders | 5 |
| Profile/Account | 12 |
| Chat/Business/Other | 8+ |
| **Total primary** | **~70+** |
| + overlays | **50+** |
