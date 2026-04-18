#####################    加载插件    ####################
ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
load_plugin() {
    local name="$1"
    local file="$ZSH_PLUGIN_DIR/$name/$name.zsh"

    [[ -f "$file" ]] && source "$file"
}

load_plugin "zsh-vi-mode"
load_plugin "fzf-tab"
load_plugin "zsh-autosuggestions"
load_plugin "zsh-syntax-highlighting"

zstyle ':fzf-tab:*' fzf-flags \
    '--color=fg:7,fg+:2,hl:4,hl+:4' \
    '--height=80%' \
    '--layout=reverse' \
    '--border' \
    '--multi' \
    '--bind=tab:down,btab:up' \
    '--bind=ctrl-j:down,ctrl-k:up' \
    '--bind=enter:accept' \
    '--bind=ctrl-n:toggle+down,ctrl-p:toggle+up' \
    '--bind=ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
    '--preview-window=right:50%:rounded'

zstyle ':fzf-tab:complete:*:*' fzf-preview '
    if [ -d "$realpath" ]; then
        if command -v eza >/dev/null 2>&1; then
        eza --tree --icons --color=always -a "$realpath" | head -200
        else
        ls -F -A --color=always "$realpath" | head -200
        fi
    elif [ -f "$realpath" ]; then
        if command -v bat >/dev/null 2>&1; then
        bat --theme="Catppuccin Mocha" --color=always --style=numbers "$realpath" 2>/dev/null || cat "$realpath"
        else
        cat "$realpath"
        fi
    fi'

function zvm_after_lazy_keybindings() {
    bindkey -M vicmd -r ":"
}
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
