#api: ### `shlog::dump`
#api: [source](__CURFILE__#L__CURLINE__)
#api:
#api: Dump a variable by calling `declare -p`
#api:
shlog::dump () {
    local varname
    for varname in "$@";do
        {
            declare -p "$varname" 2>/dev/null|| echo "$varname="
        } |grep -o "$varname.*" #|sed -e 's,\([( ]\)\[,\1\n\t[,g'
    done
}
