# whisper-ptt

Local push-to-talk speech-to-text for Linux/Wayland. Hold **Right Ctrl** to record, release to transcribe and type. Nothing leaves your machine.

Uses [faster-whisper](https://github.com/SYSTRAN/faster-whisper) for transcription with automatic CUDA GPU acceleration (falls back to CPU).

## How it works

1. Microphone stays open continuously for instant capture (or on-demand with `WHISPER_LAZY_MIC=1`)
2. A 2-second pre-buffer captures words spoken before the key press (persistent mic mode only)
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

The installer creates a Python venv at `~/.local/share/whisper-ptt/venv`, installs scripts to `~/.local/bin/`, and enables a systemd user service that starts at login.

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

WHISPER_LAZY_MIC=1            # only open mic during recording (frees Bluetooth)
WHISPER_DEVICE=               # input device name or index (blank = system default)
```

### Bluetooth headset sharing

If your Bluetooth headset is paired to multiple devices, the default persistent mic mode
claims the HFP/HSP profile and prevents the headset from accepting calls on other devices.
Two options:

- **`WHISPER_LAZY_MIC=1`** — mic is only opened while recording. The headset is free
  between dictation presses. Loses the 2-second pre-buffer.
- **`WHISPER_DEVICE=<name>`** — pin whisper-ptt to a specific input (e.g., your laptop's
  built-in mic). The Bluetooth mic is never claimed. Use `python3 -m sounddevice` to list
  available devices.

## Uninstall

```bash
./uninstall.sh
```

## License

MIT
