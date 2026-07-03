'use strict';

/**
 * BabyMon legal-pages service.
 *
 * Routes:
 *   GET /         -> 301 redirect to /privacy (so the bare domain lands somewhere useful)
 *   GET /privacy  -> privacy.html (5-minute cache, version-stamped in HTML)
 *   GET /eula     -> eula.html (5-minute cache)
 *   GET /health   -> JSON {status:'ok'} for Railway healthcheck + uptime monitors
 *
 * Static fixtures (HTML files) live in this directory and are kept in sync with
 * the canonical sources at apps/mobile/tool/privacy_policy.html + eula.html via
 * `npm run sync` (see sync-legal.js + README.md).
 */

const express = require('express');
const path = require('path');

const PORT = Number(process.env.PORT) || 3000;
const HERE = __dirname;
const CACHE_HEADER = 'public, max-age=300, must-revalidate';

const app = express();

// Disable the auto-generated X-Powered-By header (small security polish).
app.disable('x-powered-by');

// Baseline security headers — applied to every response. Zero-dep.
// Defense-in-depth against click-jacking, MIME sniffing, and over-eager
// Referer leakage that could surface the user came from a sensitive URL.
app.use((_req, res, next) => {
  res.set('X-Content-Type-Options', 'nosniff');
  res.set('X-Frame-Options', 'DENY');
  res.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  next();
});

// --- Routes ---------------------------------------------------------------

function sendLegalFile(filename, fallbackEmail, cacheHeader = CACHE_HEADER) {
  return (_req, res) => {
    res.set('Content-Type', 'text/html; charset=utf-8');
    res.set('Cache-Control', cacheHeader);
    res.sendFile(path.join(HERE, filename), (err) => {
      if (err && !res.headersSent) {
        // Don't leak the file path; just log a single diagnostic line and
        // return a generic public message that still tells the user where to
        // get human help (so the legal doc link never goes dark silently).
        console.error(`[legal-pages] sendFile(${filename}) failed: ${err.code || err.message}`);
        res.status(500).type('text/plain; charset=utf-8').send(
          'This legal document is temporarily unavailable. ' +
          'Please email ' + fallbackEmail + ' for assistance.'
        );
      }
    });
  };
}

app.get('/privacy', sendLegalFile('privacy.html', 'privacy@babymon.app'));
app.get('/eula',    sendLegalFile('eula.html',    'legal@babymon.app'));
app.get('/',        (_req, res) => res.redirect(301, '/privacy'));

app.get('/health', (_req, res) => {
  res.set('Cache-Control', 'no-store');
  res.json({ status: 'ok', service: 'babymon-legal-pages', uptime_s: Math.round(process.uptime()) });
});

// Return 404 in plain text (not HTML) so security scanners see this is intentional.
app.use((_req, res) => {
  res.status(404).type('text/plain; charset=utf-8').send('Not found.');
});

// --- Boot -----------------------------------------------------------------

const server = app.listen(PORT, '0.0.0.0', () => {
  // BOOT line is parseable by `node --test` smoke tests. Keep this format stable.
  console.log(`[legal-pages] BOOT port=${PORT} address=0.0.0.0`);
  console.log(`[legal-pages]   -> http://localhost:${PORT}/privacy`);
  console.log(`[legal-pages]   -> http://localhost:${PORT}/eula`);
  console.log(`[legal-pages]   -> http://localhost:${PORT}/health`);
});

// Graceful shutdown so Railway restarts don't cut active connections.
function shutdown(signal) {
  console.log(`[legal-pages] received ${signal}, closing server...`);
  server.close((err) => {
    if (err) { console.error('[legal-pages] error during shutdown:', err); process.exit(1); }
    process.exit(0);
  });
  // Hard cap on shutdown duration.
  setTimeout(() => process.exit(1), 10000).unref();
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT',  () => shutdown('SIGINT'));
