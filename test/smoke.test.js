// =====================================================================
// Smoke test — verifies the app structure and exits non-zero on failure
// =====================================================================
const assert = require('assert');
const fs = require('fs');
const path = require('path');

console.log('Running smoke tests...');

// Test 1 — package.json loads and has required fields
const pkg = require('../package.json');
assert.ok(pkg.name, 'package.json must have a name');
console.log('  PASS: package.json has name "' + pkg.name + '"');

// Test 2 — main entry file exists
const mainFile = pkg.main || 'app.js';
assert.ok(
  fs.existsSync(path.join(__dirname, '..', mainFile)),
  'Main entry file must exist: ' + mainFile
);
console.log('  PASS: main entry file exists (' + mainFile + ')');

// Test 3 — Node version is 16 or above
const major = parseInt(process.versions.node.split('.')[0], 10);
assert.ok(major >= 16, 'Node version must be >= 16, got ' + major);
console.log('  PASS: Node version ' + process.versions.node);

console.log('All tests passed.');
process.exit(0);
