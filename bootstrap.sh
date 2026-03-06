#!/usr/bin/env bash
set -euo pipefail

# ── Terminal Environment Bootstrap ────────────────────────────────
# Sets up zsh + tmux + neovim on macOS or Linux (Debian/Ubuntu/Arch).
# Run from a standard bash shell:
#   git clone <your-dotfiles-repo> ~/dotfiles
#   cd ~/dotfiles && bash bootstrap.sh

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$1"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$1"; }
ok()    { printf '\033[1;32m[ok]\033[0m    %s\n' "$1"; }
fail()  { printf '\033[1;31m[fail]\033[0m  %s\n' "$1"; exit 1; }

# ── Detect platform ──────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM=macos ;;
  Linux)  PLATFORM=linux ;;
  *)      fail "Unsupported OS: $OS" ;;
esac
info "Platform: $PLATFORM"

# ── Detect Linux distro family ───────────────────────────────────
if [[ "$PLATFORM" == linux ]]; then
  if command -v apt-get >/dev/null 2>&1; then
    DISTRO=debian
  elif command -v pacman >/dev/null 2>&1; then
    DISTRO=arch
  elif command -v dnf >/dev/null 2>&1; then
    DISTRO=fedora
  else
    warn "Unknown Linux distro. You may need to install packages manually."
    DISTRO=unknown
  fi
  info "Distro family: $DISTRO"
fi

# ── Install packages ─────────────────────────────────────────────
install_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to current session PATH
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi

  info "Installing packages via Homebrew..."
  brew install \
    zsh neovim tmux fzf ripgrep git \
    starship zoxide eza gitmux \
    zsh-autosuggestions zsh-syntax-highlighting \
    zsh-history-substring-search zsh-vi-mode
}

install_linux_debian() {
  info "Installing packages via apt..."
  sudo apt-get update -qq
  sudo apt-get install -y \
    zsh tmux fzf ripgrep git curl xclip

  # Packages not in apt — install via cargo/go/binary
  install_linux_extras
}

install_linux_arch() {
  info "Installing packages via pacman..."
  sudo pacman -Syu --noconfirm --needed \
    zsh tmux fzf ripgrep git xclip \
    zsh-autosuggestions zsh-syntax-highlighting \
    zsh-history-substring-search

  # AUR or manual installs
  if command -v yay >/dev/null 2>&1; then
    yay -S --noconfirm --needed zsh-vi-mode starship zoxide eza gitmux-bin
  else
    warn "yay not found. Installing remaining tools via cargo/binary..."
    install_linux_extras
  fi
}

install_linux_fedora() {
  info "Installing packages via dnf..."
  sudo dnf install -y \
    zsh tmux fzf ripgrep git xclip

  install_linux_extras
}

install_linux_extras() {
  # neovim (latest stable via appimage or tarball)
  if ! command -v nvim >/dev/null 2>&1; then
    info "Installing neovim..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo tar -xzf nvim-linux-x86_64.tar.gz -C /opt
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm -f nvim-linux-x86_64.tar.gz
  fi

  # starship
  if ! command -v starship >/dev/null 2>&1; then
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # zoxide
  if ! command -v zoxide >/dev/null 2>&1; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi

  # eza
  if ! command -v eza >/dev/null 2>&1; then
    info "Installing eza..."
    if command -v cargo >/dev/null 2>&1; then
      cargo install eza
    else
      warn "cargo not found — install Rust first for eza, or install eza manually"
    fi
  fi

  # gitmux
  if ! command -v gitmux >/dev/null 2>&1; then
    info "Installing gitmux..."
    if command -v go >/dev/null 2>&1; then
      go install github.com/arl/gitmux@latest
    else
      warn "go not found — install Go first for gitmux, or install gitmux manually"
    fi
  fi

  # zsh plugins (if not installed via package manager)
  local zsh_plugin_dir="/usr/share"
  if [[ ! -f "$zsh_plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
     [[ ! -f "$zsh_plugin_dir/zsh-autosuggestions.zsh" ]]; then
    info "Installing zsh plugins to ~/.local/share/zsh/plugins..."
    local target="$HOME/.local/share/zsh/plugins"
    mkdir -p "$target"
    [[ -d "$target/zsh-autosuggestions" ]]          || git clone https://github.com/zsh-users/zsh-autosuggestions "$target/zsh-autosuggestions"
    [[ -d "$target/zsh-syntax-highlighting" ]]      || git clone https://github.com/zsh-users/zsh-syntax-highlighting "$target/zsh-syntax-highlighting"
    [[ -d "$target/zsh-history-substring-search" ]] || git clone https://github.com/zsh-users/zsh-history-substring-search "$target/zsh-history-substring-search"
    [[ -d "$target/zsh-vi-mode" ]]                  || git clone https://github.com/jeffreytse/zsh-vi-mode "$target/zsh-vi-mode"
  fi
}

# ── Run platform installer ───────────────────────────────────────
case "$PLATFORM" in
  macos) install_macos ;;
  linux)
    case "$DISTRO" in
      debian)  install_linux_debian ;;
      arch)    install_linux_arch ;;
      fedora)  install_linux_fedora ;;
      unknown) warn "Skipping package install — install dependencies manually." ;;
    esac
    ;;
esac

# ── Symlink dotfiles ─────────────────────────────────────────────
link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "Backing up existing $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  ok "Linked $dst"
}

info "Symlinking dotfiles..."
link "$DOTFILES_DIR/zshrc"               "$HOME/.zshrc"
link "$DOTFILES_DIR/zshenv"              "$HOME/.zshenv"
link "$DOTFILES_DIR/tmux.conf"           "$HOME/.tmux.conf"
link "$DOTFILES_DIR/gitmux.conf"         "$HOME/.gitmux.conf"

mkdir -p "$HOME/.config"
link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

mkdir -p "$HOME/.config/nvim"
link "$DOTFILES_DIR/nvim/init.lua"        "$HOME/.config/nvim/init.lua"

# ── Clear zsh caches (will regenerate on first shell start) ──────
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# ── Bootstrap TPM ────────────────────────────────────────────────
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing tmux plugin manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# ── Set default shell to zsh ─────────────────────────────────────
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  info "Changing default shell to zsh..."
  if ! grep -qF "$ZSH_PATH" /etc/shells 2>/dev/null; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$ZSH_PATH"
fi

# ── Done ──────────────────────────────────────────────────────────
echo ""
ok "Bootstrap complete!"
info "Next steps:"
info "  1. Restart your shell:  exec zsh"
info "  2. In tmux, press prefix + I to install tmux plugins"
info "  3. Open nvim — plugins will auto-install on first launch"
