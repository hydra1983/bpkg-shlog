shlog
=====
Easy Logging in the shell

<!-- BEGIN-BANNER -f "slant" -w '```' 'logging bash\n```' shlog -->
```
         __    __           
   _____/ /_  / /___  ____ _
  / ___/ __ \/ / __ \/ __ `/
 (__  ) / / / / /_/ / /_/ / 
/____/_/ /_/_/\____/\__, /  
                   /____/   
logging bash
```

<!-- END-BANNER -->

<!-- BEGIN-MARKDOWN-TOC -->
* [USAGE](#usage)
* [INSTALL](#install)
	* [Requirements](#requirements)
	* [From source - system-wide](#from-source---system-wide)
	* [From source - home directory](#from-source---home-directory)
	* [From source - project specific](#from-source---project-specific)
	* [bpkg bash package manager](#bpkg-bash-package-manager)
* [CONFIGURATION](#configuration)
	* [Log levels](#log-levels)
	* [Configuration files](#configuration-files)
	* [Colors](#colors)
		* [`SHLOG_STYLE_TRACE`](#shlog_style_trace)
		* [`SHLOG_STYLE_DEBUG`](#shlog_style_debug)
		* [`SHLOG_STYLE_INFO`](#shlog_style_info)
		* [`SHLOG_STYLE_WARN`](#shlog_style_warn)
		* [`SHLOG_STYLE_ERROR`](#shlog_style_error)
		* [`SHLOG_STYLE_MODULE`](#shlog_style_module)
		* [`SHLOG_STYLE_LINE`](#shlog_style_line)
		* [`SHLOG_STYLE_DATE`](#shlog_style_date)
		* [`SHLOG_STYLE_RESET`](#shlog_style_reset)
	* [Outputs](#outputs)
		* [`SHLOG_TERM`](#shlog_term)
		* [`SHLOG_FILE`](#shlog_file)
	* [Enabling / Disabling colors](#enabling---disabling-colors)
		* [`SHLOG_TERM_COLORIZE`](#shlog_term_colorize)
		* [`SHLOG_FILE_COLORIZE`](#shlog_file_colorize)
	* [Term Output options](#term-output-options)
		* [`SHLOG_TERM_OUTPUT`](#shlog_term_output)
	* [File Output options](#file-output-options)
		* [`SHLOG_FILE_FILENAME`](#shlog_file_filename)
	* [Formatting Log output](#formatting-log-output)
		* [`SHLOG_DATE_FORMAT`](#shlog_date_format)
		* [`SHLOG_FORMAT`](#shlog_format)
			* [`%level`](#level)
			* [`%date`](#date)
			* [`%module`](#module)
			* [`%line`](#line)
			* [`%msg`](#msg)
	* [Debugging shlog](#debugging-shlog)
		* [`SHLOG_SELFDEBUG`](#shlog_selfdebug)
* [FAQ](#faq)
	* [How to turn off logging?](#how-to-turn-off-logging)
	* [How to debug the logging?](#how-to-debug-the-logging)
	* [How to log to STDOUT instead of STDERR?](#how-to-log-to-stdout-instead-of-stderr)
	* [How to log to a file?](#how-to-log-to-a-file)
	* [How to enable or disable color output?](#how-to-enable-or-disable-color-output)
	* [Logging is slow and `module` is always `shlog`?](#logging-is-slow-and-module-is-always-shlog)
* [API](#api)
	* [`shlog`](#shlog)
	* [`shlog::init`](#shloginit)
	* [`shlog::selfdebug`](#shlogselfdebug)
	* [`shlog::dump`](#shlogdump)
	* [`shlog::pipe`](#shlogpipe)
* [COPYRIGHT](#copyright)

<!-- END-MARKDOWN-TOC -->

## USAGE
<!-- BEGIN-EVAL ./shlog --help | sed 's,^,\t,' -->
	Usage: shlog [-v] [-l LEVEL] [-m MODULE] [-d VARNAME] [-x EXIT_STATUS] <msg>
	
	    Options:
	
	        -h --help               Show this help
	        -l --level LEVEL        Log at this LEVEL [Default: trace]
	        -m --module MODULE      Log as this MODULE [Default: calling script]
	        -d --dump VARNAME       Dump variable VARNAME
	        -x --exit EXIT_STATUS   Log and exit with EXIT_STATUS

<!-- END-EVAL -->

## INSTALL
<!-- BEGIN-INCLUDE doc/INSTALL.md -->
### Requirements

* bash >= 4 (This is a guess but seems likely)

### From source - system-wide

```
git clone https://github.com/kba/shlog
cd shlog
make install
```

### From source - home directory

To install to your home directory, use the `PREFIX` make variable:

```
make install PREFIX=$HOME/.local
```

Make sure you have `PATH="$HOME/.local/bin:$PATH` in your shell
startup script.

