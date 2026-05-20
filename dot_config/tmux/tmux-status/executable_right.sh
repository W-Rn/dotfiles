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
    status_bg="#1a1b26"
fi

# ── 各区块独立配色 ──
sys_seg_bg="#3b4261"
sys_seg_fg="#c0caf5"
time_seg_bg="#cba6f7"
time_seg_fg="#1a1b26"
hostname_seg_bg="${TMUX_THEME_COLOR:-#7aa2f7}"
hostname_seg_fg="#1a1b26"

separator=""
right_cap="█"
hostname=$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf 'host')

# ── System 段 ──
sys_segment=""
if command -v tmux-mem-cpu-load >/dev/null 2>&1; then
    sys_raw=$(tmux-mem-cpu-load 2>/dev/null || true)
    if [[ -n "$sys_raw" ]]; then
        mem_text=$(awk '{print $1}' <<<"$sys_raw")
        cpu=$(awk '{print $4}' <<<"$sys_raw")
        sys_output="${mem_text:+  $mem_text }${cpu:+  $cpu}"
        sys_segment=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s] %s ' \
            "$sys_seg_bg" "$status_bg" "$separator" \
            "$sys_seg_fg" "$sys_seg_bg" "$sys_output")
    fi
fi

# ── Time 段 ──
now=$(date '+%H:%M')
date_str=$(date '+%Y-%m-%d')

connector_bg="$status_bg"
[[ -n "$sys_segment" ]] && connector_bg="$sys_seg_bg"

time_segment=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s,bold]  %s %s ' \
    "$time_seg_bg" "$connector_bg" "$separator" \
    "$time_seg_fg" "$time_seg_bg" "$now" "$date_str")

# ── Hostname 段 ──
hostname_segment=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s,bold]  %s ' \
    "$hostname_seg_bg" "$time_seg_bg" "$separator" \
    "$hostname_seg_fg" "$hostname_seg_bg" "$hostname")

# ── 右侧收尾 ──
right_cap_segment=$(printf '#[fg=%s,bg=%s]%s' \
    "$hostname_seg_bg" "$status_bg" "$right_cap")

# ── 最终输出 ──
printf '%s%s%s%s' \
    "$sys_segment" \
    "$time_segment" \
    "$hostname_segment" \
    "$right_cap_segment"
