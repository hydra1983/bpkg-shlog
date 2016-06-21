#api: ### `shlog::selfdebug`
#api: [source](__CURFILE__#L__CURLINE__)
#api:
#api: Dump the configuration to STDOUT.
#api:
#api: See [`shlog::dump`](#shlog--dump).
#api:
shlog::selfdebug () {
    >&2 echo "Initialized shlog:"
    >&2 shlog::dump \
        SHLOG_LEVELS \
        SHLOG_STYLES \
        SHLOG_USE_STYLES \
        SHLOG_OUTPUTS \
        SHLOG_TERM \
        SHLOG_FILE \
        SHLOG_TERM_COLORIZE \
        SHLOG_FILE_COLORIZE \
        SHLOG_FORMAT \
        SHLOG_DATE_FORMAT
}

