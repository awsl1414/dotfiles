alias zed="zeditor"
alias reboot="sudo systemctl reboot"
alias shutdown="sudo systemctl poweroff"
alias poweroff="sudo systemctl poweroff"

# 检查是否安装 nvim
if command -v nvim >/dev/null 2>&1; then
    alias vim="nvim"
fi
