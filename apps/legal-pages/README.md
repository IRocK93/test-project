# `@babymon/legal-pages`

Tiny Express service that serves BabyMon's **Privacy Policy** and **EULA** at `/privacy` and `/eula`, plus a `/health` endpoint. Designed to deploy to Railway's free tier in one command.

> **TL;DR:** `railway up` from this directory → a `*.up.railway.app` URL you paste into Google Play Console.

## Live URLs

After deployment, the `*.up.railway.app` URL gets surfaced as:

| Route | Returns |
|-------|---------|
| `GET /privacy` | BabyMon Privacy Policy (HTML) |
| `GET /eula`    | BabyMon End-User License Agreement (HTML) |
| `GET /health`  | `{"status":"ok",...}` — used by Railway healthcheck + uptime monitors |
| `GET /`        | `301` redirect to `/privacy` (so the bare domain lands somewhere useful) |

## Files in this directory

| File | Purpose |
|------|---------|
| `index.js` | Express server, ~120 lines, no DB, no auth. Two file-serving routes + a healthcheck. |
| `package.json` | Single dep: `express`. Scripts: `start`, `dev`, `sync`, `test`. |
| `Dockerfile` | Node 20-alpine, non-root user, healthcheck. Self-contained build context — does NOT reference `../mobile/tool/*`. |
| `railway.json` | Tells Railway: build via Dockerfile, listen on `/health`, restart on failure. |
| `.dockerignore` | Excludes `node_modules/`, `README.md`, `sync-legal.js`, `test/`. Small image. |
| `.gitignore` | Excludes `node_modules/`, `.railway/`, `.env`. |
| `privacy.html` | Production copy of the privacy policy. **Generated, do not edit directly.** |
| `eula.html`    | Production copy of the EULA. **Generated, do not edit directly.** |
| `sync-legal.js` | Cross-platform Node script that re-derives `privacy.html` + `eula.html` from the canonical sources. |
| `test/smoke.test.js` | `node --test` smoke test for all routes. No external deps. |
| `README.md` | You are here. |

## One-time deployment (founder runbook)

You need a Railway account (you said you have the free tier). Steps:

```bash
# From your laptop, once:
cd apps/legal-pages
npm install                # installs express + writes package-lock.json

# Install Railway CLI if not already
npm install -g @railway/cli

railway login              # opens browser, sign in

# Either create a brand-new Railway project for legal pages...
railway init --name babymon-legal-pages

# ...or link into your existing Railway project that hosts the API:
railway link              # picks an existing service in your project

# Deploy!
railway up                 # builds the Dockerfile, streams logs, deploys
```

Railway prints the public URL when the deploy finishes, e.g.
`https://babymon-legal-pages-production-a1b2.up.railway.app`. Verify with:

```bash
curl -I https://<your-url>/health     # 200 OK + JSON
curl -I https://<your-url>/privacy    # 200 + text/html
curl -I https://<your-url>/eula       # 200 + text/html
```

Then paste the `/privacy` URL into:

- **Google Play Console** → App content → Privacy policy URL
- **Apple App Store Connect** (later, $99/yr) → App information → Privacy Policy URL
- (later) your marketing site footer
- (later) the in-app "Legal" screen

## When the legal team edits the canonical source

The legal team edits the **canonical** versions in `apps/mobile/tool/`:

- `apps/mobile/tool/privacy_policy.html` ← legal team edits here
- `apps/mobile/tool/eula.html` ← legal team edits here

Those files keep the relative cross-links (`eula.html`, `privacy_policy.html`) so they read cleanly when you double-click them locally.

To push a legal update to production, from this directory:

```bash
npm run sync               # rewrites cross-links + writes privacy.html + eula.html here
git add privacy.html eula.html
git commit -m "legal: update privacy + eula"
git push                    # Railway auto-deploys within ~30 seconds
```

That's it. The founder never edits `privacy.html` or `eula.html` directly — only the canonical sources.

## Verification before high-stakes deadlines

```bash
npm test                    # boots server, hits every route, asserts body + content-type
```

The smoke test uses Node's built-in `node:test` runner. No test framework to install.

## Cost

- **Service**: $0/mo at low traffic on Railway's $5/mo free credit. A 256MB Node service with light traffic uses ~$0.50–$1.50/mo. ✓
- **Domain DNS**: $0 (we're using the free `*.up.railway.app` URL).
- **Total monthly cost**: **$0**.

If you later want `https://babymon.app/privacy` instead of `https://babymon-legal-pages-production.up.railway.app/privacy`, that's a separate task: buy `babymon.app` (~$12/yr at Porkbun / Namecheap / Cloudflare Registrar) and add a CNAME record in your registrar's DNS.

## Why not on the existing API?

The privacy-policy URL goes into:
- Google Play Console (URL stability tested at annual review)
- Apple App Store Connect (same)
- The in-app "Legal" link
- Email footers

Coupling it to the API's uptime means **any API outage also makes the legal docs unreachable**, which is bad because:
1. Google Play's crawlers check the URL — a 5xx will get you a takedown notice.
2. Parents trying to read what they signed need the doc when the app is *gone* (e.g., they think their data was leaked).
3. Legal teams need a stable, independent URL.

A standalone service on Railway's edge gives independent restarts, independent deploys, and minimal shared risk surface. Plus the cost is essentially zero.

## Operational commands (for later)

After `railway link` once in this directory:

```bash
railway logs               # stream container logs
railway restart            # restart the service (e.g. after Railway platform issues)
railway open               # open the Railway dashboard for this service
railway variables          # list/set environment variables
```
