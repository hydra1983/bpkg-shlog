#api: ### `shlog::pipe`
#api: 
#api: Read lines from STDIN and log them.
#api:
#api: See [`shlog`](#shlog) for options.
#api:
shlog::pipe () {
    declare -a shlogargs=()
    while [[ "$1" = -* ]];do
        shlogargs+=("$1" "$2")
        shift; shift;
    done
    local line
    while read -r line;do
        shlog "${shlogargs[@]}" "$line"
    done
}
