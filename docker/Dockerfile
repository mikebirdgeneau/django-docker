FROM debian:stable-slim as base

# Configure environment variables:
ENV TZ America/Edmonton
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Copy configuration for apt (package manager) and postfix (email notifications):
COPY docker/apt_preferences /etc/apt/preferences
COPY docker/main.cf /etc/postfix/main.cf

# Install common (base) packages and dependencies:

RUN echo "deb https://deb.debian.org/debian testing main" >> /etc/apt/sources.list && \
    # echo 'Acquire::https::deb.debian.org::Verify-Peer "false";' > /etc/apt/apt.conf.d/99-certs && \ ## Not recommended, but may be needed behind load balancers.
    apt-get update -yq &&  \
    apt-get upgrade -yq && \
    apt-get install -yq --no-install-recommends apt-utils && \
    apt-get install -yq --no-install-recommends locales locales-all csh bash g++ gcc libc-bin \
    libc6 git cron curl rsync procps rsyslog sudo \
    build-essential checkinstall vim wget autofs nfs-common pandoc ghostscript graphviz \
    postgresql-client postgresql-client-common chromium-driver nis default-jre p7zip-full \
    r-base python3 && \
    apt-get install -yq bsd-mailx --no-install-recommends && \
    apt-get install -yq postfix --no-install-recommends && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

FROM base as pythonbuilder

# Set environment variables:
ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1 \
    # pip:
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # poetry:
    POETRY_VERSION=1.1.14 \
    POETRY_NO_INTERACTION=1 \
    POETRY_CACHE_DIR='/var/cache/pypoetry' \
    PATH="$PATH:/root/.local/bin" \
    POETRY_VIRTUALENVS_IN_PROJECT=true

# Copy any local certs (e.g. Load Balancer)
COPY docker/certs/.gitkeep docker/certs/*.crt /usr/local/share/ca-certificates/

# Install packages:
RUN update-ca-certificates && \
    apt-get update && \
    apt-get install -yq -t testing --no-install-recommends && \
    apt-get install -t testing -yq --no-install-recommends libssl-dev libffi-dev libsasl2-dev python3-dev \
    libproj-dev proj-bin libldap2-dev libgeos++-dev libpq-dev graphviz-dev libc6 && \
    rm -rf /var/lib/apt/lists/*

# Install specified version of python:
RUN wget -nv https://www.python.org/ftp/python/3.10.5/Python-3.10.5.tgz -O /opt/Python-3.10.5.tgz && \
    cd /opt && \
    tar -xzf /opt/Python-3.10.5.tgz --one-top-level && \
    cd /opt/Python-3.10.5 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 3
WORKDIR /app

# Install poetry:
RUN python -m pip install --no-cache-dir certifi && \
    python -m pip install --no-cache-dir --upgrade pip "pipx" && \
    pipx install "poetry==$POETRY_VERSION" && \
    pipx ensurepath

# Build python packages / environment:
COPY pyproject.toml poetry.lock /app/
RUN poetry cache clear --all pypi && \
    poetry update && \
    poetry install --no-root && \
    poetry export --dev --without-hashes --no-interaction --no-ansi -f requirements.txt -o /app/requirements.txt

ENTRYPOINT ["/bin/bash"]

FROM base as django

RUN apt-get update -yq && \
    apt-get install -yq python3 --no-install-recommends && \
    apt-get install -t testing -yq libc6 libssl3 libldap-2.5-0 libffi8 && \
    rm -rf /var/lib/apt/lists/*

# Copy files from respective builders:
COPY --from=pythonbuilder /opt/Python-3.10.5/python /usr/local/bin/python3.10
COPY --from=pythonbuilder /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=pythonbuilder /app/.venv /opt/env
COPY --from=pythonbuilder /app/pyproject.toml /app/.poetry/
COPY --from=pythonbuilder /app/poetry.lock /app/.poetry/
COPY --from=pythonbuilder /app/requirements.txt /app/.poetry/

# Copy any local certs (e.g. Load Balancer)
COPY docker/certs/.gitkeep docker/certs/*.crt /usr/local/share/ca-certificates/

WORKDIR /app
RUN update-ca-certificates && \
    update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 3 && \
    echo "VIRTUAL_ENV=/opt/env" >> /app/.env && \
    echo "PATH=/opt/env/bin:$PATH" >> /app/.env

ENV VIRTUAL_ENV /opt/env
ENV PATH $VIRTUAL_ENV/bin:$PATH

COPY app /app

# User settings
RUN useradd --shell /bin/bash -m app && \
chown -R app:app /app

USER app
ENV VIRTUAL_ENV /opt/env
ENV PATH $VIRTUAL_ENV/bin:$PATH
ENV DJANGO_ENV test
WORKDIR /app

ENTRYPOINT ["/bin/bash"]
