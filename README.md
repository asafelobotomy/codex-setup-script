# codex-setup-script
Shell script intended for Codex "Setup script" field. It cleans the npm
environment, installs dependencies, and performs basic diagnostics for a
reliable Node.js workspace.

## Usage

Copy the contents of `setup-env.sh` into the Setup script configuration
in Codex.

The script:

- verifies that Node.js and npm are installed
- removes npm-specific and global proxy settings
- updates npm, refreshes the shell, and cleans the cache
- installs dependencies with `npm ci` when a lock file is present, or `npm install` otherwise
- deduplicates packages and checks for duplicates if `npm-duplicate-checker` is available
- runs `npm doctor` for final diagnostics
