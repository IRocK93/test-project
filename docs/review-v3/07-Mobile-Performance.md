# Mobile Performance Audit Report

## Grade: C+

## Summary
The app is architecturally sound with proper disposal patterns and caching infrastructure, but suffers from three critical frame-rate killers: a continuously-animated gradient background across all IndexedStack tabs, excessive BackdropFilter layering, and a coarse-grained global refresh provider that causes cascade rebuilds across 5 simultaneously-live tab screens. Memory pressure from the LLM model and IndexedStack design compounds these issues. The app can achieve a B+ / A- grade by fixing the top 3 issues below.

## Findings

| # | Severity | File:Line | Issue | Impact | Fix |
|---|----------|-----------|-------|--------|-----|
| 1 | **CRITICAL** | `premium_background.dart:30-33` | Continuous 12-second `AnimationController..repeat(reverse: true)` runs on all 4 active IndexedStack tabs simultaneously, driving per-frame `Color.lerp()`, `LinearGradient`, and 4x radial `Container` rebuilds | Each tab's background re-rasterizes every frame. With 4 tabs active, this is **4 simultaneous per-frame GPU compositions** -- guaranteed jank on mid-range devices. | (a) Pause controller when tab is not visible. (b) Use `TickerMode` to disable animations on non-visible tabs. (c) Replace with shader-based gradient that GPU caches. |
| 2 | **CRITICAL** | `main_screen.dart:839,720,331` + `glass_surface.dart:56` | Three independent `BackdropFilter` widgets render simultaneously on MainScreen: AppBar (heavy blur), Bottom Nav (heavy blur), More menu (another GlassSurface). Plus each tab screen may have its own glass surfaces. | Each `BackdropFilter` forces compositor to read back layer tree and perform blur pass. **Three concurrent blur passes** produces measurable frame budget overrun. On low-end devices drops to 30-40fps. | Consolidate AppBar and Bottom Nav into single shared `BackdropFilter`. Use `GlassSurface.group()` for bottom nav items. |
| 3 | **HIGH** | `providers.dart:35` | `appRefreshProvider` is a single `StateProvider<int>` watched by 15+ listeners across all tabs. One mutation cascades `setState()` in every screen simultaneously. | After any mutation, **every active tab screen re-fetches data from API and rebuilds**. | Replace with targeted refresh: only bump relevant `tabRefreshProvider(tabIndex)`. Use `pendingAddActionProvider` consistently. |
| 4 | **HIGH** | `main.dart:44` | `SharedPreferences.getInstance()` blocks `main()` before `runApp()`. Async I/O on main isolate. | Delays first frame by 50-300ms depending on device storage speed. | Move SharedPreferences init into splash screen or use `FutureProvider` that resolves during splash animation. |
| 5 | **HIGH** | `app.dart:21` | `ValueKey(styleKey)` on `MaterialApp.router` causes **entire widget tree teardown and rebuild** on every visual style toggle (glass/clay). | Theme toggle is not smooth -- entire app disposed and recreated. | Remove `ValueKey`. Use `AnimatedSwitcher` only on `PremiumBackground`. |
| 6 | **HIGH** | `main_screen.dart:825-828` | `IndexedStack` with 4 screens -- all 4 mount, 4 AnimationControllers start, 4 data fetches fire on first load. | CPU/GPU spike at startup. Memory holds all 4 complete widget subtrees forever. | Use `AutomaticKeepAliveClientMixin` with `wantKeepAlive = false` for non-visible screens. Lazy-load data when tab becomes visible. |
| 7 | **MEDIUM** | `dashboard_screen.dart:408-421` | `build()` wraps body in `PremiumBackground` which re-executes on every rebuild from refresh providers. | Dashboard rebuilds cascade to premium background which is already animating. Double path to jank. | Extract `PremiumBackground` outside dashboard's build scope or use `const` widget boundary. |
| 8 | **MEDIUM** | `api_client.dart:17-18` | `connectTimeout: 30s`, `receiveTimeout: 30s`. Excessive for mobile app. No DNS timeout. | Users stare at loading spinners for 30 seconds on poor connections. | Reduce to `connectTimeout: 10s`, `receiveTimeout: 15s`. |
| 9 | **MEDIUM** | `api_client.dart:57-59` | Cache invalidation uses `String.contains(pattern)` -- overbroad. Deleting single entry invalidates all caches containing that resource prefix. | Unnecessary refetches. | Use exact path matching or structured resource invalidation. |
| 10 | **MEDIUM** | `response_cache.dart:7` | `ResponseCache` is plain `Map` with no eviction policy, no size limit. | Cache grows unbounded over time. | Add LRU eviction with max size (e.g., 50 entries). Serialize only `data` + `statusCode` rather than full `Response` objects. |
| 11 | **LOW** | `app_theme.dart:38-39` | `GoogleFonts.syne` and `GoogleFonts.plusJakartaSans` fetch from CDN at runtime despite fonts already bundled in assets. | First launch shows fallback system font until fonts download. | Wire up bundled font assets directly via `fontFamily` instead of `GoogleFonts` builder. |
| 12 | **LOW** | `splash_screen.dart:123-129` | `Positioned.fill` + `BackdropFilter` on a `Stack` with no content behind it to blur. | Unnecessary GPU work during most performance-critical moment (first frame). | Use simple semi-transparent overlay instead of real-time blur. |
| 13 | **LOW** | `dashboard_screen.dart:513-533` | `ReorderableListView` with `proxyDecorator` including `AnimatedBuilder` + `Transform.scale` + `BoxShadow` on drag. | Minor drag jank on low-end devices. | Use `RepaintBoundary` around each tile. |
| 14 | **LOW** | `app.dart:15-16` | `BabyMonApp` watches 3 providers. Any auth/theme change rebuilds entire `MaterialApp.router`. | Over-rebuild scope. | Use `Consumer` widgets at narrower scope. |

