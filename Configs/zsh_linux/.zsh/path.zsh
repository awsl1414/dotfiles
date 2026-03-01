# ============================================
# 开发工具 PATH
# ============================================

# Go
export GOPATH=$HOME/go
path_add "$GOPATH/bin"

# Cargo (Rust)
path_add "$HOME/.cargo/bin"

# Bun
path_add "$HOME/.bun/bin"

# pipx
path_add "$HOME/.local/bin"
