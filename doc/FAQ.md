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
