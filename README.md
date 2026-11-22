# dotfiles

使用 [Chezmoi](https://www.chezmoi.io/) 管理的个人配置文件，支持 Linux (Arch) 和 macOS，按 base / full 两档决定部署范围。

## 档位

首次 `chezmoi init` 会问两个问题：

| 参数 | 取值 | 含义 |
|------|------|------|
| `profile` | `base` / `full` | base 部署 shell、git、命令行工具、基础语言运行时与 ghostty 的配置；full 在此基础上增加 zed、kitty 的配置，以及重型工具、GUI 应用与 IDE |
| `kde` | `auto` / `on` / `off` | `auto` 按当前会话是否 KDE 决定是否部署 KDE 配置文件，`on` / `off` 强制开关 |

选择会写进 `~/.config/chezmoi/chezmoi.toml` 的 `[data]`。Linux ARM 上 full 档按 base 处理：GUI 配置不部署，full 包清单也不安装。

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

先 init 回答两个问题，再 apply：

```bash
chezmoi init https://github.com/awsl1414/dotfiles.git
chezmoi apply
```

没有终端的环境（脚本、CI）给 init 加 `--promptDefaults`，它会直接采用默认值 `base` / `auto`：

```bash
chezmoi init --promptDefaults https://github.com/awsl1414/dotfiles.git
```

### 已有配置的机器

如果 `~/.config/chezmoi/chezmoi.toml` 是加档位参数之前生成的，`chezmoi apply`、`diff`、`status` 会打印：

```
warning: config file template has changed, run chezmoi init to regenerate config file
```

重跑一次 `chezmoi init` 补上 `profile` 与 `kde`，之后不再出现。

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

## 更换档位

init 时填过的值会被记住，重跑 init 不会重问。换档有两种做法：

```bash
$EDITOR ~/.config/chezmoi/chezmoi.toml   # 修改 [data] 下的 profile 或 kde
chezmoi apply
```

或者删掉 `~/.config/chezmoi/chezmoi.toml` 重新 `chezmoi init`，会重新询问。

从 full 降到 base 后，full 档的文件还留在 `~/.config` 里。用仓库里的脚本清理，默认只打印将删除的路径：

```bash
./scripts/cleanup-orphans.sh            # dry-run
./scripts/cleanup-orphans.sh --apply    # 真删
```

脚本只删与 chezmoi 记录一致的文件和空目录，手工改过的文件会跳过。

## 管理的配置

| 配置 | 平台 | 档位 | 说明 |
|------|------|------|------|
| zsh | 全部 | base | .zshrc / aliases / functions / path（模板合并） |
| git | 全部 | base | .gitconfig（模板化 email/name） |
| rust | 全部 | base | cargo 镜像配置 |
| python | 全部 | base | uv 镜像配置 |
| front | 全部 | base | npm / yarn 镜像 |
| zed | 全部 | full | 编辑器配置 |
| kitty | 全部 | full | 终端配置（含平台快捷键文件） |
| ghostty | 全部 | base | 终端配置 |
| fcitx5 | Linux | base | 输入法 |
| pipewire | Linux | base | 音频降噪与 JACK |
| plasma | Linux | 按 `kde` | KDE6 桌面 |
| packages | Arch / macOS | 按档位 | `packages/{base,full}/` 下的包清单 |

## 目录结构

```
├── .chezmoidata.yaml          # 默认数据：用户信息、镜像、档位、tiers
├── .chezmoi.toml.tmpl         # chezmoi 配置模板（询问 profile / kde）
├── .chezmoiignore.tmpl        # 平台与档位过滤规则
├── dot_gitconfig.tmpl         # ~/.gitconfig
├── dot_zshrc.tmpl             # ~/.zshrc
├── dot_zsh/                   # ~/.zsh/ (aliases, functions, path, mirrors)
├── dot_cargo/                 # ~/.cargo/
├── private_dot_config/        # ~/.config/ (ghostty, zed, kitty, ...)
├── private_dot_local/         # ~/.local/ (fcitx5 rime)
├── packages/                  # 包清单 (base/full × pacman/aur/Brewfile)
├── scripts/                   # cleanup-orphans.sh
└── .chezmoiscripts/           # 安装脚本 (插件、包、工具)
```
