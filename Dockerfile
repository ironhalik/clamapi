FROM python:3.10-alpine3.18

RUN apk add --no-cache \
    curl \
    clamav \
    clamav-libunrar &&\
    curl -o /usr/local/bin/waitforit -sSL https://github.com/maxcnunes/waitforit/releases/download/v2.4.1/waitforit-linux_amd64 && \
    chmod +x /usr/local/bin/waitforit &&\
    pip install --no-cache-dir \
    flask==2.1.1 \
    clamd==1.0.2 \
    gunicorn==20.0.4

COPY clamd/ /etc/clamav/
COPY api/ /code/
COPY docker-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/clamav/

WORKDIR /code/

EXPOSE 3310

ENTRYPOINT ["docker-entrypoint.sh"]
