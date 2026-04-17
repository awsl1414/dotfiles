# 个人的配置文件

## 使用说明

### linux

### macos

0、安装 xcode
```bash
xcode-select --install
```

1、安装 brew
```bash
# 镜像站安装
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.bfsu.edu.cn/git/homebrew/brew.git"
git clone --depth=1 https://mirrors.bfsu.edu.cn/git/homebrew/install.git brew-install
/bin/bash brew-install/install.sh
rm -rf brew-install

# 官方安装脚本
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2、安装 rust
```bash
brew install rustup
```

2.1 初始化 rustup
```bash
rustup-init
```

3、安装 tuckr
```bash
cargo install --git https://github.com/RaphGL/Tuckr.git
```

4、恢复配置
```bash
cd Configs

# 恢复所有配置
tuckr add \* -f

# 执行所有恢复脚本
tuckr set \*
```