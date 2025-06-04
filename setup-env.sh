#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "🧹 Cleaning npm environment..."

# 1. Clear proxy config
unset npm_config_http_proxy
unset npm_config_https_proxy

# 2. Remove proxy settings from .npmrc if it exists
[ -f ~/.npmrc ] && sed -i '/proxy/d' ~/.npmrc

# 3. Show current versions
echo "🔢 Node version: $(node -v)"
echo "🔢 NPM version: $(npm -v)"

# 4. Update npm
npm install -g npm@latest

# 5. Clean cache
npm cache clean --force

# 6. Show .npmrc (if exists)
[ -f ~/.npmrc ] && echo "📄 .npmrc:" && cat ~/.npmrc

# 7. Audit outdated packages
npm outdated --all || echo "✅ No outdated packages"

# 8. Reinstall project deps
rm -rf node_modules
[ -f package-lock.json ] && npm ci || npm install

# 9. Optional: duplicate check
if npx --yes npm-duplicate-checker >/dev/null 2>&1; then
  echo "🔍 Checking for duplicate packages..."
  npx npm-duplicate-checker
else
  echo "⚠️ Duplicate checker not installed — skipping."
fi

# 10. Safe npm doctor run
echo "🩺 Running npm doctor..."
set +e
npm doctor || echo "⚠️ npm doctor reported issues — see above."
set -e

echo "✅ Setup complete."