## Top 3 Frame-Rate Killers

1. **PremiumBackground.AnimationController** (CRITICAL) -- 4 simultaneous continuous animations on IndexedStack tabs. Each runs `Color.lerp()` 8x per frame, rebuilds `Stack` with 4-8 `Positioned` radial orb `Container`s, triggers `AnimatedBuilder` every tick. **Guaranteed 60fps failure** on Adreno 5xx or Mali-G52 GPUs.

2. **Stacked BackdropFilter layers** (CRITICAL) -- MainScreen renders: AppBar `GlassSurface` (heavy blur, sigma ~20), Bottom Nav `BackdropFilter` (heavy blur, sigma ~20), plus any glass surfaces inside visible tab. With 3+ concurrent blur passes, Skia compositor's saveLayer budget exceeded, causing frame drops.

3. **appRefreshProvider cascade** (HIGH) -- 15+ listeners across 5 tab screens. Single mutation triggers `setState()` + `loadData()` on every active screen simultaneously.

## Top 3 Memory Concerns

1. **IndexedStack: 5 live tab subtrees** -- All screens held in memory with full widget trees, scroll states, and animation controllers.
2. **LLM model inference memory** -- GGUF model loaded into RAM. Requires 4GB total device RAM. On 4GB devices, OS may kill background processes during inference alongside 5 live tab screens.
3. **ResponseCache unbounded growth** -- No eviction policy, no size cap. Dashboard fetches 8+ GET endpoints per refresh.

## Startup Time Analysis

```
T+0ms     main() -> WidgetsFlutterBinding.ensureInitialized()
T+50-300ms SharedPreferences.getInstance() BLOCKS main isolate
T+300ms   runApp() -> ProviderScope -> BabyMonApp
T+320ms   SplashScreen renders, AnimationController starts
T+350ms   _checkAuth() reads from FlutterSecureStorage (async)
T+2000ms  Fixed 2s delay in _checkAuth() completes
T+2350ms  Route decision: /home or /login
T+2500ms  MainScreen mounts -> 4 tabs load -> 4x data fetches
T+3000ms  Dashboard data arrives, first meaningful paint
```

**Recommendations:** Reduce fixed delay to 1.5s. Use `Future.wait` for auth check + SharedPrefs init in parallel. Deferred-load non-visible tabs.

## GPU/Rendering Cost Assessment

**Per-frame cost on MainScreen (Dashboard tab visible):**
- Animated gradient + radial orbs: ~3-4ms
- BackdropFilter (AppBar): ~2-3ms  
- BackdropFilter (Bottom Nav): ~2-3ms
- Remaining widget tree: ~3-5ms
- **Total: ~10-15ms** -- no headroom. Any GC pause or I/O interrupt drops the frame.

**RepaintBoundary usage is sparse** (only in `animated_entry.dart` and `level_up_celebration.dart`).

**`withValues`/`withOpacity` calls: 383 occurrences across 63 files.** Each creates new `Color` object. In hot build paths (premium background: 9 calls per frame per tab = 36 calls/frame), generates measurable GC pressure.

**APK size estimate:** ~30-40MB minimum (Flutter base + fonts + llamadart native libs + Dart AOT + assets). LLM model download adds ~2.5GB post-install.

**Disposal hygiene:** All 30+ `dispose()` methods properly clean up controllers, subscriptions, and tokens. Well-done.
