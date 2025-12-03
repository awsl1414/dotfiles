#!/bin/bash

# 定义配置目录
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
REPO_URL="https://github.com/awsl1414/wezterm-config.git"

# 检查目录是否存在且非空
if [[ ! -d "$WEZTERM_CONFIG_DIR" ]] || [[ -z "$(ls -A "$WEZTERM_CONFIG_DIR" 2>/dev/null)" ]]; then
    echo "Cloning wezterm configuration..."
    
    # 如果目录存在但为空，先删除
    if [[ -d "$WEZTERM_CONFIG_DIR" ]]; then
        rmdir "$WEZTERM_CONFIG_DIR"
    fi
    
    # 克隆仓库
    if git clone --depth 1 "$REPO_URL" "$WEZTERM_CONFIG_DIR" 2>/dev/null; then
        echo "Successfully cloned wezterm configuration to $WEZTERM_CONFIG_DIR"
    else
        echo "Error: Failed to clone repository" >&2
        exit 1
    fi
else
    echo "Wezterm configuration already exists at $WEZTERM_CONFIG_DIR"
fi
