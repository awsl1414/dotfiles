# dotfiles

chezmoi 管理的个人 dotfiles，覆盖 Arch Linux（KDE Plasma）与 macOS，按 base / full 两档决定部署范围。`README.md` 面向使用者，本文件面向在本仓库里改配置的 agent。

## 常用命令

```bash
chezmoi edit ~/.zshrc              # 编辑某个目标对应的源文件
chezmoi diff                       # 预览变更；配置里的 diff.exclude 排除脚本
chezmoi apply                      # 应用；run_onchange 脚本在这里执行
chezmoi add ~/.gitconfig           # 把已有文件纳入管理
chezmoi status                     # 按条目列出差异，脚本条目也在内
chezmoi verify --exclude scripts   # 目标状态一致时退出 0
chezmoi cd                         # 进入源目录
chezmoi data                       # 查看模板数据
chezmoi execute-template '{{ .mirrors.npm }}'
chezmoi update                     # git pull 后 apply

./scripts/cleanup-orphans.sh             # dry-run，列出降档残留
./scripts/cleanup-orphans.sh --apply     # 真删
```

## 档位

`profile` 取 `base` 或 `full`，`kde` 取 `auto` / `on` / `off`。两个值由 `promptChoiceOnce` 在 `chezmoi init` 时询问，写进 `~/.config/chezmoi/chezmoi.toml` 的 `[data]`。

- **base**：shell、git、命令行工具、基础语言运行时与 ghostty 的配置
- **full**：在 base 之上部署 `~/.config/zed` 与 `~/.config/kitty`，并安装重型工具、GUI 应用与 IDE
- **kde**：`auto` 按会话里的 `$KDE_SESSION_VERSION` 判断是否部署 KDE 文件，`on` / `off` 强制开关
- **Linux ARM**（`os == linux` 且 `arch == arm64`）上 full 档降级为 base：GUI 配置不进 destination，full 包清单也不装。macOS arm64 不受影响，判断同时看 os 与 arch

`promptChoiceOnce` 读到已有值就不再询问。换档要改 `chezmoi.toml` 的 `[data]` 再 apply，或者删掉配置文件重新 init。

## 数据流

`.chezmoidata.yaml` 是默认值的唯一来源：`user`、`mirrors`、`profile`、`kde`、`tiers`、`arch_tweaks`。模板用 `{{ .user.email }}`、`{{ .mirrors.go }}` 取用。`~/.config/chezmoi/chezmoi.toml` 的 `[data]` 覆盖同名默认值，所以机器本地选择不影响仓库里的默认。

`tiers.full.dirs` 与 `tiers.full.files` 是 full 档的路径清单：`.chezmoiignore.tmpl` 据此排除，`scripts/cleanup-orphans.sh` 也读同一份清单。新增 full 专属路径只改这里，不要在两处各写一份。

`arch_tweaks.arm64.pacman_skip` 列出 ARM 上 Arch 官方仓库没有的包，安装脚本据此跳过。它只作用于 base 清单，因为 ARM 上 full 档不安装。

## 跨平台

1. **`.chezmoiignore.tmpl`**：非 Linux 排除 makepkg、mirrors.zsh、`.config/go/`、fcitx5、pipewire、environment.d、`.local/`；full 档目录按 profile 与 ARM 规则排除；KDE 文件按 `kde` 参数排除
2. **模板条件**：`{{ if eq .chezmoi.os "linux" }}` / `"darwin"` 分支，用在 zshrc、aliases、path 与两个安装脚本
3. **平台专属文件**：kitty 的 `keybindings/linux.conf` 与 `keybindings/macos.conf` 分开维护

写 ignore 时，`{{ . }}` 必须单独成行。写成 `{{- range }}{{ . }}` 会把多轮输出粘成一个不存在的路径，ignore 静默失效。判断 KDE 会话用 `env "KDE_SESSION_VERSION"` 模板函数；模板数据里没有 `.Env`，用它取环境变量会直接报错。

仓库根的普通目录（没有 `dot_` / `private_` 前缀）会被当成目标目录部署，新增同级目录时要同时写进 ignore。

