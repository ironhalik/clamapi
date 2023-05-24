#!/bin/ash
set -e

if [ "${1}" == "clamd" ]; then
    if [ "${FRESHCLAM_INIT:-true}" == "true" ]; then
        echo "Initializing freshclam"
        freshclam --stdout
    fi
    exec clamd
elif [ "${1}" == "freshclam" ]; then
    if [ "${WAIT_FOR_CLAMD:-true}" == "true" ]; then
        echo "Waiting for clamd on ${CLAMD_HOST:-clamd}:${CLAMD_PORT:-3310}"
        waitforit -host="${CLAMD_HOST:-clamd}" -port="${CLAMD_PORT:-3310}" -timeout=300
        echo "${CLAMD_HOST:-clamd} is up"
    fi
    exec freshclam --stdout --daemon --foreground --daemon-notify=/etc/clamav/clamd.conf --checks="${FRESHCLAM_CHECKS:-12}"
elif [ "${1}" == "api" ]; then
    if [ "${WAIT_FOR_CLAMD:-true}" == "true" ]; then
        echo "Waiting for clamd on ${CLAMD_HOST:-clamd}:${CLAMD_PORT:-3310}"
        waitforit -host="${CLAMD_HOST:-clamd}" -port="${CLAMD_PORT:-3310}" -timeout=300
        echo "${CLAMD_HOST:-clamd} is up"
    fi
    exec gunicorn api:app
else
    exec "${@}"
fi
