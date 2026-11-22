#!/bin/bash
# 清理切档后留在 home 里的 full 档文件。
#
# 用法：
#   ./scripts/cleanup-orphans.sh            只打印将删除的路径
#   ./scripts/cleanup-orphans.sh --apply    真删
#
# 需要把 chezmoi 指向别处（验证或临时 destination）时，整套参数塞进 CHEZMOI_ARGS：
#   CHEZMOI_ARGS="--source /repo --destination /tmp/home --config /tmp/cfg.toml" ./scripts/cleanup-orphans.sh
# CHEZMOI_ARGS 按空格切分，所以值里不能有空格；路径由 mktemp 生成时不会有空格。
#
# 哪些路径算 full 档，只认 .chezmoidata.yaml 的 tiers.full.dirs 与 tiers.full.files，
# 脚本里不另写一份清单。

set -euo pipefail

APPLY=0
for arg in "$@"; do
    case "$arg" in
        --apply) APPLY=1 ;;
        -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "未知参数：${arg}（可用：--apply）" >&2; exit 2 ;;
    esac
done

# 不用 mapfile/declare -A/${x^^}：目标环境包含 macOS 自带 bash 3.2
CHEZMOI_OPTS=()
if [[ -n "${CHEZMOI_ARGS:-}" ]]; then
    read -r -a CHEZMOI_OPTS <<<"$CHEZMOI_ARGS"
fi

# 空数组在 bash 3.2 + set -u 下直接展开会报 unbound variable
cz() { chezmoi ${CHEZMOI_OPTS[@]+"${CHEZMOI_OPTS[@]}"} "$@" </dev/null; }

warn() { printf '跳过    %s\n' "$*" >&2; }
err() { printf '错误    %s\n' "$*" >&2; }

if ! command -v sha256sum >/dev/null 2>&1; then
    err "没找到 sha256sum，无法校验文件内容，脚本退出"
    exit 1
fi

T=$(mktemp -d)
trap 'rm -rf "${T:?}"' EXIT

dest=$(cz execute-template '{{ .chezmoi.destDir }}')
if [[ -z "$dest" || ! -d "$dest" ]]; then
    err "destination 目录不存在：${dest:-<空>}"
    exit 1
fi

# managed 会按当前档位算：档位还是 full 时这些路径仍在管理范围内，脚本不会报出任何残留
profile=$(cz execute-template '{{ .profile }}')
echo "当前档位：${profile:-未设置}"

# 判定删除前必须能读到状态，读不到就什么都不动
if ! cz state get-bucket --bucket=entryState >"$T/bucket.json"; then
    err "读取 entryState 失败，脚本退出"
    exit 1
fi

# key 在 get-bucket 输出里固定顶格缩进两格，值是 JSON 字符串
awk -F'"' '/^  "\//{ print $2 }' "$T/bucket.json" | LC_ALL=C sort -u >"$T/tracked"

cz managed --path-style=absolute | LC_ALL=C sort -u >"$T/managed"

LC_ALL=C comm -23 "$T/tracked" "$T/managed" >"$T/orphans"

# allowlist：tiers 里的路径前缀。同时收进物理路径形式，
# 临时 destination 在 macOS 上常是 /var/... 而实际指向 /private/var/...，
# 只留字面形式会让前缀匹配静默落空。
: >"$T/allow"
dest_real=$(cd "$dest" && pwd -P)
cz execute-template '{{ range .tiers.full.dirs }}{{ . }}{{ "\n" }}{{ end }}{{ range .tiers.full.files }}{{ . }}{{ "\n" }}{{ end }}' \
    >"$T/tiers.txt"
while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    [[ "$rel" == */ ]] && rel=${rel%/}
    printf '%s\n' "$dest/$rel" >>"$T/allow"
    if [[ "$dest_real" != "$dest" ]]; then
        printf '%s\n' "$dest_real/$rel" >>"$T/allow"
    fi
done <"$T/tiers.txt"

if [[ ! -s "$T/allow" ]]; then
    err "tiers.full.dirs 与 tiers.full.files 都是空的，没有可清理的路径"
    exit 1
fi

awk -v allowfile="$T/allow" '
    BEGIN { while ((getline line < allowfile) > 0) if (line != "") pre[++n] = line }
    {
        for (i = 1; i <= n; i++) {
            p = pre[i]
            if ($0 == p || substr($0, 1, length(p) + 1) == p "/") { print; next }
        }
    }
' "$T/orphans" >"$T/candidates"

# 先删深路径：父目录 rmdir 要等子项都清掉才可能成功。
# 按 / 的层数排序而不是路径字符长度，同层长短无关。
awk '{ n = split($0, a, "/"); printf "%d\t%s\n", n, $0 }' "$T/candidates" \
    | sort -t "$(printf '\t')" -k1,1nr | cut -f2- >"$T/ordered"

