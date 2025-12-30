
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

export PATH="/Users/logan/.bun/bin:$PATH"

if command -v brew >/dev/null 2>&1; then
    
    # 尝试获取 openjdk 路径，如果存在则配置
    JDK_PATH=$(brew --prefix openjdk 2>/dev/null)
    if [ -d "$JDK_PATH" ]; then
        export JAVA_HOME="$JDK_PATH"
        export PATH="$JAVA_HOME/bin:$PATH"
    fi

    # 尝试获取 kotlin 路径，如果存在则配置
    KOTLIN_PATH=$(brew --prefix kotlin 2>/dev/null)
    if [ -d "$KOTLIN_PATH" ]; then
        export KOTLIN_HOME="$KOTLIN_PATH"
        export PATH="$KOTLIN_PATH/bin:$PATH"
    fi
    
fi