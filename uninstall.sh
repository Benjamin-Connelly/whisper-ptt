#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
VENV_DIR="${HOME}/.local/share/whisper-ptt/venv"
SERVICE_DIR="${HOME}/.config/systemd/user"

echo "==> Stopping and disabling service..."
systemctl --user stop whisper-ptt.service 2>/dev/null || true
systemctl --user disable whisper-ptt.service 2>/dev/null || true

echo "==> Removing files..."
rm -f "${SERVICE_DIR}/whisper-ptt.service"
rm -f "${BIN_DIR}/whisper-ptt"

echo "==> Removing virtual environment..."
rm -rf "${VENV_DIR}"
rmdir "${HOME}/.local/share/whisper-ptt" 2>/dev/null || true

systemctl --user daemon-reload

echo "Done. whisper-ptt has been removed."
