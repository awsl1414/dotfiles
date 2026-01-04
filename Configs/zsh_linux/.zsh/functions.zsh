
proxy() {
    # 默认 HOST 为 localhost，如果传入了第二个参数则使用第二个参数
    local HOST="${2:-localhost}"
    local PORT="7897"
    local http_proxy_url="http://$HOST:$PORT"
    local socks_proxy_url="socks5://$HOST:$PORT"

    case "$1" in
        "on")
            export http_proxy="$http_proxy_url"
            export https_proxy="$http_proxy_url"
            export HTTP_PROXY="$http_proxy_url"
            export HTTPS_PROXY="$http_proxy_url"
            export all_proxy="$socks_proxy_url"
            export ALL_PROXY="$socks_proxy_url"

            echo "🔌 代理已开启"
            echo "    Host:  $HOST"
            echo "    HTTP:  $http_proxy_url"
            echo "    SOCKS: $socks_proxy_url"
            ;;
        "off")
            unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
            echo "🔓 代理已关闭"
            ;;
        "status")
            echo "当前代理状态:"
            echo "  HTTP/HTTPS: ${http_proxy:-未设置}"
            echo "  SOCKS:      ${all_proxy:-未设置}"
            # 顺便检测一下网络连通性
            if [ -n "$http_proxy" ]; then
                echo -n "  连通性测试: "
                curl -Is --connect-timeout 2 https://www.google.com | grep -q "HTTP" && echo "✅ 成功" || echo "❌ 失败"
            fi
            ;;
        *)
            echo "终端代理使用方法:"
            echo "  proxy on [host] - 开启代理 (默认 localhost)"
            echo "  proxy off       - 关闭代理"
            echo "  proxy status    - 查看状态"
            echo "示例: proxy on 192.168.1.5"
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