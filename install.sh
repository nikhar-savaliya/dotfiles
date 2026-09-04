#!/usr/bin/env bash
# Dotfiles installer — macOS (MacBook) or Omarchy (Arch/Hyprland).
#
# Remote (nothing cloned yet):
#   curl -fsSL https://raw.githubusercontent.com/maxxkph/dotfiles/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/maxxkph/dotfiles/main/install.sh | bash -s -- omarchy
#
# Local:
#   ./install.sh            # interactive menu
#   ./install.sh mac        # non-interactive
#   ./install.sh omarchy

set -euo pipefail

REPO_URL="https://github.com/maxxkph/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '\033[34m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[32m ✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m !!\033[0m %s\n' "$*"; }

# ------------------------------------------------------------- bootstrap ----
# When piped from curl there is no checkout — grab git, clone/update, re-exec.

SELF="${BASH_SOURCE[0]:-}"
if [[ -z "$SELF" || ! -f "$SELF" || ! -d "$(dirname "$SELF")/ghostty" ]]; then
  if ! command -v git >/dev/null 2>&1; then
    info "installing git"
    if [[ "$OSTYPE" == darwin* ]]; then
      xcode-select --install || true
      warn "finish the Command Line Tools install, then re-run this command"
      exit 1
    elif command -v omarchy-pkg-add >/dev/null 2>&1; then omarchy-pkg-add git
    else sudo pacman -S --needed --noconfirm git; fi
  fi
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    info "updating $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only
  else
    info "cloning $REPO_URL -> $DOTFILES_DIR"
    git clone "$REPO_URL" "$DOTFILES_DIR"
  fi
  exec bash "$DOTFILES_DIR/install.sh" "$@"
fi

DOTFILES="$(cd "$(dirname "$SELF")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

# ---------------------------------------------------------------- platform ----

PLATFORM="${1:-}"
if [[ -z "$PLATFORM" ]]; then
  if [[ -r /dev/tty ]]; then
    bold "Where are you setting up?"
    echo "  1) MacBook (macOS)"
    echo "  2) Omarchy (Arch / Hyprland)"
    read -rp "> " choice </dev/tty
    case "$choice" in
      1) PLATFORM=mac ;;
      2) PLATFORM=omarchy ;;
      *) warn "unknown choice"; exit 1 ;;
    esac
  else
    warn "no terminal for the menu — pass one explicitly:  ... | bash -s -- {mac|omarchy}"
    exit 1
  fi
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
    if command -v omarchy-pkg-add >/dev/null 2>&1; then
      omarchy-pkg-add "$arch_pkg"                       # Omarchy wrapper (repos + AUR + OPR)
    elif pacman -Si "$arch_pkg" >/dev/null 2>&1; then
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
    local bak="$dest.bak"
    [[ -e "$bak" ]] && bak="$dest.bak-$STAMP"   # keep the old .bak, don't clobber
    mv "$dest" "$bak"
    warn "backed up existing $dest -> $bak"
  fi
  ln -s "$src" "$dest"
  ok "$dest -> $src"
}

VSCODE_USER="$HOME/.config/Code/User"
[[ "$PLATFORM" == mac ]] && VSCODE_USER="$HOME/Library/Application Support/Code/User"

# --------------------------------------------------------------- fonts ------
# SF Mono only lives inside Terminal.app's bundle — install it properly so the
# config doesn't depend on Apple keeping it there.

bold "Fonts"
if [[ "$PLATFORM" == mac ]]; then
  FONTDIR="$HOME/Library/Fonts"
else
  FONTDIR="$HOME/.local/share/fonts"
fi
mkdir -p "$FONTDIR"
cp "$DOTFILES"/fonts/*.otf "$DOTFILES"/fonts/*.ttf "$FONTDIR/"
command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$FONTDIR" >/dev/null
ok "SF Mono + SF Mono Terminal -> $FONTDIR"

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
    | while read -r ext; do
        if code --install-extension "$ext" --force >/dev/null 2>&1; then ok "$ext"
        else warn "could not install $ext"; fi
      done
fi

# --------------------------------------------------------------- tmux ------

bold "tmux"
pkg_install tmux tmux tmux
link "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

bold "Done."
