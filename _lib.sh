#!/usr/bin/env bash
# Shared helpers + the managed symlink map.
# Sourced by install.sh / cleanup.sh / revert.sh — not run directly.

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '\033[34m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[32m ✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m !!\033[0m %s\n' "$*"; }

# resolve_platform [arg] -> "mac" | "omarchy"  (auto-detects from $OSTYPE if empty)
resolve_platform() {
  case "${1:-}" in
    mac|macos)    echo mac ;;
    omarchy|arch) echo omarchy ;;
    "")           [[ "${OSTYPE:-}" == darwin* ]] && echo mac || echo omarchy ;;
    *)            warn "unknown platform: $1  (use mac|omarchy)"; return 1 ;;
  esac
}

vscode_user_dir() { # <platform>
  [[ "$1" == mac ]] \
    && echo "$HOME/Library/Application Support/Code/User" \
    || echo "$HOME/.config/Code/User"
}

font_dir() { # <platform>
  [[ "$1" == mac ]] \
    && echo "$HOME/Library/Fonts" \
    || echo "$HOME/.local/share/fonts"
}

# link_map <dotfiles-root> <platform>  ->  tab-separated "src<TAB>dest" lines.
# Single source of truth for what install links and what revert/cleanup touch.
link_map() {
  local root="$1" vsc; vsc="$(vscode_user_dir "$2")"
  printf '%s\t%s\n' \
    "$root/ghostty"              "$HOME/.config/ghostty" \
    "$root/nvim"                 "$HOME/.config/nvim" \
    "$root/zed/settings.json"    "$HOME/.config/zed/settings.json" \
    "$root/zed/keymap.json"      "$HOME/.config/zed/keymap.json" \
    "$root/vscode/settings.json" "$vsc/settings.json" \
    "$root/vscode/keybinds.json" "$vsc/keybindings.json" \
    "$root/tmux/.tmux.conf"      "$HOME/.tmux.conf"
}

# backups_for <dest>  ->  existing backup paths, oldest first (plain .bak, then .bak-<stamp>)
backups_for() {
  local dest="$1" b
  shopt -s nullglob
  [[ -e "$dest.bak" ]] && printf '%s\n' "$dest.bak"
  for b in "$dest".bak-*; do printf '%s\n' "$b"; done
  shopt -u nullglob
}

# newest_backup <dest>  ->  the most recent backup path, or nothing
newest_backup() { backups_for "$1" | tail -n1; }

# is_our_link <src> <dest>  ->  true if dest is a symlink pointing at src
is_our_link() { [[ -L "$2" && "$(readlink "$2")" == "$1" ]]; }
