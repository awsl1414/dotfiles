
# arclinux dotfiles

## 怎么用

### 安装软件

```shell

paru -S zsh oh-my-zsh-git autojump \
zsh-syntax-highlighting zsh-autosuggestions \
zsh-theme-powerlevel10k-git \
ttf-meslo-nerd-font-powerlevel10k \
powerline-fonts awesome-terminal-fonts

paru -S alacritty kitty aria2
```

### 创建软链接

```shell
sudo ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting /usr/share/oh-my-zsh/custom/plugins/ 
sudo ln -s /usr/share/zsh/plugins/zsh-autosuggestions /usr/share/oh-my-zsh/custom/plugins/
sudo ln -s /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme /usr/share/oh-my-zsh/custom/themes
```
