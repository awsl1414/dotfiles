
# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# cargo
export PATH=$PATH:$HOME/.cargo/bin

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# Created by `pipx` on 2025-08-23 13:15:59
export PATH="$PATH:$HOME/.local/bin"

eval "$(zoxide init zsh)"