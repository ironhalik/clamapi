#!/bin/ash
set -e

if [ "${1}" = "clamd" ]; then
    if [ "${FRESHCLAM_INIT}" = "true" ]; then
        echo "Initializing freshclam"
        freshclam --stdout
    fi
    exec clamd
elif [ "${1}" = "freshclam" ]; then
    exec freshclam --stdout --daemon --foreground --daemon-notify=/etc/clamav/clamd.conf --checks="${FRESHCLAM_CHECKS}"
elif [ "${1}" = "api" ]; then
    exec gunicorn api:app
else
    exec "${@}"
fi
