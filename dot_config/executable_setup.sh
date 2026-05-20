#!/bin/bash
# shellcheck disable=SC1091

INSTALLDIR="$HOME/.local/bin"
SOFTWAREDIR="$HOME/.local/software"
NODE_VERSION="22.14.0"
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
    echo "🚀 Installing Rust..."
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
        echo "✨ Rust installation completed! at: $(command -v cargo)"
    else
        echo "❌ Failed to install Rust"
    fi
else
    echo "✅ cargo is already installed at: $(command -v cargo)"
fi

export PATH="${HOME}/.cargo/bin:${INSTALLDIR}:${PATH}"

##############################        starship          ##############################
if ! command -v "starship" &>/dev/null; then
    echo "🚀 Installing Starship..."
    if curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$INSTALLDIR"; then
        echo "✨ starship installation completed! at: $(command -v starship)"
    else
        echo "❌ Failed to install starship"
    fi
else
    echo "✅ starship is already installed at: $(command -v starship)"
fi

##############################        chezmoi         ###############################
if ! command -v "chezmoi" &>/dev/null; then
    echo "🚀 chezmoi not found, starting installation..."
    if sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$INSTALLDIR"; then
        echo "✨ chezmoi installation completed! at: $(command -v chezmoi)"
    else
        echo "❌ Failed to install chezmoi"
    fi
else
    echo "✅ chezmoi is already installed at: $(command -v chezmoi)"
fi

##############################           uv              ##############################
if ! command -v "uv" &>/dev/null; then
    echo "🚀 uv not found, starting installation..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh -s -- -y --bin-dir "$INSTALLDIR"; then
        echo "✨ uv installation completed! at: $(command -v uv)"
    else
        echo "❌ Failed to install uv"
    fi
else
    echo "✅ uv is already installed at: $(command -v uv)"
fi

##############################        neovim          ##############################
if ! command -v "nvim" &>/dev/null; then
    echo "🚀 neovim not found, starting installation..."
    TMPDIR=$(mktemp -d)
    if curl -fLo "$TMPDIR/nvim.tar.gz" \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
        rm -rf "$SOFTWAREDIR/nvim" && \
        mkdir -p "$SOFTWAREDIR/nvim" "$HOME/.local/share/nvim/undo" && \
        echo "📦 Extracting neovim..." && \
        tar -xzf "$TMPDIR/nvim.tar.gz" -C "$SOFTWAREDIR/nvim" --strip-components=1 && \
        ln -sf "$SOFTWAREDIR/nvim/bin/nvim" "$INSTALLDIR/nvim" && \
        rm -rf "$TMPDIR"; then
        echo "✨ neovim installation completed! at: $(command -v nvim)"
    else
        echo "❌ Failed to install neovim"
        rm -rf "$TMPDIR"
    fi
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
    if git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && "$HOME/.fzf/install" --no-update-rc; then
        echo "✨ fzf installation completed! at: $(command -v fzf)"
    else
        echo "❌ Failed to install fzf"
        rm -rf "$HOME/.fzf"
    fi
else
    echo "✅ fzf is already installed at: $(command -v fzf)"
fi

##############################        Node.js          ##############################
if ! command -v "node" &>/dev/null; then
    echo "🚀 Downloading Node.js v${NODE_VERSION}..."
    TMPDIR=$(mktemp -d)
    if curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o "$TMPDIR/node.tar.xz" && \
        tar -xJf "$TMPDIR/node.tar.xz" -C "$SOFTWAREDIR" && \
        ln -sf "$SOFTWAREDIR/node-v${NODE_VERSION}-linux-x64/bin/node" "$INSTALLDIR/node" && \
        ln -sf "$SOFTWAREDIR/node-v${NODE_VERSION}-linux-x64/bin/npm" "$INSTALLDIR/npm" && \
        ln -sf "$SOFTWAREDIR/node-v${NODE_VERSION}-linux-x64/bin/npx" "$INSTALLDIR/npx"; then
        rm -rf "$TMPDIR"
        echo "✨ Node.js v${NODE_VERSION} installation completed! at: $(command -v node)"
    else
        echo "❌ Failed to install Node.js"
        rm -rf "$TMPDIR" "$SOFTWAREDIR/node-v${NODE_VERSION}-linux-x64"
    fi
else
    echo "✅ node is already installed at: $(command -v node)"
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
