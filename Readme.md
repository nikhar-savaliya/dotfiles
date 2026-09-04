# 🛠️ Dotfiles

A starter dotfiles setup for **Ghostty**, **Neovim** (LazyVim), **Zed**, **VS Code**, and **tmux** —
one install script for a fresh **MacBook** or an **Omarchy** (Arch / Hyprland) box.

## Install

One line on a fresh machine — installs git, clones to `~/dotfiles`, runs the installer:

```sh
curl -fsSL https://raw.githubusercontent.com/maxxkph/dotfiles/main/install.sh | bash -s -- mac
curl -fsSL https://raw.githubusercontent.com/maxxkph/dotfiles/main/install.sh | bash -s -- omarchy
```

Already cloned (run from anywhere — the scripts locate the repo themselves):

```sh
~/dotfiles/install.sh          # interactive menu
~/dotfiles/install.sh mac      # or non-interactive
```

Re-running is safe: packages already present are skipped, and the repo is `git pull`ed first when bootstrapped remotely.

The script:

| Step | macOS | Omarchy |
|---|---|---|
| Fonts (SF Mono, SF Mono Terminal) | copied to `~/Library/Fonts` | copied to `~/.local/share/fonts` + `fc-cache` |
| Ghostty | `brew install --cask ghostty` if missing | `pacman -S ghostty` if missing |
| Neovim | `brew install neovim` if missing | `pacman -S neovim` if missing |
| Zed | `brew install --cask zed` if missing | `pacman -S zed` if missing |
| VS Code | `brew install --cask visual-studio-code` if missing | `visual-studio-code-bin` if missing |
| tmux | `brew install tmux` if missing | `tmux` if missing |
| Configs | symlinked into `~/.config` (VS Code → `~/Library/Application Support/Code/User`, tmux → `~/.tmux.conf`) | symlinked into `~/.config` (tmux → `~/.tmux.conf`) |
| VS Code extensions | installed from `vscode/extensions.md` | same |

On Omarchy, package installs go through `omarchy-pkg-add` when present (repos + AUR + OPR), falling back to `pacman`/`yay`.

Existing files are backed up next to the original as `<name>.bak` (or `<name>.bak-<timestamp>` if a `.bak` is already there) before linking.

## Cleanup & revert

```sh
~/dotfiles/cleanup.sh [mac|omarchy]   # delete the .bak backups (only where linking succeeded)
~/dotfiles/revert.sh  [mac|omarchy]   # undo: drop symlinks, restore newest .bak, remove installed fonts
```

Both auto-detect the platform if omitted and take `DRY_RUN=1` to preview. `revert.sh` leaves
installed packages and VS Code extensions in place — remove those by hand.

## Layout

```
install.sh   set up a machine
cleanup.sh   remove backups after a good install
revert.sh    undo install.sh
_lib.sh      shared helpers + the symlink map (single source of truth)

ghostty/     config + themes/ + custom icon      -> ~/.config/ghostty
nvim/        LazyVim config                      -> ~/.config/nvim
zed/         settings.json, keymap.json          -> ~/.config/zed/
vscode/      settings.json, keybinds.json,       -> Code User dir
             extensions.md
fonts/       SF Mono / SF Mono Terminal (.otf/.ttf)
tmux/        .tmux.conf                          -> ~/.tmux.conf
```
