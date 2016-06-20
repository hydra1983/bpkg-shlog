shlog-dump () {
    local varname
    for varname in "$@";do
        {
            declare -p "$varname" 2>/dev/null|| echo "$varname="
        } |grep -o "$varname.*" #|sed -e 's,\([( ]\)\[,\1\n\t[,g'
    done
}
