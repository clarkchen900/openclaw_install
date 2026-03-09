#!/bin/bash
set -e

# ============================================================
# OpenClaw Installation Script for macOS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  OpenClaw Installer for macOS${NC}"
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

# Check if running on macOS
check_os() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    print_success "Running on macOS $(sw_vers -productVersion)"
}

# Check for Homebrew
check_homebrew() {
    print_step "Checking for Homebrew..."
    if command -v brew &> /dev/null; then
        print_success "Homebrew is installed"
    else
        print_warning "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_success "Homebrew installed"
    fi
}

# Install Node.js
install_node() {
    print_step "Checking Node.js..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js is already installed: $NODE_VERSION"
    else
        print_warning "Node.js not found. Installing..."
        brew install node
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
    echo "  2. QQ (via OneBot/NapCat)"
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
            npm install -g @larksuiteoapi/feishu-openclaw-plugin @kirigaya/openclaw-onebot @canghe/openclaw-wechat 2>/dev/null || true
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
    check_homebrew
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