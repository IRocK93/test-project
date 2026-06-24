# BabyMon Performance Audit — v4

**Date:** 2026-06-22
**Overall Grade: D+ (54/100)**

---

## Mobile: Frame Rate — THE #1 ISSUE

### Glassmorphism GPU Overload (Grade: F)

**4 Animated Radial Orbs:**
- `premium_background.dart`: `AnimatedBuilder` with 12-second repeating `AnimationController` driving 4 repositioned radial orbs
- Wraps EVERY screen (Dashboard, Feeding, Milestones, Health, Album, Journal, Discover)
- Continuous 60fps GPU composition while app is open

**Cascading BackdropFilter (3+ per screen):**
- `MainScreen` bottom nav: `BackdropFilter` sigma 8.0
- `MainScreen` AppBar: `GlassSurface` with `BackdropFilter`
- `DashboardScreen`: `BackdropFilter` in edit sheet
- Every `GlassSurface` widget adds another blur pass

**Extreme Blur Intensity:**
- `design_tokens.dart`: `glassBlurMd = 15.0`, `glassBlurHeavy = 24.0` sigma
- Standard practice: 4-8 sigma. At sigma=24, GPU samples 96px radius per pixel
- Splash screen uses sigma 24 on full-screen BackdropFilter

**RepaintBoundary nearly nonexistent** — only 2 files use it

---

## Backend Query Hotspots

| Hotspot | Location | Impact |
|---------|----------|--------|
| Badge check loads entire entity history | `badges.service.ts:147-151` | N+1 — 5000 rows loaded per mutation |
| Evolution service double-lookup | `evolution.service.ts:15,39` | 2 DB round-trips for same entity |
| Journal unbounded | `journal.service.ts:17-29` | All entries loaded, no pagination |
| No caching anywhere | Global | Grade: F |

---

## Network Performance

### Dashboard Waterfall: 9 HTTP Requests
```
Future.wait([
  _fetchBabyMon,       // GET /api/baby-mons/:id
  _fetchEvolution,     // GET /api/baby-mons/:id/evolution
  _fetchGrowth ×2,     // 2x GET growth (WEIGHT, HEIGHT)
  _fetchAllergies,     // GET allergies
  _fetchProfile,       // GET /api/users/me
])
// then 3 more requests for cosmetic data
// then 1 more for stage content
```
**No backend aggregation endpoint exists.**

### Other Network Issues
- No compression middleware (Express compression not enabled)
- No exponential backoff — retry interceptor only handles 401
- No request deduplication — identical simultaneous calls both fire

---

## Concrete Recommendations

### Priority 1 — Immediate (30-50% frame rate improvement)
1. **Remove `AnimatedBuilder` from `PremiumBackground`** — replace with static gradient
2. **Move BackdropFilter to single ancestor level** — eliminate cascading blur passes
3. **Reduce blur sigma from 15/24 to 4-8**
4. **Fix badge N+1 query** — use `_count` instead of `include`

### Priority 2 — Short-term (2-3x faster screen loads)
5. Create `/api/dashboard/:id` aggregation endpoint (9→1 round-trips)
6. Add Express compression middleware
7. Add pagination to journal endpoint
8. Move `SharedPreferences.getInstance()` out of blocking `main()`
9. Eliminate 2-second `Future.delayed` in splash screen

### Priority 3 — Medium-term
10. Add server-side Redis caching
11. Add `const` to all eligible widgets
12. Replace `ListView()` with `ListView.builder()` in feeding/drawer
13. Add image memory constraints to `CachedNetworkImage`
14. Add exponential backoff to API client
15. Add request deduplication

---

## Summary Scorecard

| Category | Grade |
|----------|-------|
| Backend Query Efficiency | D |
| Backend Caching | F |
| Backend Response Size | D |
| Backend Connection Pooling | C |
| Backend Background Jobs | D |
| Mobile Frame Rate | F |
| Mobile Widget Rebuilds | D |
| Mobile List Performance | C- |
| Mobile Image Handling | C+ |
| Mobile Startup Time | D |
| Mobile Memory | D+ |
| Network Request Batching | D |
| Network Payload Optimization | D- |
| Network Retry/Backoff | C |
