#!/bin/zsh

# 定义补全路径
COMP_DIR="$HOME/.local/share/zsh/completion"
mkdir -p "$COMP_DIR"

# 确保当前路径包含你安装软件的目录，否则脚本找不到命令
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

echo "⏳ Generating Zsh completions..."

# Zellij 补全
if command -v zellij &>/dev/null; then
    zellij setup --generate-completion zsh >"$COMP_DIR/_zellij"
    echo "✅ Zellij completion generated."
fi

# uv 补全
if command -v uv &>/dev/null; then
    uv generate-shell-completion zsh >"$COMP_DIR/_uv"
    echo "✅ uv completion generated."
fi

# Chezmoi 补全
if command -v chezmoi &>/dev/null; then
    chezmoi completion zsh >"$COMP_DIR/_chezmoi"
    echo "✅ Chezmoi completion generated."
fi

# Starship 补全
if command -v starship &>/dev/null; then
    starship completions zsh >"$COMP_DIR/_starship" 2>/dev/null
    echo "✅ Starship completion generated."
fi

# fd 补全
if command -v fd &>/dev/null; then
    fd --gen-completions zsh >"$COMP_DIR/_fd" 2>/dev/null
    echo "✅ fd completion generated."
fi

# 强制 Zsh 重新构建补全缓存
rm -f ~/.zcompdump
echo "✅ All completions generated. Restart your shell or run: exec zsh"
