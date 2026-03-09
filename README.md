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

## What It Does

1. Detects your OS
2. Installs package manager if needed (Homebrew on macOS)
3. Installs Node.js & npm
4. Installs OpenClaw globally
5. Optional plugins: Feishu, QQ, WeChat
6. Launches onboarding wizard
7. Starts OpenClaw gateway

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
