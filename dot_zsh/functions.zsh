
# 开关终端代理。目标写成 [host][:port]，只给 host 时补默认端口，
# 只给 :port 时用 localhost。
px() {
    local DEFAULT_HOST="localhost"
    local DEFAULT_PORT="7897"
    local probe_url="https://www.gstatic.com/generate_204"

    case "${1:-}" in
        off)
            unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
            echo "proxy off"
            return 0
            ;;
        st|status)
            if [[ -z "${http_proxy:-}" ]]; then
                echo "proxy off"
                return 0
            fi
            printf '  HTTP(S) %s\n' "$http_proxy"
            printf '  SOCKS   %s\n' "${all_proxy:-未设置}"
            # 只测 HTTP 代理，SOCKS 变量可能指向不同入口
            curl -Is --connect-timeout 2 --proxy "$http_proxy" "$probe_url" >/dev/null 2>&1 \
                && echo "connect ok" || echo "connect fail"
            return 0
            ;;
        -h|--help)
            cat <<'EOF'
usage: px [off|st|<host>[:<port>]|:<port>]

  px                开代理，指向 localhost:7897
  px <host>         指向 <host>:7897
  px <host>:<port>  指向指定地址
  px :<port>        指向 localhost:<port>
  px off            关代理，清除相关环境变量
  px st             显示当前代理并测试连通性
EOF
            return 0
            ;;
    esac

    local target="${1:-$DEFAULT_HOST}"
    local host port
    if [[ "$target" == :* ]]; then
        host="$DEFAULT_HOST"
        port="${target#:}"
    elif [[ "$target" == *:* ]]; then
        host="${target%:*}"
        port="${target##*:}"
    else
        host="$target"
        port="$DEFAULT_PORT"
    fi

    # 不校验的话 "::" 这类输入会拼出 http://localhost:: 这样的无效 URL，
    # 而环境变量已经导出，后续所有请求都会失败且看不出原因
    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        echo "px: 端口必须是数字，收到 '$port'" >&2
        return 1
    fi
    if [[ -z "$host" ]]; then
        echo "px: 无法解析目标 '$1'，用 px --help 看用法" >&2
        return 1
    fi

    local http_url="http://$host:$port"
    local socks_url="socks5://$host:$port"
    export http_proxy="$http_url" https_proxy="$http_url"
    export HTTP_PROXY="$http_url" HTTPS_PROXY="$http_url"
    export all_proxy="$socks_url" ALL_PROXY="$socks_url"
    printf 'proxy on\n  HTTP(S) %s\n  SOCKS   %s\n' "$http_url" "$socks_url"
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

# 智能添加到 PATH（自动去重，跳过不存在的目录）
# 用法: path_add /path/to/bin
path_add() {
    local argpath="$1"
    [[ -d "$argpath" ]] || return 0
    case ":${PATH}:" in
        *:"$argpath":*) ;;
        *) export PATH="$argpath:$PATH" ;;
    esac
}
