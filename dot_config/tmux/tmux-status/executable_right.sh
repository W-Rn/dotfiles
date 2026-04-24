#!/usr/bin/env bash
set -euo pipefail

# hide entire right status if terminal width is below threshold
min_width=${TMUX_RIGHT_MIN_WIDTH:-90}
width=$(tmux display-message -p '#{client_width}' 2>/dev/null || true)
if [[ -z "${width:-}" || "$width" == "0" ]]; then
    width=$(tmux display-message -p '#{window_width}' 2>/dev/null || true)
fi
if [[ -z "${width:-}" || "$width" == "0" ]]; then
    width=${COLUMNS:-}
fi
if [[ -n "${width:-}" && "$width" =~ ^[0-9]+$ ]]; then
    if ((width < min_width)); then
        exit 0
    fi
fi

status_bg=$(tmux show -gqv status-bg)
if [[ -z "$status_bg" || "$status_bg" == "default" ]]; then
    status_bg="#2e3440"
fi

# segment_bg="#3b4252"
segment_fg="#d8dee9"
# Host (domain) colors to mirror left active style
host_bg="${TMUX_THEME_COLOR:-#88c0d0}"
host_fg="#2e3440"
# separator=""
separator=""
right_cap="█"
# right_cap=""
hostname=$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf 'host')
rainbarf_bg="#3b4252"
rainbarf_segment=""
rainbarf_toggle="${TMUX_RAINBARF:-1}"

case "$rainbarf_toggle" in
0 | false | FALSE | off | OFF | no | NO)
    rainbarf_toggle="0"
    ;;
*)
    rainbarf_toggle="1"
    ;;
esac

if [[ "$rainbarf_toggle" == "1" ]] && command -v rainbarf >/dev/null 2>&1; then
    rainbarf_output=$(rainbarf --no-battery --no-remaining --no-bolt --tmux --rgb 2>/dev/null || true)
    rainbarf_output=${rainbarf_output//$'\n'/}
    if [[ -n "$rainbarf_output" ]]; then
        rainbarf_segment=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]%s' \
            "$rainbarf_bg" "$status_bg" "$separator" \
            "$segment_fg" "$rainbarf_bg" "$rainbarf_output")
    fi
fi

# Time and date (24h)
now=$(date '+%H:%M')
date_str=$(date '+%Y-%m-%d')

# Build a connector into the main block using host colors
host_connector_bg="$status_bg"
if [[ -n "$rainbarf_segment" ]]; then
    host_connector_bg="$rainbarf_bg"
fi

printf '%s#[fg=%s,bg=%s]%s#[fg=%s,bg=%s,bold] %s %s | #[fg=%s,bg=%s]%s #[fg=%s,bg=%s]%s' \
    "$rainbarf_segment" \
    "$host_bg" "$host_connector_bg" "$separator" \
    "$host_fg" "$host_bg" "$now" "$date_str" \
    "$host_fg" "$host_bg" "$hostname" \
    "$host_bg" "$status_bg" "$right_cap"
