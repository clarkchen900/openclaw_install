# OpenClaw Installer for macOS & Linux

A simple one-click script to install OpenClaw on your system.

## Quick Install

```bash
curl -O https://raw.githubusercontent.com/clarkchen900/openclaw_install/main/install-openclaw-macos.sh
chmod +x install-openclaw-macos.sh
./install-openclaw-macos.sh
```

## Supported OS

- ✅ macOS
- ✅ Debian/Ubuntu (apt)
- ✅ Fedora/RHEL/CentOS (dnf/yum)
- ✅ Arch Linux (pacman)

## Features

- **Smart Detection**: Checks if Node.js, npm, and OpenClaw are already installed
- **Skip Existing**: If OpenClaw is already installed, prompts to install plugins only
- **Multi-OS Support**: Works on macOS and Linux (apt/dnf/yum/pacman)

## What It Does

1. Detects your OS
2. Checks if Node.js is installed (skip if yes)
3. Checks if npm is installed (skip if yes)
4. Checks if OpenClaw is installed:
   - **If YES**: Prompt to install plugins only, then start
   - **If NO**: Install OpenClaw, then prompt for plugins

## Supported Plugins

| Plugin | Package | Description |
|--------|---------|-------------|
| Feishu | @larksuiteoapi/feishu-openclaw-plugin | 飞书/ Lark |
| QQ | @sliverp/qqbot | QQ bot |
| WeChat | @canghe/openclaw-wechat | 微信 |

## Requirements

- macOS 10.15+ / Linux (see above)
- Internet connection

## After Install

- Open http://localhost:18789
- Or use TUI: `openclaw tui`
- Check status: `openclaw status`

## License

MIT
