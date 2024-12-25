#!/bin/bash

EXCLUDE=(
    ".git"
    ".gitignore"
    ".DS_Store"
    "restore.sh"
    "backup.sh"
    "README.md"
)

files=$(find . -maxdepth 1 ! -name '.')

function handle_exclude() {
    for i in "${!EXCLUDE[@]}"; do
        # 如果文件名不以 "./" 开头，添加 "./"
        if [[ ${EXCLUDE[$i]} != ./* ]]; then
            EXCLUDE["$i"]="./${EXCLUDE[$i]}"
        fi
    done
}

function main() {
    for file in $files; do
        if [[ ! " ${EXCLUDE[*]} " =~ ${file} ]]; then
            cp -r "$file" "$HOME"
        fi
    done
}

handle_exclude
main
