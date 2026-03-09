#!/bin/bash
set -e

# ============================================================
# OpenClaw Installation Script for macOS & Linux
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  OpenClaw Installer (macOS/Linux)${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}[→]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                case "$ID" in
                    debian|ubuntu|linuxmint|pop)
                        echo "debian"
                        ;;
                    fedora|rhel|centos|rocky|alma)
                        echo "rhel"
                        ;;
                    arch|manjaro|endeavouros)
                        echo "arch"
                        ;;
                    *)
                        echo "linux"
                        ;;
                esac
            else
                echo "linux"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check for package manager
check_package_manager() {
    OS=$(detect_os)
    
    case "$OS" in
        macos)
            if command -v brew &> /dev/null; then
                print_success "Homebrew is installed"
                echo "brew"
            else
                print_warning "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                print_success "Homebrew installed"
                echo "brew"
            fi
            ;;
        debian)
            if command -v apt-get &> /dev/null; then
                print_success "apt-get available"
                echo "apt"
            else
                print_error "apt-get not found"
                exit 1
            fi
            ;;
        rhel)
            if command -v dnf &> /dev/null; then
                print_success "dnf available"
                echo "dnf"
            elif command -v yum &> /dev/null; then
                print_success "yum available"
                echo "yum"
            else
                print_error "No package manager found"
                exit 1
            fi
            ;;
        arch)
            if command -v pacman &> /dev/null; then
                print_success "pacman available"
                echo "pacman"
            else
                print_error "pacman not found"
                exit 1
            fi
            ;;
        *)
            print_error "Unsupported OS"
            exit 1
            ;;
    esac
}

# Check OS and show welcome
check_os() {
    OS=$(detect_os)
    case "$OS" in
        macos)
            print_success "Running on macOS $(sw_vers -productVersion)"
            ;;
        debian)
            . /etc/os-release
            print_success "Running on $NAME"
            ;;
        rhel)
            . /etc/os-release
            print_success "Running on $NAME"
            ;;
        arch)
            print_success "Running on Arch Linux"
            ;;
        *)
            print_warning "Unknown OS, trying to proceed anyway..."
            ;;
    esac
}

# Install Node.js
install_node() {
    print_step "Checking Node.js..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js is already installed: $NODE_VERSION"
    else
        print_warning "Node.js not found. Installing..."
        
        PKG_MGR=$(check_package_manager)
        
        case "$PKG_MGR" in
            brew)
                brew install node
                ;;
            apt)
                curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs
                ;;
            dnf|yum)
                curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && yum install -y nodejs
                ;;
            pacman)
                pacman -S --noconfirm nodejs npm
                ;;
        esac
        print_success "Node.js installed"
    fi

    print_step "Checking npm..."
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_success "npm is already installed: v$NPM_VERSION"
    else
        print_error "npm installation failed"
        exit 1
    fi
}

# Install OpenClaw
install_openclaw() {
    print_step "Installing OpenClaw..."
    
    # Check if already installed
    if command -v openclaw &> /dev/null; then
        print_warning "OpenClaw is already installed"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_success "Keeping existing installation"
            return
        fi
    fi

    # Install OpenClaw globally
    npm install -g openclaw
    
    if command -v openclaw &> /dev/null; then
        print_success "OpenClaw installed successfully"
        openclaw --version
    else
        print_error "OpenClaw installation failed"
        exit 1
    fi
}

# Configure OpenClaw
configure_openclaw() {
    print_step "Configuring OpenClaw..."
    
    # Create config directory
    mkdir -p ~/.openclaw
    
    print_success "Configuration directory created"
    
    # Initialize config with wizard
    echo ""
    print_warning "Now launching OpenClaw onboarding wizard..."
    echo ""
    
    # Run onboard command
    openclaw onboard
}

# Install channel plugins (optional)
install_plugins() {
    echo ""
    print_step "Installing optional plugins..."
    echo "  1. Feishu (飞书)"
    echo "  2. QQ"
    echo "  3. WeChat"
    echo "  4. All of above"
    echo "  5. Skip"
    echo ""
    
    read -p "Select plugins to install (1-5): " -n 1 -r
    echo
    
    case $REPLY in
        1) npm install -g @larksuiteoapi/feishu-openclaw-plugin ;;
        2) npm install -g @sliverp/qqbot ;;
        3) npm install -g @canghe/openclaw-wechat ;;
        4) 
            npm install -g @larksuiteoapi/feishu-openclaw-plugin @sliverp/qqbot @canghe/openclaw-wechat 2>/dev/null || true
            ;;
        5) print_warning "Skipping plugin installation" ;;
        *) print_warning "Invalid option, skipping" ;;
    esac
    
    print_success "Plugin installation complete"
}

# Start OpenClaw
start_openclaw() {
    echo ""
    print_step "Starting OpenClaw..."
    
    # Check for config
    if [[ -f ~/.openclaw/openclaw.json ]]; then
        openclaw gateway start
        print_success "OpenClaw gateway started"
        
        echo ""
        echo "========================================"
        echo -e "${GREEN}  Installation Complete!${NC}"
        echo "========================================"
        echo ""
        echo "OpenClaw is now running!"
        echo ""
        echo "Next steps:"
        echo "  • Open http://localhost:18789 in your browser"
        echo "  • Or use the TUI: openclaw tui"
        echo "  • Check status: openclaw status"
        echo ""
    else
        print_warning "Config not found. Please run: openclaw onboard"
    fi
}

# Main
main() {
    print_header
    
    check_os
    install_node
    install_openclaw
    install_plugins
    
    echo ""
    read -p "Start OpenClaw now? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_warning "OpenClaw not started. Run 'openclaw gateway start' when ready."
    else
        configure_openclaw
        start_openclaw
    fi
}

main "$@"