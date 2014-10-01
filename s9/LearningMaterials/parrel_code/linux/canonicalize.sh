canonicalize () {
    # 标准化路径名 "$1" (消除其中的 .，.. 和符号链接并转换成绝对路径)
    local path dir d0 d target          # 局部变量

    if [ $# -ne 1 ]; then
        echo 1>&2 "Usage: canonicalize pathname"
        return 1                        # 返回非 0 表示错误
    fi

    path="$1"                           # 待处理的路径名
    if test "${path#/}" = "$path"; then path="`pwd`/$path"; fi
                                        # 转成绝对路径
    
    # 第一遍扫描：消去符号链接
    dir=""
    # 对文件名中的每级目录依次循环 (为处理文件名中的空格，将它们用 '#' 代替)
    for d in `echo "$path" | sed -e 's/ /#/g' -e 's/\// /g'`; do
        d="`echo $d|sed -e 's/#/ /g'`"  # 将 '#' 变回空格
        d0="$dir"                       # 当前目录
        dir="$dir/$d"                   # 下一层目录
        while test -h "$dir"; do
            # 替换符号链接
            target=`/bin/ls -l "$dir" | awk -F' -> ' '{print $2}'`
            if test "${target#/}" != "$target"; then
                dir="$target"           # 目标是绝对路径名
            else
                dir="$d0/$target"       # 目标是相对路径名
            fi
            d0="${dir%/${dir##*/}}"     # 新的当前目录
        done
    done
    path="$dir"
    
    # 第二遍扫描：消去 "." 和 ".."
    dir=""
    for d in `echo "$path" | sed -e 's/ /#/g' -e 's/\// /g'`; do
        d="`echo $d | sed -e 's/#/ /g'`"
        case "$d" in
            ..) dir="${dir%/[^/]*}" ;;
             .) continue ;;
             *) dir="$dir/$d" ;;
        esac
    done
    path="$dir"                         # path 中包含最终处理结果

    echo $path                          # 新路径名 -> stdout
}
