
proxy() {
    local http_proxy_url="http://localhost:7897"
    local socks_proxy_url="socks5://localhost:7897"

    case "$1" in
        "on")
            # HTTP/HTTPS 代理
            export http_proxy="$http_proxy_url"
            export https_proxy="$http_proxy_url"
            export HTTP_PROXY="$http_proxy_url"
            export HTTPS_PROXY="$http_proxy_url"

            # SOCKS 代理
            export all_proxy="$socks_proxy_url"
            export ALL_PROXY="$socks_proxy_url"

            echo "🔌 代理已开启"
            echo "   HTTP/HTTPS: $http_proxy_url"
            echo "   SOCKS: $socks_proxy_url"
            ;;
        "off")
            # 取消 HTTP/HTTPS 代理
            unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

            # 取消 SOCKS 代理
            unset all_proxy ALL_PROXY

            echo "🔓 代理已关闭"
            ;;
        "status")
            echo "HTTP代理: ${http_proxy:-未设置}"
            echo "HTTPS代理: ${https_proxy:-未设置}"
            echo "SOCKS代理: ${all_proxy:-未设置}"
            ;;
        *)
            echo "终端代理使用方法:"
            echo "  proxy on     - 开启代理"
            echo "  proxy off    - 关闭代理"
            echo "  proxy status - 查看状态"
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