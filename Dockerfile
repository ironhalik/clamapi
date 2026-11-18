FROM alpine:3.24

RUN apk add --no-cache \
    python3~=3.14 \
    py3-pip \
    clamav \
    clamav-libunrar &&\
    pip install --no-cache-dir --break-system-packages \
    flask==3.1.3 \
    gunicorn==27.0.1

COPY clamd/ /etc/clamav/
COPY api/ /code/
COPY docker-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/clamav/

WORKDIR /code/

EXPOSE 3310

ENV GUNICORN_WORKERS=2
ENV FRESHCLAM_INIT=true
ENV FRESHCLAM_CHECKS=12

ENTRYPOINT ["docker-entrypoint.sh"]
