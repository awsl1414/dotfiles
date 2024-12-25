#!/bin/bash

BACKUP_DIR="."

BACKUP_FILES=(
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.zshenv"
    "$HOME/.p10k.zsh"
    "$HOME/.npmrc"
    "$HOME/.yarnrc"
    "$HOME/.czrc"
    "$HOME/.commitlintrc.cjs"
    "$HOME/.gitconfig"
    "$HOME/.cargo/config.toml"
    "$HOME/.config/alacritty"
    "$HOME/.config/kitty/"
    "$HOME/.config/nvim/"
    "$HOME/.config/pdm/"
    "$HOME/.config/pip/"
)

function main() {
    for FILE in "${BACKUP_FILES[@]}"; do
        if [ -e "$FILE" ]; then
            # 获取文件的相对路径，相对于 HOME 目录
            RELATIVE_PATH="${FILE/#$HOME/}"         # 删除 $HOME 部分，保留相对路径
            TARGET_PATH="$BACKUP_DIR$RELATIVE_PATH" # 在备份目录中重建相对路径

            # 如果是目录，直接创建目录并复制
            if [ -d "$FILE" ]; then
                mkdir -p "$(dirname "$TARGET_PATH")"
                cp -r "$FILE" "$TARGET_PATH"
                echo "已备份目录: $FILE 到 $TARGET_PATH"
            else
                # 如果是文件，创建父目录后再复制文件
                mkdir -p "$(dirname "$TARGET_PATH")"
                cp "$FILE" "$TARGET_PATH"
                echo "已备份文件: $FILE 到 $TARGET_PATH"
            fi
        else
            echo "文件不存在: $FILE"
        fi
    done
    echo "备份完成，所有文件已复制到: $BACKUP_DIR"
}

main