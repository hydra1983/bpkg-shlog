shlog () {
    if [[ ! -z "$SHLOG_SILENT" ]];then
        return
    fi
    local level="trace"
    local msg
    local module
    if [[ "${BASH_SOURCE[0]}" != "$0" ]];then
        module="${BASH_SOURCE[1]}"
    else
        module="$0"
    fi
    module=${module##*/}
    module=${module%%.%}
    local exit_status=-1
    while [[ "$1" = -* ]];do
        case "$1" in
            ## ## OPTIONS

            ## ### -l,--level LEVEL
            ##
            ## Log the message to this level. Default: `trace`
            ##
            -l|--level) level=$2; shift ;;
            ## ### -m,--module MODULE
            ##
            ## Mark the log message as belonging to this module. Default: basename of `$0`
            ##
            -m|--module) module="$2"; shift ;;
            ## ### -x,--exit EXIT_STATUS
            ##
            ## Exit the shell after emitting the log message.
            ##
            -x|--exit) exit_status=$2; shift ;;
            ## ### -d,--dump VARNAME
            ##
            ## Dump the definition of `VARNAME` instead of a log message.
            ##
            -d|--dump) msg=$(shlog-dump "$2"); shift ;;
            ## ### -v,--verbose
            ##
            ## Dump the configuration of shlog upon initialization. See [`SHLOG_SELFDEBUG`](#shlog-selfdebug)
            ##
            -v|--verbose) SHLOG_SELFDEBUG="true"; shift ;;
        esac
        shift
    done
    msg="${msg:-$*}"
    local output
    for output in "${!SHLOG_OUTPUTS[@]}";do
        local out="$SHLOG_FORMAT"
        # shellcheck disable=SC2004
        output_level="${SHLOG_LEVELS[${SHLOG_OUTPUTS[$output]}]}"
        msg_level="${SHLOG_LEVELS[$level]}"
        if (( output_level > msg_level ));then
            continue
        fi
        # shellcheck disable=2059
        local date=$(printf "$SHLOG_DATE_FORMAT")
        printf -v levelfmt "%-5s" "$level"
        if [[ "${SHLOG_USE_STYLES[$output]}" = "true" ]];then
            out=${out//%level/${SHLOG_STYLES[$level]}${levelfmt}${SHLOG_STYLES[reset]}}
            out=${out//%module/${SHLOG_STYLES[module]}${module}${SHLOG_STYLES[reset]}}
            out=${out//%line/${SHLOG_STYLES[line]}${BASH_LINENO[0]}${SHLOG_STYLES[reset]}}
            out=${out//%date/${SHLOG_STYLES[date]}${date}${SHLOG_STYLES[reset]}}
        else
            out=${out//%level/$levelfmt}
            out=${out//%module/$module}
            out=${out//%line/${BASH_LINENO[0]}}
            out=${out//%date/$date}
        fi
        out=${out//%msg/$msg}
        # shellcheck disable=2059
        case "$output" in
            stdout) echo -e "$out" ;;
            stderr) echo -e "$out" >&2 ;;
            file) echo -e "$out" >> "$SHLOG_FILE" ;;
        esac
    done
    if [[ "$exit_status" != "-1" ]];then
        exit "$exit_status"
    fi
}


