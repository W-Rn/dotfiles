export FZF_DEFAULT_COMMAND='fd'
export FZF_COMPLETION_TRIGGER=',,'
export FZF_DEFAULT_OPTS="
    --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
    --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
    --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
    --color=selected-bg:#45475A \
    --color=border:#6C7086,label:#CDD6F4 \
    --height 80%
    --layout=reverse
    --border
    --multi
    --bind 'tab:down'
    --bind 'btab:up'
    --bind 'ctrl-j:down'
    --bind 'ctrl-k:up'
    --bind 'enter:accept'
    --bind 'ctrl-n:toggle+down'
    --bind 'ctrl-p:toggle+up'
    --preview '
        if [ -d {} ]; then
            if command -v eza >/dev/null 2>&1; then
                eza --tree --icons --color=always {} | head -200
            else
                ls -R {} | head -200
            fi
            else
            if command -v bat >/dev/null 2>&1; then
                bat --theme=\"Catppuccin Mocha\" --style=numbers --color=always {} 2>/dev/null || cat {}
            else
                cat {}
            fi
        fi'
    --preview-window 'right:50%'
    --bind 'ctrl-u:preview-page-up'
    --bind 'ctrl-d:preview-page-down'
"
# _fzf_compgen_path() {
#   fd --hidden --exclude .git . "$1"
# }
#
# _fzf_compgen_dir() {
#   fd --type d --hidden --exclude .git . "$1"
# }
