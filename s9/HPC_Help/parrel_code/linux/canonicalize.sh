canonicalize () {
    # ��׼��·���� "$1" (�������е� .��.. �ͷ������Ӳ�ת���ɾ���·��)
    local path dir d0 d target          # �ֲ�����

    if [ $# -ne 1 ]; then
        echo 1>&2 "Usage: canonicalize pathname"
        return 1                        # ���ط� 0 ��ʾ����
    fi

    path="$1"                           # �������·����
    if test "${path#/}" = "$path"; then path="`pwd`/$path"; fi
                                        # ת�ɾ���·��
    
    # ��һ��ɨ�裺��ȥ��������
    dir=""
    # ���ļ����е�ÿ��Ŀ¼����ѭ�� (Ϊ�����ļ����еĿո񣬽������� '#' ����)
    for d in `echo "$path" | sed -e 's/ /#/g' -e 's/\// /g'`; do
        d="`echo $d|sed -e 's/#/ /g'`"  # �� '#' ��ؿո�
        d0="$dir"                       # ��ǰĿ¼
        dir="$dir/$d"                   # ��һ��Ŀ¼
        while test -h "$dir"; do
            # �滻��������
            target=`/bin/ls -l "$dir" | awk -F' -> ' '{print $2}'`
            if test "${target#/}" != "$target"; then
                dir="$target"           # Ŀ���Ǿ���·����
            else
                dir="$d0/$target"       # Ŀ�������·����
            fi
            d0="${dir%/${dir##*/}}"     # �µĵ�ǰĿ¼
        done
    done
    path="$dir"
    
    # �ڶ���ɨ�裺��ȥ "." �� ".."
    dir=""
    for d in `echo "$path" | sed -e 's/ /#/g' -e 's/\// /g'`; do
        d="`echo $d | sed -e 's/#/ /g'`"
        case "$d" in
            ..) dir="${dir%/[^/]*}" ;;
             .) continue ;;
             *) dir="$dir/$d" ;;
        esac
    done
    path="$dir"                         # path �а������մ�����

    echo $path                          # ��·���� -> stdout
}
