# --- 补全初始化 ---
fpath=($HOME/.local/share/zsh/completion/ $fpath)
autoload -Uz compinit && compinit

# 基础策
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
_comp_options+=(globdots)

_zellij_completer() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    if ((CURRENT == 3)); then
        if [[ "|attach|a|kill-session|k|delete-session|d|" == *"|$words[2]|"* ]]; then
            local -a sessions
            sessions=($(zellij list-sessions --short 2>/dev/null))
            if ((${#sessions} > 0)); then
                _describe -t sessions 'zellij sessions' sessions
                return 0
            fi
        fi
    fi

    if (($+functions[_zellij])); then
        _zellij "$@"
    fi
}

compdef _zellij_completer zellij