### From source - project specific

`shlog` comes pre-built, so you can use it in your project, e.g. by
including the shlog repo as a git submodule:

```sh
cd ~/myproject
git submodule add https://github.com/kba/shlog deps/shlog
```

In your script, add `~myproject/deps/shlog/dist` to your path and
`source "$(which shlog)"`.

### bpkg bash package manager

```
bpkg install 'kba/shlog'
```

<!-- END-INCLUDE -->

## CONFIGURATION
<!-- BEGIN-RENDER src/shlog-init.bash -->
### Log levels

`shlog` knows five levels, from lowest to highest priority:

* trace
* debug
* info
* warn
* error

### Configuration files

`shlog` will look in three places for a configuration file with
environment variables:

* `/etc/default/shlogrc`
* `$HOME/.config/shlog/shlogrc`
* `$PWD/.shlogrc`

Environment variables in any of those files will be sourced in that
order to configure the logging.

### Colors

Defines the colors to use for various part of the log message if
[`SHLOG_USE_STYLES`](#shlog_use_styles) is set for that [output](#shlog-outputs).

#### `SHLOG_STYLE_TRACE`
`SHLOG_STYLE_TRACE`  : `%level`==`trace` : Default: magenta
#### `SHLOG_STYLE_DEBUG`
`SHLOG_STYLE_DEBUG`  : `%level`==`debug` : Default: cyan
#### `SHLOG_STYLE_INFO`
`SHLOG_STYLE_INFO`   : `%level`==`info`  : Default: cyan
#### `SHLOG_STYLE_WARN`
`SHLOG_STYLE_WARN`   : `%level`==`warn`  : Default: yellow
#### `SHLOG_STYLE_ERROR`
`SHLOG_STYLE_ERROR`  : `%level`==`error` : Default: bold red
#### `SHLOG_STYLE_MODULE`
`SHLOG_STYLE_MODULE` : `%module`         : Default: bold
#### `SHLOG_STYLE_LINE`
`SHLOG_STYLE_LINE`   : `%line`           : Default: bold green
#### `SHLOG_STYLE_DATE`
`SHLOG_STYLE_DATE`   : `%date`           : Default: none
#### `SHLOG_STYLE_RESET`
`SHLOG_STYLE_RESET` : (after every style) : Default: `[0m`

### Outputs

Defines the minimum level at which to log to different outputs

#### `SHLOG_TERM`
`SHLOG_TERM`: Minimum level for terminal. Default: `trace`
#### `SHLOG_FILE`
`SHLOG_FILE`: Minimum level for file logging. Default: `off`

### Enabling / Disabling colors

Defines which outputs should use [styles](#shlog_styles).

#### `SHLOG_TERM_COLORIZE`
`SHLOG_TERM_COLORIZE`: Use styles on terminal . Default: `"true"`
#### `SHLOG_FILE_COLORIZE`
`SHLOG_FILE_COLORIZE`: Use styles on file . Default: `"false"`

### Term Output options

#### `SHLOG_TERM_OUTPUT`

Whether to output to `stderr` (the default) or `stdout`.

### File Output options

#### `SHLOG_FILE_FILENAME`
`SHLOG_FILE_FILENAME`: Filename of the file to log to.

Default: basename of `$0` with out extension + `.log` in `/tmp`

### Formatting Log output

#### `SHLOG_DATE_FORMAT`

`strftime(3)` pattern for the `%date` part of a log message, to be
passed to `printf`.

Default: `%(%F %T)T` (i.e. `YYYY-MM-DD HH:MM:SS`)

#### `SHLOG_FORMAT`

`printf`-Pattern for the log message.

Default: `[%level] %date %module:%line - %msg`

Custom patterns:
##### `%level`
`%level`: The [log level](#shlog-levels)
##### `%date`
`%date`: The timestamp of the log message, see [`SHLOG_DATE_FORMAT`](#shlog_date_format)
##### `%module`
`%module`: The calling [module](#-m---module-module)
##### `%line`
`%line`: Line number of the calling script
##### `%msg`
`%msg`: The actual log message

### Debugging shlog

#### `SHLOG_SELFDEBUG`
If set to `"true"`, shlog will output its configuration upon first initialization.

Default: false

<!-- END-RENDER -->

## FAQ
<!-- BEGIN-INCLUDE doc/FAQ.md -->
### How to turn off logging?

Set the `SHLOG_SILENT` variable to a non-zero value to discard all log
messages within that shell:

```sh
SHLOG_SILENT=true some-noisy-script.sh
```

### How to debug the logging?

To debug the logging process itself, set the `SHLOG_SELFDEBUG`
variable to a non zero value:

```sh
SHLOG_SELFDEBUG=true some-command.sh
```

This will make `shlog` output its configuration upon initialization
and also log all the files it sourced.

### How to log to STDOUT instead of STDERR?

Set `SHLOG_TERM_OUTPUT` to `stdout`:

```sh
SHLOG_TERM_OUTPUT=stdout
SHLOG_TERM=debug # or trace, info, warn, error
```

### How to log to a file?

Enable the `file` output in your [configuration file](#configuration-files):

```sh
SHLOG_FILE=trace
SHLOG_FILE_FILENAME=$PWD/myscrip.log
```

`SHLOG_FILE_FILENAME` is optional, will default to a file in /tmp
derived from $0 if not set explicitly

### How to enable or disable color output?

Define `SHLOG_<output>_COLORIZE`. The default is:

```sh
SHLOG_TERM_COLORIZE=true
SHLOG_FILE_COLORIZE=false
```

### Logging is slow and `module` is always `shlog`?

While you can use `shlog` as a command line script, it's much faster
to use it as a shell function.

Make sure you **source** the `shlog` script, otherwise every log
command is spawning a new shell. Compare:

Slow:

```sh
time for i in $(seq 1000); do shlog -l info test; done
# ...
# real  0m4.466s
# user  0m0.164s
# sys   0m0.172s
```

Fast:

```
source "$(which shlog)"
time for i in $(seq 1000); do shlog -l info test; done
# ...
# real  0m0.889s
# user  0m0.408s
# sys   0m0.136s
```

<!-- END-INCLUDE -->

## API
<!-- BEGIN-RENDER -ip '#api: \?' src/shlog.bash -->
### `shlog`
[source](src/shlog.bash#L28)

The logging function

<!-- END-RENDER -->
<!-- BEGIN-RENDER -ip '#api: \?' src/shlog-init.bash -->
### `shlog::init`
[source](src/shlog-init.bash#L4)

(Re-)initialize the logging by reading configuration files and setting up variables.

<!-- END-RENDER -->
<!-- BEGIN-RENDER -ip '#api: \?' src/shlog-selfdebug.bash -->
### `shlog::selfdebug`
[source](src/shlog-selfdebug.bash#L2)

Dump the configuration to STDOUT.

See [`shlog::dump`](#shlog--dump).

<!-- END-RENDER -->
<!-- BEGIN-RENDER -ip '#api: \?' src/shlog-dump.bash -->
### `shlog::dump`
[source](src/shlog-dump.bash#L2)

Dump a variable by calling `declare -p`

<!-- END-RENDER -->
<!-- BEGIN-RENDER -ip '#api: \?' src/shlog-pipe.bash -->
### `shlog::pipe`

Read lines from STDIN and log them.

See [`shlog`](#shlog) for options.

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

<!-- END-INCLUDE -->
