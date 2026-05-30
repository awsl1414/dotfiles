# ============================================
# 架构检测
# ============================================
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    # echo "Apple Silicon"
    export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$ARCH" == "x86_64" ]]; then
    # echo "Intel Chip"
    export HOMEBREW_PREFIX="/usr/local"
else
    echo "Unknown architecture: $ARCH"
fi

# Homebrew
eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

# ============================================
# 开发工具 PATH
# ============================================


# Rust rustup-init
source "$HOME/.cargo/env"

# Go
export GOPATH=$HOME/go
path_add "$GOPATH/bin"

# pipx
path_add "$HOME/.local/bin"

# Bun
path_add "$HOME/.bun/bin"

# ============================================
# Homebrew 可选工具（条件加载）
# ============================================
if command -v brew >/dev/null 2>&1; then

    # OpenJDK
    jdk=$(
        brew list --formula |
        grep '^openjdk' |
        sort -V |
        tail -1
    )

    JDK_PATH="$(brew --prefix "$jdk")/libexec/openjdk.jdk/Contents/Home"
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

    # Android SDK
    # ANDROID_HOME 是旧版的 SDK 路径，ANDROID_SDK_ROOT 是新版的 SDK 路径
    export ANDROID_HOME="$(brew --prefix)/share/android-commandlinetools"
    if [ -d "$ANDROID_HOME" ]; then
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
        path_add "$ANDROID_HOME/cmdline-tools/latest/bin"
        path_add "$ANDROID_HOME/platform-tools"
    fi

    # Android NDK
    export ANDROID_NDK_HOME="$(brew --prefix)/share/android-ndk"
    if [ -d "$ANDROID_NDK_HOME" ]; then
        path_add "$ANDROID_NDK_HOME"
    fi

fi

# ============================================
# 其他工具
# ============================================

# Antigravity
path_add "$HOME/.antigravity/antigravity/bin"

# # ZeroBrew
# export ZEROBREW_DIR="$HOME/.zerobrew"
# export ZEROBREW_BIN="$HOME/.local/bin"
# export ZEROBREW_ROOT=/opt/zerobrew
# export ZEROBREW_PREFIX=/opt/zerobrew/prefix
# export PKG_CONFIG_PATH="/opt/zerobrew/prefix/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
# path_add "$ZEROBREW_BIN"
# path_add "$ZEROBREW_PREFIX/bin"

export TUCKR_HOME="$HOME/.dotfiles"

# Added by Obsidian
path_add "/Applications/Obsidian.app/Contents/MacOS"

path_add "$HOMEBREW_PREFIX/opt/curl/bin"

# Fnm
eval "$(fnm env --use-on-cd --shell zsh)"
