# whisper-ptt

Local push-to-talk speech-to-text for Linux/Wayland. Hold **Right Ctrl** to record, release to transcribe and type. Nothing leaves your machine.

Uses [faster-whisper](https://github.com/SYSTRAN/faster-whisper) for transcription with automatic CUDA GPU acceleration (falls back to CPU).

## How it works

1. Microphone is only opened during recording to avoid claiming Bluetooth profiles
2. Set `WHISPER_LAZY_MIC=0` for persistent mic with a 2-second pre-buffer (captures speech before key press)
3. On release, audio is sent through Whisper with VAD filtering
4. Transcribed text is copied to clipboard (`wl-copy`) and typed (`ydotool`)

Typical latency is ~1s on a modern NVIDIA GPU.

## Requirements

- Linux with Wayland (GNOME, Sway, etc.)
- Python 3.10+
- PipeWire or PulseAudio
- System packages: `ydotool`, `wl-clipboard`, `libportaudio2`
- User must be in the `input` group (for keyboard access)
- Optional: NVIDIA GPU with CUDA for fast inference

## Install

```bash
# System dependencies (Debian/Ubuntu)
sudo apt install ydotool wl-clipboard libportaudio2

# Input group access (log out and back in after this)
sudo usermod -aG input $USER

# Clone and install
git clone https://github.com/Benjamin-Connelly/whisper-ptt.git
cd whisper-ptt
./install.sh
```

The installer creates a Python venv at `~/.local/share/whisper-ptt/venv`, symlinks the script to `~/.local/bin/`, and enables a systemd user service that starts at login. The symlink means `git pull` updates the running version — just restart the service.

## Usage

```bash
# Start now
systemctl --user start whisper-ptt

# Check status
systemctl --user status whisper-ptt

# View logs
journalctl --user -u whisper-ptt -f

# Stop
systemctl --user stop whisper-ptt
```

Hold **Right Ctrl** anywhere on your desktop to dictate. Text appears at the cursor.

## Configuration

Environment variables (set in `~/.config/environment.d/whisper.conf` or similar):

```bash
WHISPER_MODEL=small.en        # faster, less accurate
WHISPER_MODEL=medium.en       # default — good balance
WHISPER_MODEL=large-v3        # slower, most accurate

WHISPER_LANGUAGE=en           # default — English
WHISPER_LANGUAGE=fr           # French, etc.

WHISPER_KEY=KEY_RIGHTCTRL     # default — see evdev ecodes for key names
WHISPER_KEY=KEY_RIGHTALT      # example: use Right Alt instead

WHISPER_LAZY_MIC=1            # default — only open mic during recording
WHISPER_LAZY_MIC=0            # persistent mic with 2-second pre-buffer

WHISPER_DEVICE=               # input device name or index (blank = system default)
```

### Audio device selection

Pin whisper-ptt to a specific input device (e.g., your laptop's built-in mic) with
`WHISPER_DEVICE`. Accepts a device name (substring match) or numeric index.
Use `python3 -m sounddevice` to list available devices.

## Uninstall

```bash
./uninstall.sh
```

## License

MIT
