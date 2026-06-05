# dotfiles

使用 [Chezmoi](https://www.chezmoi.io/) 管理的个人配置文件，支持 Linux (Arch) 和 macOS。

## 快速开始

### 安装 Chezmoi

**macOS:**
```bash
brew install chezmoi
```

**Arch Linux:**
```bash
sudo pacman -S chezmoi
```

### 从本仓库初始化

```bash
chezmoi init --apply https://github.com/awsl1414/dotfiles.git
```

初始化时会提示输入 Email 地址，用于 gitconfig 等模板。

### 在新机器上恢复配置

```bash
chezmoi init --apply --verbose https://github.com/awsl1414/dotfiles.git
```

## 日常使用

```bash
# 编辑配置文件（在源目录中）
chezmoi edit ~/.zshrc

# 查看变更
chezmoi diff

# 应用变更
chezmoi apply

# 从本机更新到源目录
chezmoi add ~/.zshrc

# 从远程拉取最新并应用
chezmoi update
```

## 管理的配置

| 配置 | 跨平台 | 说明 |
|------|--------|------|
| zsh | ✅ | .zshrc / aliases / functions / path (模板合并) |
| git | ✅ | .gitconfig (模板化 email/name) |
| ghostty | ✅ | 终端配置 |
| zed | ✅ | 编辑器配置 |
| kitty | ✅ | 终端配置 (含平台快捷键) |
| rust | ✅ | cargo config |
| python | ✅ | uv 镜像配置 |
| front | ✅ | npm/yarn 镜像 |
| fcitx5 | Linux | 输入法 |
| pipewire | Linux | 音频降噪 |
| plasma | Linux | KDE6 桌面 |
| packages | Linux | Arch 包列表 |

## 目录结构

```
├── .chezmoidata.yaml          # 个人数据变量
├── .chezmoi.toml.tmpl         # chezmoi 配置模板
├── .chezmoiignore.tmpl        # 平台过滤规则
├── dot_gitconfig.tmpl         # ~/.gitconfig
├── dot_zshrc.tmpl             # ~/.zshrc
├── dot_zsh/                   # ~/.zsh/ (aliases, functions, path, mirrors)
├── dot_cargo/                 # ~/.cargo/
├── private_dot_config/        # ~/.config/ (ghostty, zed, kitty, ...)
├── private_dot_local/         # ~/.local/ (fcitx5 rime)
└── .chezmoiscripts/           # 脚本 (安装插件、工具、包)
```

## 从 Tuckr 迁移

本仓库于 2026-06 从 Tuckr 迁移至 Chezmoi，主要变化：

- 包管理 → 模板 + 条件判断
- Hooks → `.chezmoiscripts/` (run_once / run_onchange)
- Linux/Mac 分离 → 单一配置 + `{{ if eq .chezmoi.os }}` 模板
- 硬编码个人信息 → `.chezmoidata.yaml` 变量化
