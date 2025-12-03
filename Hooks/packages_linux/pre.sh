#!/bin/bash

# 判断是否为archlinux
if [[ -f /etc/arch-release ]]; then
    export IS_ARCHLINUX=true
else
    export IS_ARCHLINUX=false
fi

packages="$HOME"/packages.txt

if [[ $IS_ARCHLINUX == true ]]; then
    if [[ -L "$packages" || -f "$packages" ]]; then
        # 检查是否安装了paru
        if ! command -v paru &> /dev/null; then
            # 安装paru
            sudo pacman -S --needed paru --noconfirm
        fi
        paru -S --needed - < $packages --noconfirm
    fi
fi

echo "Packages installation completed."