#!/usr/bin/env bash
# Drop the *.bak backups install.sh left behind — but only for targets that are
# now proper dotfiles symlinks (i.e. that install succeeded). Fonts have no
# backups, so they're untouched.
#
#   ~/dotfiles/cleanup.sh [mac|omarchy]     # auto-detects platform if omitted
#   DRY_RUN=1 ~/dotfiles/cleanup.sh         # show what would be removed

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/_lib.sh"

PLATFORM="$(resolve_platform "${1:-}")" || exit 1
DRY="${DRY_RUN:-}"
info "Platform: $PLATFORM${DRY:+  (dry run)}"

removed=0 kept=0
while IFS=$'\t' read -r src dest; do
  if ! is_our_link "$src" "$dest"; then
    while read -r b; do [[ -n "$b" ]] || continue
      warn "keep $b — $dest is not linked to dotfiles"; kept=$((kept + 1))
    done < <(backups_for "$dest")
    continue
  fi
  while read -r bak; do
    [[ -n "$bak" ]] || continue
    if [[ -n "$DRY" ]]; then info "would remove $bak"
    else rm -rf "$bak"; ok "removed $bak"; fi
    removed=$((removed + 1))
  done < <(backups_for "$dest")
done < <(link_map "$HERE" "$PLATFORM")

msg="${removed} backup(s) $([[ -n "$DRY" ]] && echo 'would be removed' || echo removed)"
(( kept )) && msg="$msg, ${kept} kept (target not linked)"
bold "Done. $msg."
