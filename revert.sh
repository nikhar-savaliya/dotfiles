#!/usr/bin/env bash
# Undo install.sh: remove the dotfiles symlinks, put the newest *.bak back in
# place, and delete the fonts that install.sh copied in.
#
# Does NOT uninstall packages (ghostty, nvim, zed, code, tmux) or VS Code
# extensions — remove those by hand if you want them gone.
#
#   ~/dotfiles/revert.sh [mac|omarchy]      # auto-detects platform if omitted
#   DRY_RUN=1 ~/dotfiles/revert.sh          # show what would happen

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/_lib.sh"

PLATFORM="$(resolve_platform "${1:-}")" || exit 1
DRY="${DRY_RUN:-}"
info "Platform: $PLATFORM${DRY:+  (dry run)}"

run() { if [[ -n "$DRY" ]]; then info "would: $*"; else "$@"; fi; }

# --------------------------------------------------------------- configs ----

bold "Configs"
while IFS=$'\t' read -r src dest; do
  if is_our_link "$src" "$dest"; then
    run rm "$dest"; ok "unlinked $dest"
  elif [[ -L "$dest" ]]; then
    warn "skip $dest — symlink points elsewhere ($(readlink "$dest"))"; continue
  elif [[ -e "$dest" ]]; then
    warn "skip $dest — not a symlink, leaving it"; continue
  else
    info "$dest — nothing there"
  fi

  restore="$(newest_backup "$dest")"
  if [[ -n "$restore" ]]; then
    run mv "$restore" "$dest"
    ok "restored $dest  (from ${restore##*/})"
    (( $(backups_for "$dest" | grep -c .) > 1 )) &&
      warn "older backups also present for $dest — remove by hand if unwanted"
  fi
done < <(link_map "$HERE" "$PLATFORM")

# --------------------------------------------------------------- fonts ------

bold "Fonts"
FONTDIR="$(font_dir "$PLATFORM")"
n=0
for f in "$HERE"/fonts/*.otf "$HERE"/fonts/*.ttf; do
  [[ -e "$f" ]] || continue
  t="$FONTDIR/${f##*/}"
  [[ -e "$t" ]] || continue
  run rm "$t"; n=$((n + 1))
done
if (( n )); then
  ok "removed $n font file(s) from $FONTDIR"
  if command -v fc-cache >/dev/null 2>&1; then run fc-cache -f "$FONTDIR" >/dev/null; fi
else
  info "no installed fonts to remove"
fi

bold "Done."
