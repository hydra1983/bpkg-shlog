# detect if being sourced and
# export if so else execute
# main function with args
shlog::reload
if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
    export -f shlog shlog::dump
else
    shlog "${@}"
fi
