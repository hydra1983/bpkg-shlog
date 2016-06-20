CSI="\e["

shlog-init () {

    ## ## ENVIRONMENT VARIABLES
    ##
    typeset -gAx \
        SHLOG_LEVELS \
        SHLOG_STYLES \
        SHLOG_OUTPUTS \
        SHLOG_USE_STYLES
    export \
        SHLOG_FILE \
        SHLOG_DATE_FORMAT \
        SHLOG_FORMAT \
        SHLOG_SELFDEBUG \
        SHLOG_INITIALIZED


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
        [reset]="${CSI}0m"
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
    ## #### SHLOG_USE_STYLES_STDOUT
    ##
    ##  `SHLOG_USE_STYLES_STDOUT`     : Use styles on stdout . Default: `"true"`
    ##
    ## #### SHLOG_USE_STYLES_STDERR
    ##
    ##  `SHLOG_USE_STYLES_STDERR` : Use styles on stderr . Default: `"true"`
    ##
    ## #### SHLOG_USE_STYLES_FILE
    ##
    ##  `SHLOG_USE_STYLES_FILE`   : Use styles on file   . Default: `"false"`
    ##
    SHLOG_USE_STYLES=(
        [stdout]="${SHLOG_USE_STYLES_STDOUT:-true}"
        [stderr]="${SHLOG_USE_STYLES_STDERR:-true}"
        [file]="${SHLOG_USE_STYLES_FILE:-false}"
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
        shlog-selfdebug
    fi
    SHLOG_INITIALIZED=true
}


