# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A [Chezmoi](https://www.chezmoi.io/) dotfiles repository managing configurations across Arch Linux (KDE Plasma) and macOS. Migrated from Tuckr. Comments and README are in Chinese (Simplified).

## Chezmoi Commands

```bash
chezmoi edit <file>          # Edit a managed file (opens in $EDITOR)
chezmoi diff                 # Preview pending changes (scripts excluded via diff.exclude)
chezmoi apply                # Apply all changes to the target system
chezmoi add <path>           # Start managing a new dotfile
chezmoi cd                   # Shell into the source directory (this repo)
chezmoi data                 # View all template data (useful for debugging templates)
chezmoi execute-template '{{ .mirrors.npm }}'  # Test a single template expression
chezmoi re-add               # Refresh managed files from target system
```

## Architecture

### Template Data Flow

`.chezmoidata.yaml` is the single source of truth for user info and mirror URLs. Templates reference values via `{{ .user.email }}`, `{{ .mirrors.go }}`, etc. The email is collected on first `chezmoi init` via `promptStringOnce` in `.chezmoi.toml.tmpl`.

### Cross-Platform Strategy

Three mechanisms handle OS differences:

1. **`.chezmoiignore.tmpl`** — excludes Linux-only files (makepkg, mirrors.zsh, fcitx5, pipewire, environment.d, `.local/`) on non-Linux; excludes KDE files when `$KDE_SESSION_VERSION` is unset (uses `env "KDE_SESSION_VERSION"` template function, not `.Env`)
2. **Go template conditionals** in `.tmpl` files — `{{ if eq .chezmoi.os "linux" }}` / `{{ if eq .chezmoi.os "darwin" }}` in zshrc, aliases, path, and scripts
3. **Separate config files** — e.g. Kitty has `linux.conf` and `macos.conf` keybinding files

### Scripts (`.chezmoiscripts/`)

Execution order is determined by numeric prefix:

| Phase | Script | Behavior |
|-------|--------|----------|
| `before_10` | `install-zsh-plugins.sh` | Clones Oh My Zsh, plugins, Powerlevel10k (all OS, `--depth 1`) |
| `onchange_30` | `install-packages.sh.tmpl` | Arch: `pacman -S --needed` + `paru -S --needed` from txt files; macOS: `brew bundle` |
| `after_50` | `install-git-tools.sh.tmpl` | Installs bun (OS-appropriate), then commitizen + cz-git via bun |

`run_once` = execute once; `run_onchange` = re-execute when script content changes. Scripts use `{{ .chezmoi.sourceDir }}` to locate package files.

### Package Lists (`packages/`)

- `pacman.txt` — Arch official packages (GPU drivers, fonts, input method, dev tools)
- `aur.txt` — AUR packages (apps + fcitx5 themes)
- `Brewfile` — macOS (CLI + casks + VS Code extensions)

The entire `packages/` directory is excluded from deployment via `.chezmoiignore.tmpl` — it's a data source only.

### Modular Zsh Config (`dot_zsh/`)

`.zshrc` sources modular `.zsh` files from `~/.zsh/`:
- `mirrors.zsh.tmpl` — mirror env vars (Linux only)
- `aliases.zsh.tmpl` — platform-specific aliases
- `path.zsh.tmpl` — PATH setup with `path_add` deduplication helper
- `functions.zsh` — `path_add` and `pxy` (proxy toggle, default localhost:7897)

### Chezmoi File Naming Conventions

- `dot_` prefix → `.` in target (e.g. `dot_zshrc` → `~/.zshrc`)
- `private_` prefix → restrictive permissions on deployed file
- `.tmpl` suffix → Go template processing
- Directories map directly (e.g. `private_dot_config/ghostty/` → `~/.config/ghostty/`)

## Key Patterns

- **Mirror centralization**: All Chinese mirror URLs live in `.chezmoidata.yaml`, referenced by templates for npm, Go, Rust, Node.js, Python (uv)
- **Commit style**: cz-git with emoji-based types (feat/fix/refactor/etc.)
- **Arch build optimizations**: `.makepkg.conf` uses `-march=native -O3`, ccache, aria2, multi-threaded compression
