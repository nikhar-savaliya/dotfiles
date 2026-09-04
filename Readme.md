# 🛠️ Dotfiles

A starter dotfiles setup for **Ghostty**, **Neovim** (LazyVim), **Zed**, **VS Code**, and **tmux** —
one install script for a fresh **MacBook** or an **Omarchy** (Arch / Hyprland) box.

## Install

```sh
git clone <this-repo> ~/dotfiles && cd ~/dotfiles
./install.sh            # interactive menu
# or non-interactive:
./install.sh mac
./install.sh omarchy
```

The script:

| Step | macOS | Omarchy |
|---|---|---|
| Fonts (SF Mono, SF Mono Terminal) | skipped — macOS ships them | copied to `~/.local/share/fonts` + `fc-cache` |
| Ghostty | `brew install --cask ghostty` if missing | `pacman -S ghostty` if missing |
| Neovim | `brew install neovim` if missing | `pacman -S neovim` if missing |
| Zed | `brew install --cask zed` if missing | `pacman -S zed` if missing |
| VS Code | `brew install --cask visual-studio-code` if missing | `visual-studio-code-bin` (AUR) if missing |
| Configs | symlinked into `~/.config` (VS Code → `~/Library/Application Support/Code/User`) | symlinked into `~/.config` |
| VS Code extensions | installed from `vscode/extensions.md` | same |

Existing files are backed up to `*.bak-<timestamp>` before linking.

## Layout

```
ghostty/   config + themes/ + custom icon      -> ~/.config/ghostty
nvim/      LazyVim config                      -> ~/.config/nvim
zed/       settings.json, keymap.json          -> ~/.config/zed/
vscode/    settings.json, keybinds.json,       -> User dir
           extensions.md
fonts/     SF Mono / SF Mono Terminal (.otf/.ttf)
tmux/      .tmux.conf
```
