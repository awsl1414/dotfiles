#!/bin/bash

# 判断是否为archlinux
if [[ -f /etc/arch-release ]]; then
    export IS_ARCHLINUX=true
else
    export IS_ARCHLINUX=false
fi

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}
packages_dir="$XDG_CONFIG_HOME/packages"

if [[ $IS_ARCHLINUX == true ]]; then
    pacman_file="$packages_dir/pacman.txt"
    aur_file="$packages_dir/aur.txt"
    
    # 使用pacman安装官方仓库包
    if [[ -f "$pacman_file" ]]; then
        echo "正在从pacman.txt安装官方仓库包..."
        grep -v '^#' "$pacman_file" | xargs sudo pacman -S --needed --noconfirm
    else
        echo "警告: $pacman_file 不存在"
    fi
    
    # 使用paru安装AUR包
    if [[ -f "$aur_file" ]]; then
        # 检查是否安装了paru
        if ! command -v paru &> /dev/null; then
            echo "正在安装paru..."
            sudo pacman -S --needed paru --noconfirm
        fi
        echo "正在从aur.txt安装AUR包..."
        grep -v '^#' "$aur_file" | xargs paru -S --needed --noconfirm
    else
        echo "警告: $aur_file 不存在"
    fi
fi

echo "包管理器安装完成。"