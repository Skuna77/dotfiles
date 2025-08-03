#!/usr/bin/env bash

# Dotfiles Installer 2.0
# Installs dependencies, creates symlinks, and handles backups

set -euo pipefail

# ---- Variables ----
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d%H%M%S)"
PKGMGR=""  # Package manager auto-detected
OS=""
SKIP_CONFIRM=false
INSTALL_PKGS=true

# ---- Dependency Lists ----
ARCH_PKGS=(
    neovim
    sxhkd
    zathura zathura-pdf-mupdf
    git
    base-devel  # For suckless builds
    xorg-server xorg-xinit  # X11 for suckless
)

# ---- Functions ----
detect_system() {
    if command -v pacman &> /dev/null; then
        OS="arch"
        PKGMGR="sudo pacman -S --needed --noconfirm"
    elif command -v apt &> /dev/null; then
        OS="debian"
        PKGMGR="sudo apt install -y"
    else
        echo "❌ Unsupported OS! Manual installation required."
        exit 1
    fi
}

install_dependencies() {
    echo -e "\n🛠️  Installing dependencies ($OS)..."
    
    case $OS in
        arch)
            $PKGMGR "${ARCH_PKGS[@]}"
            ;;
        debian)
            # Would have debian packages here
            ;;
    esac
    
    # Additional language managers
    if ! command -v npm &> /dev/null; then
        echo "Installing Node.js..."
        curl -fsSL https://fnm.vercel.app/install | bash
    fi
}

build_suckless() {
    echo -e "\n🔨 Building suckless tools..."
    local tools=(dwm dmenu slock st)  # Add/remove as needed
    
    for tool in "${tools[@]}"; do
        if [ -d "$DOTFILES_DIR/suckless/$tool" ]; then
            echo "Building $tool..."
            cd "$DOTFILES_DIR/suckless/$tool"
            sudo make clean install
        fi
    done
    cd "$DOTFILES_DIR"
}

create_symlink() {
    # ... (same as previous version) ...
}

# ---- Main ----
# Parse flags
while getopts "yn" opt; do
    case $opt in
        y) SKIP_CONFIRM=true ;;
        n) INSTALL_PKGS=false ;;
        *) ;;
    esac
done

# System detection
detect_system

# Confirm action
if ! $SKIP_CONFIRM; then
    read -rp "Install dependencies and setup dotfiles? [y/N] " -n 1
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# Install dependencies
if $INSTALL_PKGS; then
    install_dependencies
else
    echo "⏩ Skipping dependency installation"
fi

# Build suckless tools
build_suckless

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create symlinks
create_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/sxhkd" "$HOME/.config/sxhkd"
create_symlink "$DOTFILES_DIR/zathura" "$HOME/.config/zathura"
create_symlink "$DOTFILES_DIR/scripts" "$HOME/.local/bin/scripts"

# Initialize Neovim (install plugins)
echo -e "\n🔌 Setting up Neovim..."
nvim --headless "+Lazy! sync" +qa

# Post-install
echo -e "\n✅ Setup complete!"
echo "Backups saved to: $BACKUP_DIR"
echo -e "\nLog out and back in for window manager changes"
