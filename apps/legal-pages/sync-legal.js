#!/usr/bin/env node
'use strict';

/**
 * apps/legal-pages/sync-legal.js
 *
 * Re-derives the production copies of the legal HTML files in THIS directory
 * from the canonical sources at apps/mobile/tool/. Rewrites relative cross-links
 * (privacy_policy.html / eula.html) into absolute URLs (/privacy, /eula)
 * so the documents stay internally consistent when served from any host.
 *
 * Usage:
 *   $ npm run sync                  # from this directory
 *   $ node sync-legal.js            # ditto
 *   $ node apps/legal-pages/sync-legal.js   # from repo root
 *
 * Exit codes:
 *   0 - all files synced (or already up to date)
 *   1 - canonical source missing (unrecoverable without the legal team's edits)
 */

const fs = require('node:fs');
const path = require('node:path');

const SCRIPT_DIR = __dirname;
const REPO_ROOT = path.resolve(SCRIPT_DIR, '..', '..');
const CANONICAL_DIR = path.join(REPO_ROOT, 'apps', 'mobile', 'tool');

// (source-filename, dest-filename, regex-pattern, replacement-string) tuples.
const TRANSFORMS = [
  // Privacy source: rewrite `eula.html` and `eula.html#anchor` -> /eula / /eula#anchor
  {
    src: path.join(CANONICAL_DIR, 'privacy_policy.html'),
    dst: path.join(SCRIPT_DIR,   'privacy.html'),
    rules: [
      [/href="eula\.html(#[^"]*)?"/g, 'href="/eula$1"'],
    ],
  },
  // EULA source: rewrite `privacy_policy.html` -> /privacy
  {
    src: path.join(CANONICAL_DIR, 'eula.html'),
    dst: path.join(SCRIPT_DIR,   'eula.html'),
    rules: [
      [/href="privacy_policy\.html(#[^"]*)?"/g, 'href="/privacy$1"'],
    ],
  },
];

let updated = 0;
let skipped = 0;

for (const { src, dst, rules } of TRANSFORMS) {
  if (!fs.existsSync(src)) {
    console.error(`FATAL: canonical source not found: ${src}`);
    console.error(`       (the legal team edits apps/mobile/tool/*, not this directory.)`);
    process.exit(1);
  }

  const original = fs.readFileSync(src, 'utf8');
  let derived = original;
  for (const [pattern, replacement] of rules) {
    derived = derived.replace(pattern, replacement);
  }

  if (derived === original && fs.existsSync(dst) && fs.readFileSync(dst, 'utf8') === original) {
    skipped++;
    console.log(`sync: up to date   ${path.relative(REPO_ROOT, dst)}`);
    continue;
  }

  fs.writeFileSync(dst, derived, 'utf8');
  updated++;
  const sizeDelta = derived.length - original.length;
  const sign = sizeDelta >= 0 ? '+' : '';
  console.log(`sync: wrote        ${path.relative(REPO_ROOT, dst)}  (${sign}${sizeDelta} bytes after rewrite)`);
}

console.log(`\nsync complete.  ${updated} file(s) written, ${skipped} file(s) up to date.`);
console.log(`Next: 'git add apps/legal-pages/privacy.html apps/legal-pages/eula.html && git commit'.`);
process.exit(0);
