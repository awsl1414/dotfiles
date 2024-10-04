#!/bin/bash

BACKUP_DIR="."

# mkdir -p "$BACKUP_DIR"

# 定义需要备份的文件和目录
FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.p10k.zsh"
    "$HOME/.npmrc"
    "$HOME/.czrc"
    "$HOME/.commitlintrc.cjs"
    "$HOME/.yarnrc"
    "$HOME/.makepkg.conf"
    "$HOME/.gitconfig"
    "$HOME/.cargo/config.toml"
    "$HOME/.aria2/"
    "$HOME/.config/alacritty"
    "$HOME/.config/kitty/"
    "$HOME/.config/nvim/"
    "$HOME/.config/pdm/"
    "$HOME/.config/pip/"
)

# 备份文件和目录
for FILE in "${FILES_TO_BACKUP[@]}"; do
    if [ -e "$FILE" ]; then
        # 获取文件的相对路径，相对于 HOME 目录
        RELATIVE_PATH="${FILE/#$HOME/}"  # 删除 $HOME 部分，保留相对路径
        TARGET_PATH="$BACKUP_DIR$RELATIVE_PATH"  # 在备份目录中重建相对路径

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
