alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias yy='yazi'
alias c='clear'
alias tl='tmux ls'
# alias reboot='sudo reboot --no-wall'
# alias sudonv='sudo -E nvim'
alias clash_start='source ~/.config/clash/active'
alias clash_stop='source ~/.config/clash/stop'
alias clash_restart='clash_stop && sleep 2 && clash_start'
if [[ -x $(command -v eza) ]]; then
    alias ls='eza --icons'
    alias ll='eza --icons --sort Name --long'
    alias la='eza --icons --sort Name --all --long'
    alias lh='eza --icons --sort newest --group --long'
    alias tree='eza --tree --icons'
else
    alias ls='ls --color=auto'
    alias lh='ls -alhrt --time-style=long-iso'
fi
if [[ -x $(command -v bat) ]]; then
    alias cat="bat --theme='Catppuccin Mocha'"
else
    alias cat='cat'
fi
