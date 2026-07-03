'use strict';

/**
 * apps/legal-pages/test/smoke.test.js
 *
 * Boot the server on a kernel-assigned ephemeral port (PORT=0), read the
 * actual bound port back out of the parseable BOOT log line, then hit every
 * route. Uses node:test (built-in, zero-dep test runner).
 *
 * Run with: npm test
 */

const test = require('node:test');
const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');
const path = require('node:path');

const SERVER_ENTRY = path.join(__dirname, '..', 'index.js');

function waitForBoot(child) {
  return new Promise((resolve, reject) => {
    let boundPort = null;
    let resolved = false;
    const onData = (chunk) => {
      const line = chunk.toString();
      // "[legal-pages] BOOT port=NNNN" — value of port IS the readiness signal.
      // Stable contract: this log format is the boot handshake with the test.
      const m = line.match(/\[legal-pages\] BOOT port=(\d+)/);
      if (m) boundPort = Number(m[1]);
      if (!resolved && boundPort !== null) {
        resolved = true;
        child.stdout.off('data', onData);
        child.stderr.off('data', onData);
        resolve(boundPort);
      }
    };
    child.stdout.on('data', onData);
    child.stderr.on('data', onData);
    child.once('exit', (code) => reject(new Error('server exited early (code=' + code + ')')));
    setTimeout(() => reject(new Error('boot timeout')), 8000);
  });
}

async function get(url) {
  const res = await fetch(url);
  const text = await res.text();
  return {
    status: res.status,
    contentType: res.headers.get('content-type') || '',
    text,
    headers: res.headers,
  };
}

test('boot: server starts and serves all legal routes', async (t) => {
  // PORT=0 => kernel picks an unused ephemeral port; avoids CI port collisions.
  const child = spawn(process.execPath, [SERVER_ENTRY], {
    env: { ...process.env, PORT: '0', NODE_ENV: 'test' },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  t.after(() => { try { child.kill('SIGTERM'); } catch {} });

  const port = await waitForBoot(child);
  assert.ok(port > 0 && port < 65536, `bound port must be valid, got ${port}`);
  const baseUrl = `http://127.0.0.1:${port}`;

  await t.test('GET /health returns JSON {status:"ok"}', async () => {
    const r = await get(baseUrl + '/health');
    assert.equal(r.status, 200);
    assert.match(r.contentType, /application\/json/);
    const body = JSON.parse(r.text);
    assert.equal(body.status, 'ok');
    assert.equal(body.service, 'babymon-legal-pages');
    assert.equal(typeof body.uptime_s, 'number');
  });

  await t.test('GET /privacy returns the privacy policy HTML with security headers', async () => {
    const r = await get(baseUrl + '/privacy');
    assert.equal(r.status, 200);
    assert.match(r.contentType, /text\/html/);
    assert.match(r.text, /Privacy Policy/i);
    assert.match(r.text, /BabyMon/);
    // Cross-link to EULA was rewritten by sync-legal.js to absolute /eula
    assert.match(r.text, /href="\/eula(\#[^"]*)?"/);
    // Defense-in-depth security headers
    assert.equal(r.headers.get('x-content-type-options'), 'nosniff');
    assert.equal(r.headers.get('x-frame-options'), 'DENY');
    assert.equal(r.headers.get('referrer-policy'), 'strict-origin-when-cross-origin');
    XPoweredByAbsent(r);
  });

  await t.test('GET /eula returns the EULA HTML with absolute /privacy cross-link', async () => {
    const r = await get(baseUrl + '/eula');
    assert.equal(r.status, 200);
    assert.match(r.contentType, /text\/html/);
    assert.match(r.text, /License Agreement/i);
    assert.match(r.text, /BabyMon/);
    assert.match(r.text, /href="\/privacy(\#[^"]*)?"/);
    XPoweredByAbsent(r);
  });

  await t.test('GET / redirects 301 to /privacy', async () => {
    const res = await fetch(baseUrl + '/', { redirect: 'manual' });
    assert.equal(res.status, 301);
    assert.equal(res.headers.get('location'), '/privacy');
  });

  await t.test('GET /unknown returns 404 plain text (no Express HTML page disclosure)', async () => {
    const r = await get(baseUrl + '/no-such-page');
    assert.equal(r.status, 404);
    assert.match(r.contentType, /text\/plain/);
    XPoweredByAbsent(r);
  });
});

function XPoweredByAbsent(r) {
  assert.equal(r.headers.get('x-powered-by'), null, 'X-Powered-By header must be suppressed');
}
