
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

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

eval "$(zoxide init zsh)"