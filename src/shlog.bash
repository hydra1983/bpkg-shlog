#!/bin/bash

# BEGIN-INCLUDE LICENSE.header
# The MIT License (MIT)
# 
# Copyright (c) 2016 Konstantin Baierer
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# END-INCLUDE

#api: ### `shlog`
#api: [source](__CURFILE__#L__CURLINE__)
#api:
#api: The logging function
#api:
shlog () {
    if [[ ! -z "$SHLOG_SILENT" ]];then
        return
    fi
    local level msg module
    level="trace"
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
            ## * `-h --help`: Show help
            -h|--help) shlog::usage; return ;;
            ## * `-l --level LEVEL`: Log the message to this level. Default: `trace`
            -l|--level) level=$2; shift ;;
            ## * -m,--module MODULE: Mark the log message as belonging to this module. Default: basename of `$0`
            -m|--module) module="$2"; shift ;;
            ## * -x,--exit EXIT_STATUS: Exit the shell after emitting the log message.
            -x|--exit) exit_status=$2; shift ;;
            ## -d,--dump VARNAME: Dump the definition of `VARNAME` instead of a log message.
            -d|--dump) msg=$(shlog::dump "$2"); shift ;;
            ## * -v,--verbose: Dump the configuration of shlog upon initialization. See
            ##   [`SHLOG_SELFDEBUG`](#shlogselfdebug)
            -v|--verbose) SHLOG_SELFDEBUG="true"; shift ;;
        esac
        shift
    done
    if [[ -z "$1" && -z "$msg" ]];then
        shlog::usage
        exit
    fi
    msg="${msg:-$*}"
    local output
    for output in "${!SHLOG_OUTPUTS[@]}";do
        local out="$SHLOG_FORMAT"
        # shellcheck disable=SC2004
        if [[ "${SHLOG_OUTPUTS[$output]}" = "off" ]];then
            continue
        fi
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
            file*)
                echo -e "$out" >> "$SHLOG_FILE_FILENAME"
                ;;
            term) 
                if [[ "$SHLOG_TERM_OUTPUT" = "stdout" ]];then
                    echo -e "$out"
                else
                    echo -e "$out" >&2
                fi
                ;;
        esac
    done
    if [[ "$exit_status" != "-1" ]];then
        exit "$exit_status"
    fi
}
