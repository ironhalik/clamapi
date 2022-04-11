FROM python:3.8-alpine3.15

RUN apk add --no-cache \
    curl \
    clamav \
    clamav-libunrar &&\
    mkdir -p /run/clamav /var/lib/clamav-build/ &&\
    chown clamav:clamav /run/clamav /var/lib/clamav-build/ &&\
    curl -o /usr/local/bin/waitforit -sSL https://github.com/maxcnunes/waitforit/releases/download/v2.4.1/waitforit-linux_amd64 && \
    chmod +x /usr/local/bin/waitforit &&\
    pip install --no-cache-dir \
    Jinja2==3.0.3 \
    flask==1.1.2 \
    clamd==1.0.2 \
    gunicorn==20.0.4

RUN freshclam --datadir=/var/lib/clamav-build/

COPY clamd/ /etc/clamav/
COPY api/ /code/
COPY docker-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/clamav/

WORKDIR /code/

EXPOSE 3310

ENV CLAMD_HOST=clamd
ENV CLAMD_PORT=3310
ENV WAIT_FOR_CLAMD=true
ENV FRESHCLAM_CHECKS=12

ENTRYPOINT ["docker-entrypoint.sh"]
