FROM python:3.7-slim

# Python Base Image Dockerfile

# uwsgi, adapted from https://github.com/docker-library/python.git
# in file python/3.6/slim/Dockerfile
# here for build perf optimization
RUN set -ex \
    && buildDeps=' \
        gcc \
        libbz2-dev \
        libc6-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libpcre3-dev \
        make \
        tcl-dev \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev \
    ' \
    && deps=' \
        libexpat1 \
    ' \
    && apt-get update && apt-get install -y $buildDeps $deps --no-install-recommends  && rm -rf /var/lib/apt/lists/* \
    && pip install uwsgi \
    && apt-get purge -y --auto-remove $buildDeps \
    && find /usr/local -depth \
    \( \
        \( -type d -a -name test -o -name tests \) \
        -o \
        \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
    \) -exec rm -rf '{}' +

RUN mkdir /var/dock
WORKDIR /var/dock
COPY requirements.txt ./

RUN pip install -r requirements.txt

RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser
USER appuser

COPY --chown=appuser . .
COPY config/known_konfigs/docker_production.py config/current_config.py
RUN ls -lah

WORKDIR common_workdir
ENV PYTHONPATH=..

RUN ls -lah
