#!/bin/bash

# 定义备份目录为当前目录中的 backup 目录
BACKUP_DIR="."

# 检查备份目录是否存在
if [ ! -d "$BACKUP_DIR" ]; then
    echo "备份目录不存在: $BACKUP_DIR"
    exit 1
fi

# 定义需要还原的文件和目录相对路径
FILES_TO_RESTORE=(
    ".zshrc"
    ".p10k.zsh"
    ".npmrc"
    ".czrc"
    ".commitlintrc.cjs"
    ".yarnrc"
    ".makepkg.conf"
    ".gitconfig"
    ".cargo/config.toml"
    ".aria2"
    ".config/alacritty"
    ".config/kitty"
    ".config/nvim"
    ".config/pdm"
    ".config/pip"
)

# 还原文件和目录
for FILE in "${FILES_TO_RESTORE[@]}"; do
    BACKUP_FILE="$BACKUP_DIR/$FILE"  # 备份目录中的文件
    TARGET_PATH="$HOME/$FILE"  # 恢复到用户的 HOME 目录


    if [ -e "$BACKUP_FILE" ]; then
        # 如果是目录，使用 cp -r 递归复制
        if [ -d "$BACKUP_FILE" ]; then
            mkdir -p "$TARGET_PATH"
            cp -r "$BACKUP_FILE"/* "$TARGET_PATH/"
            echo "已还原目录: $BACKUP_FILE 到 $TARGET_PATH"
        else
            # 如果是文件，直接复制
            mkdir -p "$(dirname "$TARGET_PATH")"  # 创建父目录
            cp "$BACKUP_FILE" "$TARGET_PATH"
            echo "已还原文件: $BACKUP_FILE 到 $TARGET_PATH"
        fi
    else
        echo "备份文件不存在: $BACKUP_FILE"
    fi
done

echo "还原完成，所有文件已从 $BACKUP_DIR 还原到 $HOME"
