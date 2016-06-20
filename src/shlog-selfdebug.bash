shlog-selfdebug () {
    >&2 echo "Initialized shlog:"
    >&2 shlog-dump SHLOG_LEVELS \
        SHLOG_STYLES \
        SHLOG_USE_STYLES \
        SHLOG_OUTPUTS \
        SHLOG_FILE \
        SHLOG_FORMAT \
        SHLOG_DATE_FORMAT
}

