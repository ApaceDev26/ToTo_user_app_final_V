# Animation Guide — Target

**Principle:** Motion clarifies hierarchy and feedback. Never decorates noise. Performance first.

---

## 1. AS-IS Motion Inventory

| Location | Type | Keep / Replace |
|----------|------|----------------|
| Splash Lottie | branded loader | Restyle asset; keep timing hooks |
| shimmer_animation | list loading | Replace with AppSkeleton geometry |
| CustomFavouriteWidget | scale spring | Keep behavior; retune curve/color |
| CustomDialogWidget | scale in | Standardize to AppDurations |
| Running order widget | pulse/scale | Soften; status-driven |
| Carousel / card_swiper | banners | Keep; gentler indicators |
| animated_text_kit | home address | Optional — reduce if noisy |
| expandable_bottom_sheet | running order | Keep logic; restyle chrome |
| smooth_page_indicator | onboarding | Restyle dots |
| Image hover scale (web) | 1.2 zoom | Tone down to 1.03–1.05 |
| Page routes (GetX default) | material/cupertino | Custom `AppPageTransition` |

---

## 2. AppDurations (canonical)

See `DESIGN_SYSTEM.md` §7.

| Token | ms |
|-------|---:|
| instant | 100 |
| fast | 180 |
| normal | 280 |
| emphasis | 400 |
| slow | 600 |

---

## 3. Allowed Motion Vocabulary

| Name | Spec | Use |
|------|------|-----|
| Fade | opacity 0→1, `fast`–`normal` | content appear |
| Slide up | offset 12–24 → 0 + fade | sheets, lists |
| Slide horizontal | 8–16% width | page (forward/back) |
| Scale | 0.96→1 | dialogs, favourite |
| Press | opacity 0.92 / scale 0.98 | buttons |
| Shimmer | linear gradient bone | skeletons only |
| Badge pop | scale spring once | cart count++ |
| Success check | path draw / Lottie once | order placed |
| Hero | shared image tag food/resto | details transitions |

**Banned:** infinite bounce, parallax stacks, confetti spam, staggered 20+ item cascades on low-end.

---

## 4. Page Transitions

```
Push:    SlideFromEnd + Fade (normal, easeOutCubic)
Modal:   SlideFromBottom (normal)
Dialog:  Fade + Scale 0.96→1 (fast)
Replace: Fade (fast)
```

Implement via `pageTransitionsTheme` + GetX `customTransition` wrapper — **do not change route names/args**.

---

## 5. List Reveal

- First paint: skeleton → fade content
- Optional: first 6 items slide-up stagger 40ms (cap)
- Paginated append: no stagger (perf)

---

## 6. Micro-interactions

| Action | Motion |
|--------|--------|
| Add to cart | button success flash + cart dock badge pop |
| Favourite | scale spring + color to accent/warm |
| Qty stepper | number crossfade / flip_counter keep if subtle |
| Order status step | timeline node fill + soft pulse once |
| Pull refresh | accent indicator |
| Toggle theme | fade surfaces `normal` |

---

## 7. Performance Rules

1. Prefer `AnimatedOpacity` / `AnimatedSlide` / implicit animations
2. One `AnimationController` per stateful micro-widget; dispose always
3. No animation inside `build` without controller reuse
4. Avoid animating large blur/shadow continuously
5. Respect `MediaQuery.disableAnimations` / `TickerMode`
6. Do not animate during rapid scroll (listener gate)

---

## 8. Phase 12 Scope

- Wire `AppDurations` everywhere
- Unified page transitions
- Hero on food image → product sheet / restaurant cover
- Cart badge + favourite polish
- Order success celebration (one tasteful Lottie)
- Remove redundant animated_text if it hurts calm brand

---

## 9. Acceptance

- [ ] No jank on mid-tier Android home scroll
- [ ] Animations disabled when OS requests
- [ ] Same durations across app
- [ ] Motion supports — not distracts from — content
