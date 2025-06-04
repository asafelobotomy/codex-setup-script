# codex-setup-script
Shell script intended for Codex "Setup script" field. It cleans the npm
environment, installs dependencies, and performs basic diagnostics for a
reliable Node.js workspace.

## Usage

Copy the contents of `setup-env.sh` into the Setup script configuration
in Codex.

The script:

- verifies that Node.js and npm are installed
- removes proxy settings
- updates npm and cleans the cache
- installs dependencies with `npm ci` when a lock file is present
- deduplicates packages and optionally checks for duplicates
- runs `npm doctor` for final diagnostics
