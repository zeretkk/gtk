#!/usr/bin/env bash
set -euo pipefail

theme_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
gtk4_config_dir="$config_dir/gtk-4.0"

links=(
  "$theme_dir/gtk-4.0/gtk.css:$gtk4_config_dir/gtk.css"
  "$theme_dir/gtk-4.0/gtk-dark.css:$gtk4_config_dir/gtk-dark.css"
  "$theme_dir/assets:$config_dir/assets"
)

usage() {
  printf '%s\n' \
    "Usage: $0 [link|unlink|status]" \
    "" \
    "Links Dracula GTK4 files into \$XDG_CONFIG_HOME for libadwaita apps." \
    "Default command: link"
}

target_matches_source() {
  local source="$1"
  local target="$2"

  [[ -L "$target" ]] || return 1
  [[ "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]
}

link_one() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    printf 'Missing source: %s\n' "$source" >&2
    return 1
  fi

  mkdir -p "$(dirname "$target")"

  if target_matches_source "$source" "$target"; then
    printf 'Already linked: %s -> %s\n' "$target" "$source"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    printf 'Backed up existing target: %s -> %s\n' "$target" "$backup"
  fi

  ln -s "$source" "$target"
  printf 'Linked: %s -> %s\n' "$target" "$source"
}

unlink_one() {
  local source="$1"
  local target="$2"

  if target_matches_source "$source" "$target"; then
    rm "$target"
    printf 'Removed link: %s\n' "$target"
  else
    printf 'Skipped: %s is not linked to this theme\n' "$target"
  fi
}

status_one() {
  local source="$1"
  local target="$2"

  if target_matches_source "$source" "$target"; then
    printf 'OK: %s -> %s\n' "$target" "$source"
  elif [[ -e "$target" || -L "$target" ]]; then
    printf 'DIFF: %s exists but points elsewhere\n' "$target"
  else
    printf 'MISSING: %s\n' "$target"
  fi
}

command="${1:-link}"

case "$command" in
  link)
    for item in "${links[@]}"; do
      IFS=: read -r source target <<< "$item"
      link_one "$source" "$target"
    done
    ;;
  unlink)
    for item in "${links[@]}"; do
      IFS=: read -r source target <<< "$item"
      unlink_one "$source" "$target"
    done
    ;;
  status)
    for item in "${links[@]}"; do
      IFS=: read -r source target <<< "$item"
      status_one "$source" "$target"
    done
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
