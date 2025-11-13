#!/bin/bash

# 如果任何命令失败，则立即退出
set -e

# 定义一个函数来加载 NVM
load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    # 检查常见的 NVM 脚本路径
    if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
        # Homebrew on Apple Silicon/Intel
        . "/opt/homebrew/opt/nvm/nvm.sh"
    elif [ -s "$NVM_DIR/nvm.sh" ]; then
        # Standard NVM install
        . "$NVM_DIR/nvm.sh"
    elif [ -s "/usr/share/nvm/init-nvm.sh" ]; then
        # System-wide install (e.g., Arch Linux package)
        . "/usr/share/nvm/init-nvm.sh"
    else
        echo "错误：找不到 nvm.sh 脚本。" >&2
        return 1
    fi
}

# 判断系统类型
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS 系统
    if ! command -v brew &> /dev/null; then
        echo "Homebrew 未安装，正在安装..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # 确保 brew 命令在 PATH 中
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    # 如果 nvm 未安装，则使用 brew 安装
    if ! command -v nvm &> /dev/null; then
        echo "nvm 未安装，正在使用 Homebrew 安装..."
        brew install nvm
    fi

elif [[ "$(uname)" == "Linux" ]]; then
    # Linux 系统，默认 archlinux
    # 如果 nvm 未安装，则使用 pacman 安装
    if ! command -v nvm &> /dev/null; then
        echo "nvm 未安装，正在使用 pacman 安装..."
        sudo pacman -Sy --noconfirm nvm
    fi
fi

# 加载 NVM 环境
echo "加载 NVM 环境..."
load_nvm

# 使用 nvm 安装并使用 Node.js LTS 版本
echo "安装/更新 Node.js LTS 版本..."
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

# 安装全局 npm 包 (如果尚未安装)
if ! command -v commitizen &> /dev/null; then
    echo "安装 commitizen 和 cz-git..."
    npm i -g cz-git commitizen
else
    echo "commitizen 已安装。"
fi

echo "环境设置完成。"