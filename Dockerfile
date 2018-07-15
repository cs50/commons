FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

# Avoid dropping man pages
RUN sed --expression '/^\s*path-exclude=\/usr\/share\/doc\/\*\s*$/ s/^#*/#/' --in-place /etc/dpkg/dpkg.cfg.d/excludes && \
    sed --expression '/^\s*path-exclude=\/usr\/share\/man\/\*\s*$/ s/^#*/#/' --in-place /etc/dpkg/dpkg.cfg.d/excludes

# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt-get update && apt-get install -y apt-utils

# Configure environment
RUN apt-get update && apt-get install -y locales && \
    locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LANG "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"
ENV PYTHONDONTWRITEBYTECODE "1"

# Install packages
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y \
        apt-transport-https \
        astyle \
        clang \
        curl \
        git \
        software-properties-common `# Avoids "add-apt-repository: not found"` \
        sqlite3 \
        unzip \
        valgrind

# Install libcs50
RUN curl --silent https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt-get install -y libcs50

# Install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs

# Install Python 3.7
ENV PYENV_ROOT /opt/pyenv
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        libbz2-dev \
        libffi-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        llvm \
        make \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    "$PYENV_ROOT"/bin/pyenv install 2.7.15 && \
    "$PYENV_ROOT"/bin/pyenv install 3.7.0 && \
    "$PYENV_ROOT"/bin/pyenv rehash && \
    "$PYENV_ROOT"/bin/pyenv global 2.7.15 3.7.0 && \
    "$PYENV_ROOT"/shims/pip2 install --upgrade pip==9.0.3 && \
    "$PYENV_ROOT"/shims/pip3 install --upgrade pip==9.0.3 && \
    "$PYENV_ROOT"/shims/pip3 install \
        cs50 \
        check50 \
        Flask \
        Flask-Session \
        style50

# Configure shell
COPY ./etc/profile.d/baseimage.sh /etc/profile.d/

# Ready /opt
RUN mkdir -p /opt/bin /opt/cs50/bin

# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu/workspace && \
    chown -R ubuntu:ubuntu /home/ubuntu
USER ubuntu
WORKDIR /home/ubuntu/workspace

# Start with login shell
CMD ["bash", "-l"]
