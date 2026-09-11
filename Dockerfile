FROM alpine:3.24

RUN apk add --no-cache \
    python3~=3.14 \
    py3-pip \
    clamav \
    clamav-libunrar \
    # CVE-2026-14456
    'libcrypto3>=3.5.8-r0' \
    'libssl3>=3.5.8-r0' \
    # CVE-2026-53612, CVE-2026-53613...
    'libuuid>=2.42.3-r1' \
    # CVE-2024-6197 \
    'libcurl>=8.9.0-r0' &&\
    pip install --no-cache-dir --break-system-packages \
    flask==2.3.3 \
    clamd==1.0.2 \
    gunicorn==22.0.0 \
    'msgpack>=1.2.1' \
    'setuptools>=78.1.1'

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
