#!/bin/bash
# shellcheck disable=SC1091

INSTALLDIR="$HOME/.local/bin"
SOFTWAREDIR="$HOME/.local/software"
NPM_GLOBAL_DIR="$HOME/.npm-global"
LAZYGIT_VERSION="0.60.0"

if [ ! -x "$(command -v curl)" ]; then
    echo "curl is required for pulling pre-compiled binaries from git release page"
    echo "Exiting..."
    exit 1
fi
if [ ! -x "$(command -v git)" ]; then
    echo "Please install git first (e.g., sudo apt install git)."
    echo "Exiting..."
    exit 1
fi

mkdir -p "$INSTALLDIR"
mkdir -p "$SOFTWAREDIR"

##############################        Rust            ##############################
if ! command -v "cargo" &>/dev/null; then
    echo "🦀 Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
else
    echo "✅ cargo is already installed at: $(command -v cargo)"
fi

export PATH="${HOME}/.cargo/bin:${INSTALLDIR}:${PATH}"

##############################        starship          ##############################
if ! command -v "starship" &>/dev/null; then
    echo "🚀 Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$INSTALLDIR"
else
    echo "✅ starship is already installed at: $(command -v starship)"
fi

##############################        chezmoi         ###############################
if ! command -v "chezmoi" &>/dev/null; then
    echo "🚀 chezmoi not found, starting installation..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$INSTALLDIR"
    echo "✨ chezmoi installation completed! at: $(command -v chezmoi)"
else
    echo "✅ chezmoi is already installed at: $(command -v chezmoi)"
fi

##############################           uv              ##############################
if ! command -v "uv" &>/dev/null; then
    echo "🚀 uv not found, starting installation..."
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- -y --bin-dir "$INSTALLDIR"
else
    echo "✅ uv is already installed at: $(command -v uv)"
fi

##############################        neovim          ##############################
if ! command -v "nvim" &>/dev/null; then
    echo "🚀 neovim not found, starting installation..."
    curl -Lo nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    rm -rf "$SOFTWAREDIR/nvim"
    mkdir -p "$SOFTWAREDIR/nvim"
    echo "📦 Extracting neovim to $SOFTWAREDIR/nvim..."
    tar -xzf nvim.tar.gz -C "$SOFTWAREDIR/nvim" --strip-components=1

    echo "🔗 Linking nvim to $INSTALLDIR..."
    ln -sf "$SOFTWAREDIR/nvim/bin/nvim" "$INSTALLDIR/nvim"
    rm -f nvim.tar.gz
    echo "✨ neovim installation completed! at: $(command -v nvim)"
else
    echo "✅ neovim is already installed at: $(command -v nvim)"
fi

##############################        lazygit              ##############################
if ! command -v "lazygit" &>/dev/null; then
    echo "🚀 lazygit not found, starting installation..."
    if curl -fLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_x86_64.tar.gz"; then
        tar -xzf lazygit.tar.gz -C "$INSTALLDIR" lazygit
        rm -f lazygit.tar.gz
        echo "✨ lazygit installation completed! at: $(command -v lazygit)"
    else
        echo "❌ Failed to download lazygit"
        rm -f lazygit.tar.gz
    fi
else
    echo "✅ lazygit is already installed at: $(command -v lazygit)"
fi

##############################        fzf              ##############################
if ! command -v "fzf" &>/dev/null; then
    echo "🚀 fzf not found, starting installation..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && "$HOME/.fzf/install" --no-update-rc
else
    echo "✅ fzf is already installed at: $(command -v fzf)"
fi

##############################      cargo install       ##############################
declare -A tools=(
    ["rg"]="ripgrep"
    ["bat"]="bat"
    ["zoxide"]="zoxide"
    ["eza"]="eza"
    ["fd"]="fd-find"
    ["yazi"]="--force yazi-build"
    ["zellij"]="--locked zellij"
    ["btm"]="bottom --locked"
)

failed_tools=()
for cmd in "${!tools[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "🚀 Installing $cmd..."
        if ! cargo install "${tools[$cmd]}"; then
            echo "❌ Failed to install $cmd"
            failed_tools+=("$cmd")
        fi
    else
        echo "✅ $cmd is already installed at: $(command -v "$cmd")"
    fi
done

if [[ ${#failed_tools[@]} -gt 0 ]]; then
    echo "❌ The following tools failed to install via cargo:" >&2
    printf "  - %s\n" "${failed_tools[@]}" >&2
fi

##############################        NVM & Node         ##############################
if [ ! -d "$HOME/.nvm" ]; then
    echo "🚀 Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | PROFILE=/dev/null bash
else
    echo "✅ nvm is already installed."
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 安装 Node.js LTS 版本
if ! command -v "node" &>/dev/null; then
    echo "📦 Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
else
    echo "✅ node is already installed at: $(command -v node) and at: NPM $(command -v npm)"
    echo "✨ Node $(node -v) and NPM $(npm -v) are ready!"
fi

# 配置 NPM 全局安装目录 (避免 sudo)
if command -v npm &>/dev/null; then
    echo "⚙️ Configuring npm global directory at $NPM_GLOBAL_DIR..."
    mkdir -p "$NPM_GLOBAL_DIR"
    npm config set prefix "$NPM_GLOBAL_DIR"
fi
