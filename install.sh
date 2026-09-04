#!/usr/bin/env bash
# Dotfiles installer — macOS (MacBook) or Omarchy (Arch/Hyprland).
#
#   ./install.sh            # interactive menu
#   ./install.sh mac        # non-interactive
#   ./install.sh omarchy

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '\033[34m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[32m ✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m !!\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------- platform ----

PLATFORM="${1:-}"
if [[ -z "$PLATFORM" ]]; then
  bold "Where are you setting up?"
  echo "  1) MacBook (macOS)"
  echo "  2) Omarchy (Arch / Hyprland)"
  read -rp "> " choice
  case "$choice" in
    1) PLATFORM=mac ;;
    2) PLATFORM=omarchy ;;
    *) warn "unknown choice"; exit 1 ;;
  esac
fi

case "$PLATFORM" in
  mac|macos)      PLATFORM=mac ;;
  omarchy|arch)   PLATFORM=omarchy ;;
  *) warn "usage: ./install.sh [mac|omarchy]"; exit 1 ;;
esac
info "Platform: $PLATFORM"

# ------------------------------------------------------------- pkg helpers ----

pkg_install() { # pkg_install <cli-to-check> <mac-cask-or-formula> <arch-pkg> [--cask]
  local check="$1" mac_pkg="$2" arch_pkg="$3" cask="${4:-}"
  if command -v "$check" >/dev/null 2>&1; then
    ok "$check already installed"
    return
  fi
  if [[ "$PLATFORM" == mac ]]; then
    if [[ "$cask" == "--cask" ]]; then
      brew list --cask "$mac_pkg" >/dev/null 2>&1 && { ok "$mac_pkg already installed"; return; }
      info "installing $mac_pkg"
      brew install --cask "$mac_pkg"
    else
      brew list "$mac_pkg" >/dev/null 2>&1 && { ok "$mac_pkg already installed"; return; }
      info "installing $mac_pkg"
      brew install "$mac_pkg"
    fi
  else
    info "installing $check"
    if pacman -Si "$arch_pkg" >/dev/null 2>&1; then
      sudo pacman -S --needed --noconfirm "$arch_pkg"
    else
      yay -S --needed --noconfirm "$arch_pkg"
    fi
  fi
}

if [[ "$PLATFORM" == mac ]] && ! command -v brew >/dev/null 2>&1; then
  info "installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --------------------------------------------------------------- linking -----

link() { # link <src> <dest>
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" ]]; then
    [[ "$(readlink "$dest")" == "$src" ]] && { ok "$dest"; return; }
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mv "$dest" "$dest.bak-$STAMP"
    warn "backed up existing $dest -> $dest.bak-$STAMP"
  fi
  ln -s "$src" "$dest"
  ok "$dest -> $src"
}

VSCODE_USER="$HOME/.config/Code/User"
[[ "$PLATFORM" == mac ]] && VSCODE_USER="$HOME/Library/Application Support/Code/User"

# --------------------------------------------------------------- fonts ------
# macOS ships SF Mono; only Omarchy needs them installed.

if [[ "$PLATFORM" == omarchy ]]; then
  bold "Fonts"
  FONTDIR="$HOME/.local/share/fonts"
  mkdir -p "$FONTDIR"
  cp "$DOTFILES"/fonts/*.otf "$DOTFILES"/fonts/*.ttf "$FONTDIR/"
  fc-cache -f "$FONTDIR" >/dev/null
  ok "SF Mono + SF Mono Terminal -> $FONTDIR"
fi

# --------------------------------------------------------------- ghostty ----

bold "Ghostty"
pkg_install ghostty ghostty ghostty --cask
link "$DOTFILES/ghostty" "$HOME/.config/ghostty"

# --------------------------------------------------------------- neovim -----

bold "Neovim"
pkg_install nvim neovim neovim
link "$DOTFILES/nvim" "$HOME/.config/nvim"

# --------------------------------------------------------------- zed --------

bold "Zed"
if [[ "$PLATFORM" == mac ]]; then
  pkg_install zed zed zed --cask
else
  pkg_install zed zed zed
fi
link "$DOTFILES/zed/settings.json" "$HOME/.config/zed/settings.json"
link "$DOTFILES/zed/keymap.json"   "$HOME/.config/zed/keymap.json"

# --------------------------------------------------------------- vscode -----

bold "VS Code"
if [[ "$PLATFORM" == mac ]]; then
  pkg_install code visual-studio-code visual-studio-code-bin --cask
else
  pkg_install code visual-studio-code visual-studio-code-bin
fi
link "$DOTFILES/vscode/settings.json" "$VSCODE_USER/settings.json"
link "$DOTFILES/vscode/keybinds.json" "$VSCODE_USER/keybindings.json"

if command -v code >/dev/null 2>&1; then
  info "installing VS Code extensions"
  grep -oE '`[a-z0-9-]+\.[a-z0-9.-]+`' "$DOTFILES/vscode/extensions.md" \
    | tr -d '`' | sort -u \
    | while read -r ext; do code --install-extension "$ext" --force >/dev/null && ok "$ext"; done
fi

bold "Done."
