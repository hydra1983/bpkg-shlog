shlog::usage () {
    echo "Usage: shlog [-v] [-l LEVEL] [-m MODULE] [-d VARNAME] [-x EXIT_STATUS] <msg>

    Options:

        -h --help               Show this help
        -l --level LEVEL        Log at this LEVEL [Default: trace]
        -m --module MODULE      Log as this MODULE [Default: calling script]
        -d --dump VARNAME       Dump variable VARNAME
        -x --exit EXIT_STATUS   Log and exit with EXIT_STATUS"
}
