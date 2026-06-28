#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$HOME/.ctf-solver"
CREDS_FILE="$DATA_DIR/.password"

mkdir -p "$DATA_DIR/challenges" "$DATA_DIR/state" "$DATA_DIR/all-skills"

if [ ! -f "$CREDS_FILE" ]; then
  python3 -c "import secrets; print(secrets.token_urlsafe(32))" > "$CREDS_FILE"
  chmod 600 "$CREDS_FILE"
fi

export APP_ROOT_DIR="$DATA_DIR"
export APP_PASSWORD
APP_PASSWORD="$(cat "$CREDS_FILE")"
export SESSION_SECRET
SESSION_SECRET="$(python3 -c "import secrets; print(secrets.token_hex(32))")"
export PORT="${PORT:-8080}"

echo ""
echo "============================================"
echo "  CTF Solver Web App (local)"
echo "============================================"
echo "  URL:      http://localhost:$PORT"
echo "  Password: $APP_PASSWORD"
echo "============================================"
echo ""

pkill -f "claude.*--input-format stream-json" 2>/dev/null || true
pkill -f "codex app-server" 2>/dev/null || true

PYTHON="$HOME/.ctf-solver/venv/bin/python"
if [ ! -x "$PYTHON" ]; then
  echo "venv not found — run: uv venv ~/.ctf-solver/venv && uv pip install --python ~/.ctf-solver/venv/bin/python starlette uvicorn python-multipart itsdangerous websockets httpx requests"
  exit 1
fi
exec "$PYTHON" "$SCRIPT_DIR/webapp/app.py"