## 脚本

`.chezmoiscripts/` 按文件名前缀排序执行：

| 前缀 | 脚本 | 行为 |
|---|---|---|
| `run_once_before_10` | `install-zsh-plugins.sh` | 克隆 Oh My Zsh、zsh-autosuggestions、zsh-syntax-highlighting、Powerlevel10k，均 `--depth 1` |
| `run_onchange_30` | `install-packages.sh.tmpl` | Arch：按档位读清单，`pacman -S --needed` 加 `paru -S --needed`；macOS：`brew bundle`；其他 Linux 打印跳过后 `exit 0` |
| `run_once_after_50` | `install-git-tools.sh.tmpl` | 先装 bun（macOS 走 Homebrew，Arch 走 pacman），再用 bun 装 commitizen 与 cz-git |

`run_onchange_30` 正文顶部写入了六个清单文件的 sha256，改清单会让脚本内容变化并触发重跑。脚本正文也随 `profile` 变化，切到 full 后 apply 会补装 full 包。脚本通过 `{{ .chezmoi.sourceDir }}` 找到 `packages/`。ARM 上另有过滤：`.chezmoidata.yaml` 的 `arch_tweaks.arm64.pacman_skip` 列出该架构官方仓库没有的包，安装时跳过。

`run_once` 只执行一次，`run_onchange` 在脚本内容变化时重跑。执行发生在 apply 阶段，`diff` 和 `status` 只显示不执行。

## 包清单

每个档位下三份清单：`pacman.txt`、`aur.txt`、`Brewfile`，按平台取用。

- Arch 的 base：keyring、CLI 工具、终端、输入法与音频、基础语言运行时
- Arch 的 full：字体、图形驱动、多媒体播放器与重型开发工具
- macOS 的 base：CLI 工具、基础语言运行时、通用终端与常用 GUI 应用
- macOS 的 full：重型工具、GUI 应用与 IDE，外加 vscode 扩展

两侧的划分不要求对称：同一个软件在两个平台可以属于不同档位。

`packages/` 整目录被 ignore，只作为数据源。

## 首次使用与验证

新机器先 `chezmoi init`，再 `chezmoi apply`。没有终端（脚本、CI）时 init 要加 `--promptDefaults`，否则 `promptChoiceOnce` 打不开 `/dev/tty`，init 直接失败。`apply` 没有这个 flag；未 init 就 apply 会打印 `config file template has changed` 警告并继续，档位取 `.chezmoidata.yaml` 的默认值，且不会生成配置文件。

已经跑过 init 的机器，如果配置文件由加档位参数之前的模板生成，`apply`、`diff`、`status` 都会打印同一段警告，重跑一次 `chezmoi init` 即可消除。

验证只对临时 destination，不要碰真实 home：

```bash
T=$(mktemp -d); mkdir -p "$T/home"
CZ=(--source "$PWD" --destination "$T/home" --config "$T/cfg.toml" \
    --cache "$T/cache" --persistent-state "$T/state.bolt")
chezmoi "${CZ[@]}" init --promptDefaults
chezmoi "${CZ[@]}" apply --exclude scripts
chezmoi "${CZ[@]}" --override-data '{"profile":"full"}' managed
rm -rf "${T:?}/home"
```

`--override-data` 可以改 `.chezmoi.os`、`.chezmoi.arch`、`.profile`，用来验证分支。`stat "/etc/arch-release"` 不受它影响，读的是真实文件系统，macOS 上走不到 Arch 分支，这类改动只能到真实 Arch 机器确认。

直接 `chezmoi verify` 会因脚本条目失败：脚本不参与 diff，却参与 verify，加 `--exclude scripts`。

## 命名

- `dot_` 前缀 → 目标名去掉前缀（`dot_zshrc.tmpl` → `~/.zshrc`）
- `private_` 前缀 → 部署后为私有权限
- `.tmpl` 后缀 → 走 Go 模板
- 目录名同样按前缀映射（`private_dot_config/kitty/` → `~/.config/kitty/`）

`CLAUDE.md` 只有一行 `@AGENTS.md` 导入，规则只写在本文件。
