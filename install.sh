#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="${HOME}/.local/share/whisper-ptt/venv"
BIN_DIR="${HOME}/.local/bin"
SERVICE_DIR="${HOME}/.config/systemd/user"
PYTHON_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

echo "==> Checking system dependencies..."

missing=()
command -v python3  >/dev/null || missing+=(python3)
command -v ydotool  >/dev/null || missing+=(ydotool)
command -v wl-copy  >/dev/null || missing+=(wl-clipboard)
pkg-config --exists libportaudio2 2>/dev/null || \
  dpkg -s libportaudio2 &>/dev/null  || missing+=(libportaudio2)

if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing packages: ${missing[*]}"
    echo "Install them with:"
    echo "  sudo apt install ${missing[*]}"
    exit 1
fi

# Check input group membership
if ! groups | grep -qw input; then
    echo "WARNING: You are not in the 'input' group."
    echo "  Run: sudo usermod -aG input \$USER"
    echo "  Then log out and back in."
fi

echo "==> Creating virtual environment at ${VENV_DIR}..."
python3 -m venv "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"

echo "==> Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Install CUDA support if an NVIDIA GPU is present
if command -v nvidia-smi &>/dev/null; then
    echo "==> NVIDIA GPU detected, installing CUDA dependencies..."
    pip install nvidia-cublas-cu12 nvidia-cudnn-cu12
else
    echo "==> No NVIDIA GPU detected, will use CPU mode."
fi

deactivate

echo "==> Symlinking script to ${BIN_DIR}..."
mkdir -p "${BIN_DIR}"
ln -sf "${REPO_DIR}/whisper-ptt" "${BIN_DIR}/whisper-ptt"

echo "==> Installing systemd user service..."
mkdir -p "${SERVICE_DIR}"

# Generate service file with resolved paths
cat > "${SERVICE_DIR}/whisper-ptt.service" <<EOF
[Unit]
Description=Whisper Push-to-Talk (Right Ctrl)
After=graphical-session.target pipewire.service
Wants=pipewire.service

[Service]
Type=simple
Environment=PYTHONUNBUFFERED=1 WHISPER_LAZY_MIC=1
Environment=LD_LIBRARY_PATH=${VENV_DIR}/lib/python${PYTHON_VER}/site-packages/nvidia/cublas/lib:${VENV_DIR}/lib/python${PYTHON_VER}/site-packages/nvidia/cudnn/lib
ExecStart=${VENV_DIR}/bin/python3 ${REPO_DIR}/whisper-ptt
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical-session.target
EOF

systemctl --user daemon-reload
systemctl --user enable whisper-ptt.service

echo ""
echo "Done! Start it now with:"
echo "  systemctl --user start whisper-ptt"
echo ""
echo "Or reboot — it will start automatically at login."
echo ""
echo "Check logs with:"
echo "  journalctl --user -u whisper-ptt -f"
