#!/bin/bash
# shellcheck disable=SC1091

INSTALLDIR="$HOME/.local/bin"
SOFTWAREDIR="$HOME/.local/software"
NPM_GLOBAL_DIR="$HOME/.npm-global"

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
if [ ! -x "$(command -v cargo)" ]; then
    echo "🦀 Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
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
    rm -rf "$SOFTWAREDIR/chezmoi"
    mkdir -p "$SOFTWAREDIR/chezmoi"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$SOFTWAREDIR/chezmoi"

    echo "🔗 Linking chezmoi to $INSTALLDIR..."
    ln -sf "$SOFTWAREDIR/chezmoi/chezmoi" "$INSTALLDIR/chezmoi"
    echo "✨ chezmoi installation completed!"
else
    echo "✅ chezmoi is already installed at $(command -v chezmoi)"
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
    echo "✨ neovim installation completed!"
else
    echo "✅ neovim is already installed at $(command -v nvim)"
fi

##############################        lazygit              ##############################
if ! command -v "lazygit" &>/dev/null; then
    echo "🚀 lazygit not found, starting installation..."
    curl -Lo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.60.0/lazygit_0.60.0_linux_x86_64.tar.gz
    rm -rf "$SOFTWAREDIR/lazygit"
    mkdir -p "$SOFTWAREDIR/lazygit"
    tar -xvf lazygit.tar.gz -C "$SOFTWAREDIR/lazygit"

    echo "🔗 Linking lazygit to $INSTALLDIR..."
    ln -sf "$SOFTWAREDIR/lazygit/lazygit" "$INSTALLDIR/lazygit"

    rm -f lazygit.tar.gz
    echo "✨ lazygit installation completed! at: $(command -v lazygit)"
else
    echo "✅ lazygit is already installed at: $(command -v lazygit)"
fi

##############################        fzf              ##############################
if ! command -v "fzf" &>/dev/null; then
    echo "🚀 fzf not found, starting installation..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && "$HOME/.fzf/install"
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

for cmd in "${!tools[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        cargo install "${tools[$cmd]}"
    else
        echo "✅ $cmd is already installed at: $(command -v "$cmd")"
    fi
done

##############################        NVM & Node         ##############################
if [ ! -d "$HOME/.nvm" ]; then
    echo "🚀 Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # 导出 NVM 环境变量以便在当前进程中使用
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    echo "✅ nvm is already installed."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

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
if [ ! -d "$NPM_GLOBAL_DIR" ]; then
    echo "⚙️ Configuring npm global directory at $NPM_GLOBAL_DIR..."
    mkdir -p "$NPM_GLOBAL_DIR"
    npm config set prefix "$NPM_GLOBAL_DIR"
fi
