
pxy() {
    local DEFAULT_PORT="7897"

    case "$1" in
        off)
            unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
            echo "proxy off"
            ;;
        st)
            if [ -z "$http_proxy" ]; then
                echo "proxy off"
                return
            fi
            echo "  HTTP(S) $http_proxy"
            echo "  SOCKS   $all_proxy"
            curl -Is --connect-timeout 2 --proxy "$http_proxy" https://www.google.com >/dev/null 2>&1 \
                && echo "connect ok" || echo "connect fail"
            ;;
        -h|--help)
            echo "usage: pxy [off|st|[host]:port]"
            echo "  (none)       enable proxy (localhost:7897)"
            echo "  <host>       enable proxy to <host>:7897"
            echo "  <host>:port  enable proxy to <host>:<port>"
            echo "  :<port>      enable proxy to localhost:<port>"
            echo "  off          disable proxy"
            echo "  st           show status & connectivity"
            ;;
        *)
            local target="${1:-localhost}"
            # 如果没有冒号，追加默认端口
            if [[ "$target" != *:* ]]; then
                target="$target:$DEFAULT_PORT"
            fi
            local http_url="http://$target"
            local socks_url="socks5://$target"
            export http_proxy="$http_url" https_proxy="$http_url"
            export HTTP_PROXY="$http_url" HTTPS_PROXY="$http_url"
            export all_proxy="$socks_url" ALL_PROXY="$socks_url"
            echo "proxy on"
            echo "  HTTP(S) $http_url"
            echo "  SOCKS   $socks_url"
            ;;
    esac
}

# 查找文件内容
fgr() {
    grep -rn "$1" .
}

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 显示当前分支
git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# 智能添加到 PATH（自动去重）
# 用法: path_add /path/to/bin
path_add() {
    local argpath="$1"
    case ":${PATH}:" in
        *:"$argpath":*) ;;
        *) export PATH="$argpath:$PATH" ;;
    esac
}
