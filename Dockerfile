FROM python:3.12-alpine3.20

RUN apk add --no-cache \
    clamav \
    clamav-libunrar &&\
    pip install --no-cache-dir \
    flask==2.3.3 \
    clamd==1.0.2 \
    gunicorn==22.0.0

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
