shlog
=====
Easy Logging in the shell

<!-- BEGIN-MARKDOWN-TOC -->
* [INSTALL](#install)
	* [Requirements](#requirements)
	* [From source](#from-source)
* [SYNOPSIS](#synopsis)
* [OPTIONS](#options)
	* [-l,--level LEVEL](#-l--level-level)
	* [-m,--module MODULE](#-m--module-module)
	* [-d,--dump VARNAME](#-d--dump-varname)
	* [-v,--verbose](#-v--verbose)
* [ENVIRONMENT VARIABLES](#environment-variables)
	* [SHLOG_LEVELS](#shlog_levels)
	* [SHLOG_STYLES](#shlog_styles)
		* [SHLOG_STYLE_TRACE](#shlog_style_trace)
		* [SHLOG_STYLE_DEBUG](#shlog_style_debug)
		* [SHLOG_STYLE_INFO](#shlog_style_info)
		* [SHLOG_STYLE_WARN](#shlog_style_warn)
		* [SHLOG_STYLE_ERROR](#shlog_style_error)
		* [SHLOG_STYLE_MODULE](#shlog_style_module)
		* [SHLOG_STYLE_LINE](#shlog_style_line)
		* [SHLOG_STYLE_DATE](#shlog_style_date)
	* [SHLOG_OUTPUTS](#shlog_outputs)
		* [SHLOG_OUTPUT_STDOUT](#shlog_output_stdout)
		* [SHLOG_OUTPUT_STDERR](#shlog_output_stderr)
		* [SHLOG_OUTPUT_FILE](#shlog_output_file)
	* [SHLOG_USE_STYLES](#shlog_use_styles)
		* [SHLOG_OUTPUT_STDOUT](#shlog_output_stdout-1)
		* [SHLOG_USE_STYLES_STDERR](#shlog_use_styles_stderr)
		* [SHLOG_USE_STYLES_FILE](#shlog_use_styles_file)
	* [SHLOG_FILE](#shlog_file)
	* [SHLOG_DATE_FORMAT](#shlog_date_format)
	* [SHLOG_FORMAT](#shlog_format)
		* [%level](#level)
		* [%date](#date)
		* [%module](#module)
		* [%line](#line)
		* [%msg](#msg)
	* [SHLOG_SELFDEBUG](#shlog_selfdebug)
* [COPYRIGHT](#copyright)

<!-- END-MARKDOWN-TOC -->

## INSTALL

### Requirements

* `bash`

### From source

```
git clone https://github.com/kba/shlog
cd shlog
make install
```

To install to your home directory, use the `PREFIX` make variable:

```
make install PREFIX=$HOME/.local
```

<!-- BEGIN-RENDER shlog.sh -->
## SYNOPSIS

    shlog -l debug "I'm a debug message"
    -> "[debug] 2016-06-19 23:47:36 shlog.sh:8 - I'm a debug message"
    SOMEVAR=3
    shlog -l info -d SOMEVAR
    -> "[info] 2016-06-19 23:47:36 shlog.sh:10 - SOMEVAR='3'"

## OPTIONS
### -l,--level LEVEL

Log the message to this level. Default: `trace`

### -m,--module MODULE

Mark the log message as belonging to this module. Default: basename of `$0`

### -d,--dump VARNAME

Dump the definition of `VARNAME` instead of a log message.

### -v,--verbose

Dump the configuration of shlog upon initialization. See [`SHLOG_SELFDEBUG`](#shlog-selfdebug)

## ENVIRONMENT VARIABLES

### SHLOG_LEVELS

`shlog` knows five levels, from lowest to highest priority:

* trace
* debug
* info
* warn
* error

### SHLOG_STYLES

Defines the colors to use for various part of the log message if
[`SHLOG_USE_STYLES`](#shlog_use_styles) is set for that [output](#shlog-outputs).

#### SHLOG_STYLE_TRACE

`SHLOG_STYLE_TRACE`  : `%level` (`trace`) . Default: magenta

#### SHLOG_STYLE_DEBUG

`SHLOG_STYLE_DEBUG`  : `%level` (`debug`) . Default: cyan

#### SHLOG_STYLE_INFO

`SHLOG_STYLE_INFO`   : `%level` (`info`)  . Default: cyan

#### SHLOG_STYLE_WARN

`SHLOG_STYLE_WARN`   : `%level` (`warn`)  . Default: yellow

#### SHLOG_STYLE_ERROR

`SHLOG_STYLE_ERROR`  : `%level` (`error`) . Default: bold red

#### SHLOG_STYLE_MODULE

`SHLOG_STYLE_MODULE` : `%module`          . Default: bold

#### SHLOG_STYLE_LINE

`SHLOG_STYLE_LINE`   : `%line`            . Default: bold green

#### SHLOG_STYLE_DATE

`SHLOG_STYLE_DATE`   : `%date`            . Default: none

### SHLOG_OUTPUTS

Defines the minimum level at which to log to different outputs

#### SHLOG_OUTPUT_STDOUT

`SHLOG_OUTPUT_STDOUT`: Minimum level for STDOUT. Default: `off`

#### SHLOG_OUTPUT_STDERR

`SHLOG_OUTPUT_STDERR`: Minimum level for STDERR. Default: `trace`

#### SHLOG_OUTPUT_FILE

`SHLOG_OUTPUT_FILE`: Minimum level for file logging. Default: `off`

### SHLOG_USE_STYLES

Defines which outputs should use [styles](#shlog_styles).

#### SHLOG_OUTPUT_STDOUT

 `SHLOG_OUTPUT_STDOUT`     : Use styles on stdout . Default: `true`

#### SHLOG_USE_STYLES_STDERR

 `SHLOG_USE_STYLES_STDERR` : Use styles on stderr . Default: `true`

#### SHLOG_USE_STYLES_FILE

 `SHLOG_USE_STYLES_FILE`   : Use styles on file   . Default: `false`

### SHLOG_FILE

Filename of the file to log to, if logging to a file is enabled

Default: basename of `0` with out extension + `.log` in `/tmp`

### SHLOG_DATE_FORMAT

`strftime(3)` pattern for the `%date` part of a log message, to be
passed to `printf`.

Default: `%(%F %T)T` (i.e. `YYYY-MM-DD HH:MM:SS`)

### SHLOG_FORMAT

`printf`-Pattern for the log message.

Custom patterns:

#### %level

`%level`: The [log level](#shlog-levels)

#### %date

`%date`: The timestamp of the log message, see [`SHLOG_DATE_FORMAT`](#shlog_date_format)

#### %module

`%module`: The calling [module](#-m---module-module)

#### %line

`%line`: Line number of the calling script

#### %msg

`%msg`: The actual log message

Default: `[%level] %date %module:%line - %msg`

### SHLOG_SELFDEBUG

If set to `"true"`, shlog will output its configuration upon first initialization.

Default: false

<!-- END-RENDER -->

## COPYRIGHT
<!-- BEGIN-INCLUDE LICENSE -->
The MIT License (MIT)

Copyright (c) 2016 Konstantin Baierer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



