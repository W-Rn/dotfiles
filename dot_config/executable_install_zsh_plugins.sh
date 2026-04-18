#!/bin/zsh

ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"

mkdir -p "$ZSH_PLUGIN_DIR"

# 检查 git 依赖
if ! command -v git &>/dev/null; then
    echo "❌ git is required to install these plugins."
    echo "Exiting..."
    exit 1
fi

typeset -A plugins
plugins=(
    "zsh-vi-mode"             "https://github.com/jeffreytse/zsh-vi-mode.git"
    "fzf-tab"                 "https://github.com/Aloxaf/fzf-tab.git"
    "zsh-autosuggestions"     "https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

failed_plugins=()


for name repo_url in ${(kv)plugins}; do
    target_dir="$ZSH_PLUGIN_DIR/$name"

    if [[ ! -d "$target_dir" ]]; then
        echo "🚀 $name not found, starting installation..."
        echo "📦 Cloning $name into $target_dir..."
        git clone --depth 1 "$repo_url" "$target_dir"

        if [[ $? -eq 0 ]]; then
            echo "✨ $name installation completed!"
        else
            echo "❌ Failed to install $name. Please check your network connection."
            failed_plugins+=("$name")
        fi
    else
        echo "✅ $name is already installed at: $target_dir"
        # git -C "$target_dir" pull --quiet
    fi
done

# 最终状态检查汇总
if [[ ${#failed_plugins[@]} -eq 0 ]]; then
    echo "✨ All Zsh plugins have been processed successfully in $ZSH_PLUGIN_DIR!"
else
    echo "❌ The following plugins failed to install:"
    for plugin in "${failed_plugins[@]}"; do
        echo "  - $plugin"
    done
    exit 1
fi

source "$HOME/.zshrc"
