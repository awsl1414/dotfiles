#!/bin/bash

# 判断是否为archlinux
if [[ -f /etc/arch-release ]]; then
    export IS_ARCHLINUX=true
else
    export IS_ARCHLINUX=false
fi

# 如果是archlinux，安装$HOME/aur.txt和$HOME/pacman.txt中的软件包
if [[ $IS_ARCHLINUX == true ]]; then
    # 安装pacman软件包
    if [[ -f $HOME/Configs/package_linux/pacman.txt ]]; then
        sudo pacman -Syu --needed - < $HOME/pacman.txt --noconfirm
    fi

    if [[ -f $HOME/Configs/package_linux/aur.txt ]]; then
        # 检查是否安装了paru
        if ! command -v paru &> /dev/null; then
            # 安装paru
            sudo pacman -S --needed paru --noconfirm
        fi

        # 使用paru安装AUR软件包
        paru -S --needed - < $HOME/aur.txt --noconfirm
    fi
fi

echo "Packages installation completed."