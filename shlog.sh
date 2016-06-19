#!/bin/bash

# BEGIN-INCLUDE LICENSE.header
# END-INCLUDE

## ## SYNOPSIS
##
##     shlog -l debug "I'm a debug message"
##     -> "[debug] 2016-06-19 23:47:36 shlog.sh:8 - I'm a debug message"
##     SOMEVAR=3
##     shlog -l info -d SOMEVAR
##     -> "[info] 2016-06-19 23:47:36 shlog.sh:10 - SOMEVAR='3'"
##

CSI="\e["
CSI_RESET="${CSI}0m"

typeset -A \
    SHLOG_LEVELS \
    SHLOG_STYLES \
    SHLOG_USE_STYLES \
    SHLOG_OUTPUTS \
    SHLOG_USE_STYLES
export \
    SHLOG_LEVELS \
    SHLOG_STYLES \
    SHLOG_OUTPUTS \
    SHLOG_USE_STYLES \
    SHLOG_FILE \
    SHLOG_SELFDEBUG \
    SHLOG_INITIALIZED

shlog () {
    local level="trace"
    local msg
    local module="${0##*/}"
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
            ## ### -d,--dump VARNAME
            ##
            ## Dump the definition of `VARNAME` instead of a log message.
            ##
            -d|--dump) msg=$(shlog-dump "$2"); shift ;;
            ## ### -v,--verbose
            ##
            ## Dump the configuration of shlog upon initialization. See [`SHLOG_SELFDEBUG`](#shlog-selfdebug)
            ##
            -v|--verbose) SHLOG_SELFDEBUG=true; shift ;;
        esac
        shift
    done
    msg="${msg:-$*}"
    if [[ $SHLOG_INITIALIZED != "true" ]];then
        shlog-init
    fi
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
        if [[ ${SHLOG_USE_STYLES[$output]} = true ]];then
            out=${out//%level/${SHLOG_STYLES[$level]}${levelfmt}${CSI_RESET}}
            out=${out//%module/${SHLOG_STYLES[module]}${module}${CSI_RESET}}
            out=${out//%line/${SHLOG_STYLES[line]}${BASH_LINENO[0]}${CSI_RESET}}
            out=${out//%date/${SHLOG_STYLES[date]}${date}${CSI_RESET}}
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
}

shlog-dump () {
    local varname
    for varname in "$@";do
        {
            declare -p "$varname" 2>/dev/null|| echo "$varname="
        } |grep -o "$varname.*" #|sed -e 's,\([( ]\)\[,\1\n\t[,g'
    done
}

shlog-init () {

    ## ## ENVIRONMENT VARIABLES
    ##

    ## ### SHLOG_LEVELS
    ## 
    ## `shlog` knows five levels, from lowest to highest priority:
    ##
    ## * trace
    ## * debug
    ## * info
    ## * warn
    ## * error
    ##
    SHLOG_LEVELS=(
        [off]=999
        [trace]=0
        [debug]=1
        [info]=2
        [warn]=3
        [error]=4
    )

    ## ### SHLOG_STYLES
    ##
    ## Defines the colors to use for various part of the log message if
    ## [`SHLOG_USE_STYLES`](#shlog_use_styles) is set for that [output](#shlog-outputs).
    ##
    ## #### SHLOG_STYLE_TRACE
    ##
    ## `SHLOG_STYLE_TRACE`  : `%level` (`trace`) . Default: magenta
    ##
    ## #### SHLOG_STYLE_DEBUG
    ##
    ## `SHLOG_STYLE_DEBUG`  : `%level` (`debug`) . Default: cyan
    ##
    ## #### SHLOG_STYLE_INFO
    ##
    ## `SHLOG_STYLE_INFO`   : `%level` (`info`)  . Default: cyan
    ##
    ## #### SHLOG_STYLE_WARN
    ##
    ## `SHLOG_STYLE_WARN`   : `%level` (`warn`)  . Default: yellow
    ##
    ## #### SHLOG_STYLE_ERROR
    ##
    ## `SHLOG_STYLE_ERROR`  : `%level` (`error`) . Default: bold red
    ##
    ## #### SHLOG_STYLE_MODULE
    ##
    ## `SHLOG_STYLE_MODULE` : `%module`          . Default: bold
    ##
    ## #### SHLOG_STYLE_LINE
    ##
    ## `SHLOG_STYLE_LINE`   : `%line`            . Default: bold green
    ##
    ## #### SHLOG_STYLE_DATE
    ##
    ## `SHLOG_STYLE_DATE`   : `%date`            . Default: none
    ##
    SHLOG_STYLES=(
        [trace]="${SHLOG_STYLE_TRACE:-${CSI}35m}"
        [debug]="${SHLOG_STYLE_DEBUG:-${CSI}36m}"
        [info]="${SHLOG_STYLE_INFO:-${CSI}32;1m}"
        [warn]="${SHLOG_STYLE_WARN:-${CSI}33m}"
        [error]="${SHLOG_STYLE_ERROR:-${CSI}31;1m}"
        [module]="${SHLOG_STYLE_MODULE:-${CSI}1m}"
        [line]="${SHLOG_STYLE_LINE:-${CSI}32;1m}"
        [date]="${SHLOG_STYLE_DATE:-}"
    )

    ## ### SHLOG_OUTPUTS
    ##
    ## Defines the minimum level at which to log to different outputs
    ##
    ## #### SHLOG_OUTPUT_STDOUT
    ##
    ## `SHLOG_OUTPUT_STDOUT`: Minimum level for STDOUT. Default: `off`
    ##
    ## #### SHLOG_OUTPUT_STDERR
    ##
    ## `SHLOG_OUTPUT_STDERR`: Minimum level for STDERR. Default: `trace`
    ##
    ## #### SHLOG_OUTPUT_FILE
    ##
    ## `SHLOG_OUTPUT_FILE`: Minimum level for file logging. Default: `off`
    ##
    SHLOG_OUTPUTS=(
        [stdout]="${SHLOG_OUTPUT_STDOUT:-off}"
        [stderr]="${SHLOG_OUTPUT_STDERR:-trace}"
        [file]="${SHLOG_OUTPUT_FILE:-off}"
    )

    ## ### SHLOG_USE_STYLES
    ##
    ## Defines which outputs should use [styles](#shlog_styles).
    ##
    ## #### SHLOG_OUTPUT_STDOUT
    ##
    ##  `SHLOG_OUTPUT_STDOUT`     : Use styles on stdout . Default: `true`
    ##
    ## #### SHLOG_USE_STYLES_STDERR
    ##
    ##  `SHLOG_USE_STYLES_STDERR` : Use styles on stderr . Default: `true`
    ##
    ## #### SHLOG_USE_STYLES_FILE
    ##
    ##  `SHLOG_USE_STYLES_FILE`   : Use styles on file   . Default: `false`
    ##
    SHLOG_USE_STYLES=(
        [stdout]="${SHLOG_USE_STYLES_STDOUT:-true}"
        [stderr]="${SHLOG_USE_STYLES_STDOUT:-true}"
        [file]="${SHLOG_USE_STYLES_STDOUT:-false}"
    )

    ## ### SHLOG_FILE
    ##
    ## Filename of the file to log to, if logging to a file is enabled
    ##
    ## Default: basename of `0` with out extension + `.log` in `/tmp`
    ##
    SHLOG_FILE=${SHLOG_FILE:-/tmp/$(basename "$0"|sed 's/\..*$//').log}

    ## ### SHLOG_DATE_FORMAT
    ##
    ## `strftime(3)` pattern for the `%date` part of a log message, to be
    ## passed to `printf`.
    ##
    ## Default: `%(%F %T)T` (i.e. `YYYY-MM-DD HH:MM:SS`)
    ##
    SHLOG_DATE_FORMAT="${SHLOG_DATE_FORMAT:-%(%F %T)T}"

    ## ### SHLOG_FORMAT
    ##
    ## `printf`-Pattern for the log message.
    ##
    ## Custom patterns:
    ##
    ## #### %level
    ##
    ## `%level`: The [log level](#shlog-levels)
    ##
    ## #### %date
    ##
    ## `%date`: The timestamp of the log message, see [`SHLOG_DATE_FORMAT`](#shlog_date_format)
    ##
    ## #### %module
    ##
    ## `%module`: The calling [module](#-m---module-module)
    ##
    ## #### %line
    ##
    ## `%line`: Line number of the calling script
    ##
    ## #### %msg
    ##
    ## `%msg`: The actual log message
    ##
    ## Default: `[%level] %date %module:%line - %msg`
    ##
    SHLOG_FORMAT="${SHLOG_FORMAT:-[%level] %date %module:%line - %msg}"

    ## ### SHLOG_SELFDEBUG
    ##
    ## If set to `"true"`, shlog will output its configuration upon first initialization.
    ##
    ## Default: false
    ##
    if [[ "$SHLOG_SELFDEBUG" = "true" ]];then
        >&2 echo "Initialized shlog:"
        >&2 shlog-dump SHLOG_LEVELS \
            SHLOG_STYLES \
            SHLOG_USE_STYLES \
            SHLOG_OUTPUTS \
            SHLOG_FILE \
            SHLOG_FORMAT \
            SHLOG_DATE_FORMAT
    fi
    SHLOG_INITIALIZED=true
}

# detect if being sourced and
# export if so else execute
# main function with args
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  export -f shlog shlog-dump
else
  shlog "${@}"
fi
