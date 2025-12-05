
# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# cargo
export PATH=$PATH:$HOME/.cargo/bin

# Created by `pipx` on 2025-08-23 13:15:59
export PATH="$PATH:$HOME/.local/bin"


export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
# export PATH="/opt/homebrew/opt/curl/bin:$PATH"


eval "$(/opt/homebrew/bin/brew shellenv)"
