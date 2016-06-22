CSI="\e["

#api: ### `shlog::reload`
#api: [source](__CURFILE__#L__CURLINE__)
#api:
#api: (Re-)initialize the logging by reading configuration files and setting up variables.
#api:
shlog::reload () {

    typeset -gA \
        SHLOG_LEVELS \
        SHLOG_STYLES \
        SHLOG_OUTPUTS \
        SHLOG_USE_STYLES
    export \
        SHLOG_LEVELS \
        SHLOG_STYLES \
        SHLOG_OUTPUTS \
        SHLOG_USE_STYLES \
        SHLOG_DATE_FORMAT \
        SHLOG_TERM_OUTPUT \
        SHLOG_FORMAT \
        SHLOG_FILE_FILENAME \
        SHLOG_SELFDEBUG \
        SHLOG_INITIALIZED


    ## ### Log levels
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

    ## ### Configuration files
    ## 
    ## `shlog` will look in three places for a configuration file with
    ## environment variables:
    ## 
    ## * `/etc/default/shlogrc`
    ## * `$HOME/.config/shlog/shlogrc`
    ## * `$PWD/.shlogrc`
    ## 
    ## Environment variables in any of those files will be sourced in that
    ## order to configure the logging.
    ##
    for conf in /etc/default/shlogrc $HOME/.config/shlog/shlogrc ${PWD}/.shlogrc;do
        if [[ -e "$conf" ]];then
            source "$conf"
            if [[ ! -z "$SHLOG_SELFDEBUG" ]];then
                shlog -m shlog -l info "Sourced '$conf'"
            fi
        fi
    done

    ## ### Colors
    ##
    ## Defines the colors to use for various part of the log message if
    ## [`SHLOG_USE_STYLES`](#shlog_use_styles) is set for that [output](#shlog-outputs).
    ##
    ## #### `SHLOG_STYLE_TRACE`
    ## `SHLOG_STYLE_TRACE`  : `%level`==`trace` : Default: magenta
    ## #### `SHLOG_STYLE_DEBUG`
    ## `SHLOG_STYLE_DEBUG`  : `%level`==`debug` : Default: cyan
    ## #### `SHLOG_STYLE_INFO`
    ## `SHLOG_STYLE_INFO`   : `%level`==`info`  : Default: cyan
    ## #### `SHLOG_STYLE_WARN`
    ## `SHLOG_STYLE_WARN`   : `%level`==`warn`  : Default: yellow
    ## #### `SHLOG_STYLE_ERROR`
    ## `SHLOG_STYLE_ERROR`  : `%level`==`error` : Default: bold red
    ## #### `SHLOG_STYLE_MODULE`
    ## `SHLOG_STYLE_MODULE` : `%module`         : Default: bold
    ## #### `SHLOG_STYLE_LINE`
    ## `SHLOG_STYLE_LINE`   : `%line`           : Default: bold green
    ## #### `SHLOG_STYLE_DATE`
    ## `SHLOG_STYLE_DATE`   : `%date`           : Default: none
    ## #### `SHLOG_STYLE_RESET`
    ## `SHLOG_STYLE_RESET` : (after every style) : Default: `\e[0m`
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

    ## ### Outputs
    ##
    ## Defines the minimum level at which to log to different outputs
    ##
    ## #### `SHLOG_TERM`
    ## `SHLOG_TERM`: Minimum level for terminal. Default: `trace`
    ## #### `SHLOG_FILE`
    ## `SHLOG_FILE`: Minimum level for file logging. Default: `off`
    ## 
    SHLOG_OUTPUTS=(
        [term]="${SHLOG_TERM:-trace}"
        [file]="${SHLOG_FILE:-off}"
    )

    ## ### Enabling / Disabling colors
    ##
    ## Defines which outputs should use [styles](#shlog_styles).
    ## 
    ## #### `SHLOG_TERM_COLORIZE`
    ## `SHLOG_TERM_COLORIZE`: Use styles on terminal . Default: `"true"`
    ## #### `SHLOG_FILE_COLORIZE`
    ## `SHLOG_FILE_COLORIZE`: Use styles on file . Default: `"false"`
    ## 
    SHLOG_USE_STYLES=(
        [term]="${SHLOG_TERM_COLORIZE:-true}"
        [file]="${SHLOG_FILE_COLORIZE:-false}"
    )

    ## ### Term Output options
    ##
    ## #### `SHLOG_TERM_OUTPUT`
    ##
    ## Whether to output to `stderr` (the default) or `stdout`.
    ##
    SHLOG_TERM_OUTPUT="${SHLOG_TERM_OUTPUT:-stderr}"

    ## ### File Output options
    ##
    ## #### `SHLOG_FILE_FILENAME`
    ## `SHLOG_FILE_FILENAME`: Filename of the file to log to.
    ##
    ## Default: basename of `$0` with out extension + `.log` in `/tmp`
    ##
    SHLOG_FILE_FILENAME=${SHLOG_FILE_FILENAME:-/tmp/$(basename "$0"|sed 's/\..*$//').log}

    ## ### Formatting Log output
    ##
    ## #### `SHLOG_DATE_FORMAT`
    ##
    ## `SHLOG_DATE_FORMAT`:
    ## `strftime(3)` pattern for the `%date` part of a log message, to be
    ## passed to `printf`.
    ##
    ## Default: `%(%F %T)T` (i.e. `YYYY-MM-DD HH:MM:SS`)
    ##
    SHLOG_DATE_FORMAT="${SHLOG_DATE_FORMAT:-%(%F %T)T}"

    ## #### `SHLOG_PROFILE_PRECISION`
    ##
    ## `SHLOG_PROFILE_PRECISION`:
    ## The granularity with which [`shlog::profile`](#shlogprofile) will
    ## print the elapsed time. Can be `ns` for nano-second precision or
    ## `ms` for millisecond precision (the default).
    ##
    SHLOG_PROFILE_PRECISION=${SHLOG_PROFILE_PRECISION:-ms}

    ## #### `SHLOG_FORMAT`
    ##
    ## `SHLOG_FORMAT`: `printf`-Pattern for the log message.
    ##
    ## Default: `[%level] %date %module:%line - %msg`
    ##
    ## Custom patterns:
    ## ##### `%level`
    ## `%level`: The [log level](#shlog-levels)
    ## ##### `%date`
    ## `%date`: The timestamp of the log message, see [`SHLOG_DATE_FORMAT`](#shlog_date_format)
    ## ##### `%module`
    ## `%module`: The calling [module](#-m---module-module)
    ## ##### `%line`
    ## `%line`: Line number of the calling script
    ## ##### `%msg`
    ## `%msg`: The actual log message
    ##
    SHLOG_FORMAT="${SHLOG_FORMAT:-[%level] %date %module:%line - %msg}"

    ## ### Debugging shlog
    ##
    ## #### `SHLOG_SELFDEBUG`
    ## `SHLOG_SELFDEBUG`: If set to `"true"`, shlog will output its configuration upon 
    ##  first initialization.
    ##
    ## Default: false
    ##
    if [[ "$SHLOG_SELFDEBUG" = "true" ]];then
        shlog::selfdebug
    fi

    SHLOG_INITIALIZED=true
}
