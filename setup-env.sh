#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Configurable behavior
# Set SKIP_DEDUPE=true to skip npm deduplication
# Set SKIP_NPM_DOCTOR=true to skip `npm doctor`
: "${SKIP_DEDUPE:=false}"
: "${SKIP_NPM_DOCTOR:=false}"

# Ensure Node and npm are available
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not installed."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm not installed."; exit 1; }
echo "📍 Node path: $(command -v node)"
echo "📍 npm path: $(command -v npm)"

# Reduce npm noise during setup
export npm_config_progress=false
export npm_config_fund=false
export npm_config_audit=false

echo "🧹 Cleaning npm environment..."

# 1. Clear proxy config
unset npm_config_http_proxy
unset npm_config_https_proxy
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

# 2. Remove proxy settings from .npmrc if it exists
if [ -f ~/.npmrc ]; then
  sed -i \
    -e '/^\s*proxy=/d' \
    -e '/^\s*https-proxy=/d' \
    -e '/^\s*http-proxy=/d' \
    ~/.npmrc
fi

# 3. Show current versions
echo "🔢 Node version: $(node -v)"
echo "🔢 NPM version: $(npm -v)"
echo "🌐 Registry: $(npm config get registry)"

# 4. Update npm
npm install -g npm@latest --no-progress
hash -r

# 5. Clean cache
npm cache clean --force
npm cache verify >/dev/null

# 6. Show .npmrc (if exists)
[ -f ~/.npmrc ] && echo "📄 .npmrc:" && cat ~/.npmrc

# 7. Audit outdated packages
npm outdated --all || echo "✅ No outdated packages"

# 8. Reinstall project deps if package.json exists
if [ -f package.json ]; then
  rm -rf node_modules
  npm_flags=(--no-audit --no-fund --prefer-offline --ignore-scripts)
  if [ -f package-lock.json ]; then
    npm ci "${npm_flags[@]}"
  else
    npm install "${npm_flags[@]}"
  fi

  # Dedupe packages to reduce duplicates
  if [ "$SKIP_DEDUPE" != "true" ]; then
    npm dedupe
  fi
else
  echo "⚠️ No package.json found. Skipping dependency installation."
fi

# 9. Optional: duplicate check
if npx --no-install npm-duplicate-checker >/dev/null 2>&1; then
  echo "🔍 Checking for duplicate packages..."
  npx --no-install npm-duplicate-checker
else
  echo "⚠️ npm-duplicate-checker not installed — skipping."
fi

# 10. Safe npm doctor run
if [ "$SKIP_NPM_DOCTOR" != "true" ]; then
  echo "🩺 Running npm doctor..."
  set +e
  npm doctor || echo "⚠️ npm doctor reported issues — see above."
  set -e
fi

echo "✅ Setup complete."
