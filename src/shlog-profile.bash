typeset -Agx SHLOG_PROFILE=()

#api: ### `shlog::profile`
#api: 
#api: Profile the execution time of shell code.
#api: 
#api: * Register a name with the profiler: `shlog::profile "my-feature"`
#api: * Whenever you call `shlog::profile -log "my-feature" [shlog-args...]`
#api:   from now on, a log message with the elapsed time will be output. 
#api:   `[shlog-args...]` are passed on to `shlog`
#api: 
#api: Example:
#api: 
#api: ```sh
#api: shlog::profile 'sleep'
#api: sleep 1.7
#api: shlog::profile -log 'sleep' -l "info"
#api: sleep 0.7
#api: shlog::profile -log 'sleep' -l "debug"
#api: 
#api: # [info ] - Profiled 'sleep': 1705 ms
#api: # [debug] - Profiled 'sleep': 708 ms
#api: ```

shlog::profile () {
    local now elapsed name do_log
    now=$(date +'%s%N')
    while [[ "$1" = -* ]];do
        case "$1" in
            -log) do_log=true ;;
        esac
        shift
    done
    name="$1"; shift;
    if [[ -z "$name" ]];then
        echo "Usage: shlog::profile [-log] <profiler-name> [shlog args...]"
        return
    fi
    if [[ "$do_log" = true ]];then
        # shellcheck disable=SC2004
        if [[ "$SHLOG_PROFILE_PRECISION" = "ns" ]];then
            (( elapsed = now - SHLOG_PROFILE[$name] ))
        else
            (( elapsed = (now - SHLOG_PROFILE[$name]) / 1000000 ))
        fi
        shlog "$@" "Profiled '${name}': ${elapsed} $SHLOG_PROFILE_PRECISION"
    fi
    SHLOG_PROFILE[$name]="$now"
}