if [[ ! -s "$T/ordered" ]]; then
    echo "没有需要清理的 full 档残留。"
    exit 0
fi

[[ $APPLY -eq 1 ]] || echo "dry-run：以下路径将被删除，加 --apply 执行。"

deleted=0
failed=0
# dry-run 下记录「若真删会移除的路径」：目录要在子项都列进来之后才能判定是否会变空，
# 只按磁盘当前内容判断会把即将变空的目录误报成跳过。
: >"$T/would"

while IFS= read -r p; do
    [[ -z "$p" ]] && continue

    # state get 对不存在的 key 输出空串并退出 0
    meta=$(cz state get --bucket=entryState --key="$p")
    if [[ -z "$meta" ]]; then
        warn "${p}（状态里没有这条记录）"
        continue
    fi
    stype=$(printf '%s\n' "$meta" | sed -n 's/.*"type":[[:space:]]*"\([a-z]*\)".*/\1/p' | head -1)
    stsha=$(printf '%s\n' "$meta" | sed -n 's/.*"contentsSHA256":[[:space:]]*"\([0-9a-f]*\)".*/\1/p' | head -1)

    # 符号链接必须先判：断链时 -e 为假，会掉进「磁盘上已不存在」分支只清状态；
    # 而 sha256sum 对断链返回非零，在 set -e 下会中断整个脚本。
    if [[ -L "$p" ]]; then
        if [[ "$stype" != "symlink" ]]; then
            warn "${p}（磁盘上是符号链接，状态记录类型为 ${stype:-未知}）"
            continue
        fi
        reason="符号链接"
        action="link"
    elif [[ ! -e "$p" ]]; then
        reason="磁盘上已不存在，只清状态"
        action="gone"
    elif [[ -d "$p" ]]; then
        # 记录类型对不上说明用户把文件换成了目录，这种目录不该由脚本动
        if [[ "$stype" != "dir" ]]; then
            warn "${p}（磁盘上是目录，状态记录类型为 ${stype:-未知}）"
            continue
        fi
        # apply 时子项已经先删掉，看磁盘就是删完的样子。dry-run 不会动磁盘，
        # 所以要扣掉「本次计划删除」的直接子项，否则目录会被误报成非空。
        leftovers=""
        while IFS= read -r child; do
            [[ -z "$child" ]] && continue
            if ! grep -Fxq -- "$p/$child" "$T/would"; then
                leftovers=1
                break
            fi
        done < <(ls -A -- "$p" 2>/dev/null)
        if [[ -n "$leftovers" ]]; then
            warn "${p}（目录非空）"
            continue
        fi
        reason="空目录"
        action="dir"
    elif [[ -f "$p" ]]; then
        if [[ "$stype" != "file" ]]; then
            warn "${p}（磁盘上是普通文件，状态记录类型为 ${stype:-未知}）"
            continue
        fi
        if ! actual=$(sha256sum -- "$p" 2>/dev/null); then
            warn "${p}（读取失败，可能是权限问题）"
            continue
        fi
        actual=${actual%% *}
        if [[ -z "$stsha" || "$actual" != "$stsha" ]]; then
            warn "${p}（内容已被修改，保留）"
            continue
        fi
        reason="文件内容与 entryState 一致"
        action="file"
    else
        warn "${p}（既不是普通文件、目录，也不是符号链接）"
        continue
    fi

    if [[ $APPLY -eq 1 ]]; then
        case "$action" in
            dir)
                if ! rmdir -- "$p"; then
                    err "删除失败：$p"
                    failed=$((failed + 1))
                    continue
                fi
                ;;
            # 磁盘上已经没有，rm 也不该被调用；这里只继续往下清状态
            gone) ;;
            *)
                if ! rm -f -- "$p"; then
                    err "删除失败：$p"
                    failed=$((failed + 1))
                    continue
                fi
                ;;
        esac
        if ! cz state delete --bucket=entryState --key="$p" >/dev/null; then
            err "状态清除失败：$p"
            failed=$((failed + 1))
            continue
        fi
        if [[ "$action" == "gone" ]]; then
            printf '已清状态  %s（%s）\n' "$p" "$reason"
        else
            printf '已删除  %s（%s）\n' "$p" "$reason"
        fi
    else
        if [[ "$action" == "gone" ]]; then
            printf '将清状态  %s（%s）\n' "$p" "$reason"
        else
            printf '将删除  %s（%s）\n' "$p" "$reason"
        fi
        printf '%s\n' "$p" >>"$T/would"
    fi
    deleted=$((deleted + 1))
done <"$T/ordered"

if [[ $APPLY -eq 1 ]]; then
    echo "完成：处理 $deleted 条，失败 $failed 条。"
else
    echo "dry-run 结束：共 $deleted 条。"
fi

[[ $failed -eq 0 ]]
