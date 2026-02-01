# ============================================
# 架构检测
# ============================================
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo "Apple Silicon"
    export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "Intel Chip"
    export HOMEBREW_PREFIX="/usr/local"
else
    echo "Unknown architecture: $ARCH"
fi

# ============================================
# 开发工具 PATH
# ============================================

# Go
export GOPATH=$HOME/go
path_add "$GOPATH/bin"

# Cargo (Rust)
path_add "$HOME/.cargo/bin"

# pipx
path_add "$HOME/.local/bin"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

# Rustup
path_add "$HOMEBREW_PREFIX/opt/rustup/bin"

# Homebrew
eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

# Bun
path_add "$HOME/.bun/bin"

# ============================================
# Homebrew 可选工具（条件加载）
# ============================================
if command -v brew >/dev/null 2>&1; then
    # OpenJDK
    JDK_PATH=$(brew --prefix openjdk 2>/dev/null)
    if [ -d "$JDK_PATH" ]; then
        export JAVA_HOME="$JDK_PATH"
        path_add "$JAVA_HOME/bin"
    fi

    # Kotlin
    KOTLIN_PATH=$(brew --prefix kotlin 2>/dev/null)
    if [ -d "$KOTLIN_PATH" ]; then
        export KOTLIN_HOME="$KOTLIN_PATH"
        path_add "$KOTLIN_HOME/bin"
    fi
fi

# ============================================
# 其他工具
# ============================================

# Antigravity
path_add "$HOME/.antigravity/antigravity/bin"

# ZeroBrew
export ZEROBREW_DIR="$HOME/.zerobrew"
export ZEROBREW_BIN="$HOME/.local/bin"
export ZEROBREW_ROOT=/opt/zerobrew
export ZEROBREW_PREFIX=/opt/zerobrew/prefix
export PKG_CONFIG_PATH="/opt/zerobrew/prefix/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
path_add "$ZEROBREW_BIN"
path_add "$ZEROBREW_PREFIX/bin"
