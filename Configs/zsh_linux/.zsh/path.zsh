# ============================================
# 开发工具 PATH
# ============================================

# Go
export GOPATH=$HOME/go
path_add "$GOPATH/bin"

# Cargo (Rust)
path_add "$HOME/.cargo/bin"

# Bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
path_add "$BUN_INSTALL/bin"

# pipx
path_add "$HOME/.local/bin"
