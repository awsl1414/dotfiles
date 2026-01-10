#!/bin/bash

# 如果任何命令失败，则立即退出
set -e

if [[ "$ARCH" == "arm64" ]]; then
    echo "Apple Silicon"
    export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "Intel Chip"
    export HOMEBREW_PREFIX="/usr/local"
else
    echo "Unknown architecture: $ARCH"
fi


# 判断系统类型
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS 系统
    if ! command -v brew &> /dev/null; then
        echo "Homebrew 未安装，正在安装..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # 确保 brew 命令在 PATH 中
    eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"

    # 如果 bun 未安装，则使用 brew 安装
    if ! command -v bun &> /dev/null; then
        echo "bun 未安装，正在使用 Homebrew 安装..."
        brew install oven-sh/bun/bun
    fi

elif [[ "$(uname)" == "Linux" ]]; then
    # Linux 系统，默认 archlinux
        sudo pacman -Sy --need --noconfirm bun
fi


# 安装全局 npm 包 (如果尚未安装)
if ! command -v commitizen &> /dev/null; then
    echo "安装 commitizen 和 cz-git..."
    bun i -g cz-git commitizen
else
    echo "commitizen 已安装。"
fi

echo "环境设置完成。"
