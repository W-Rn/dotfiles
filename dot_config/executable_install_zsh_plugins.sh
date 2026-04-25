#!/bin/zsh

ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"

mkdir -p "$ZSH_PLUGIN_DIR"

if ! command -v git &>/dev/null; then
    echo "❌ git is required to install these plugins."
    echo "Exiting..."
    exit 1
fi

typeset -gA plugins
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
        if ! git clone --depth 1 "$repo_url" "$target_dir"; then
            echo "❌ Failed to install $name. Please check your network connection."
            rm -rf "$target_dir"
            failed_plugins+=("$name")
        else
            echo "✨ $name installation completed!"
        fi
    elif ! git -C "$target_dir" status &>/dev/null; then
        echo "⚠️ $name directory exists but is broken, re-cloning..."
        rm -rf "$target_dir"
        if ! git clone --depth 1 "$repo_url" "$target_dir"; then
            echo "❌ Failed to reinstall $name."
            failed_plugins+=("$name")
        else
            echo "✨ $name reinstallation completed!"
        fi
    elif [[ "$(git -C "$target_dir" remote get-url origin 2>/dev/null | sed 's|^git@github\.com:|https://github.com/|; s|\.git$||; s|/$||')" != \
            "$(sed 's|^git@github\.com:|https://github.com/|; s|\.git$||; s|/$||' <<< "$repo_url")" ]]; then
        echo "⚠️ $name remote URL mismatch, re-cloning..."
        rm -rf "$target_dir"
        if ! git clone --depth 1 "$repo_url" "$target_dir"; then
            echo "❌ Failed to reinstall $name."
            failed_plugins+=("$name")
        else
            echo "✨ $name reinstallation completed!"
        fi
    else
        echo "✅ $name is already installed at: $target_dir"
    fi
done

if [[ ${#failed_plugins[@]} -eq 0 ]]; then
    echo "✨ All Zsh plugins have been processed successfully in $ZSH_PLUGIN_DIR!"
else
    echo "❌ The following plugins failed to install:"
    for plugin in "${failed_plugins[@]}"; do
        echo "  - $plugin"
    done
    exit 1
fi
