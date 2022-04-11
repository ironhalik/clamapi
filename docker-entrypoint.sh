#!/bin/ash -e

if [[ "${1}" == "clamd" ]]; then
    if [ -d "/var/lib/clamav-build/" ] && ! ls /var/lib/clamav/ | grep -q .; then
        echo "Copying images database definitions from image."
        cp -rp /var/lib/clamav-build/* /var/lib/clamav/
    fi
    exec clamd
elif [[ "${1}" == "freshclam" ]]; then
    if [[ "${WAIT_FOR_CLAMD}" == "true" ]]; then
        echo "Waiting for clamd on ${CLAMD_HOST}:${CLAMD_PORT}"
        waitforit -host=${CLAMD_HOST} -port=${CLAMD_PORT} -timeout=300
        echo ${CLAMD_HOST} is up
    fi
    exec freshclam --daemon --foreground --checks="${FRESHCLAM_CHECKS}"
elif [[ "${1}" == "api" ]]; then
    if [[ "${WAIT_FOR_CLAMD}" == "true" ]]; then
        echo "Waiting for clamd on ${CLAMD_HOST}:${CLAMD_PORT}"
        waitforit -host=${CLAMD_HOST} -port=${CLAMD_PORT} -timeout=300
        echo ${CLAMD_HOST} is up
    fi
    exec gunicorn -c gunicorn.py api:app
else
    exec "${@}"
fi
