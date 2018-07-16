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
        clang-5.0 \
        curl \
        git \
        software-properties-common `# Avoids "add-apt-repository: not found"` \
        sqlite3 \
        unzip \
        valgrind && \
        update-alternatives --install /usr/bin/clang clang $(which clang-5.0) 1

# Install libcs50
RUN curl --silent https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt-get install -y libcs50

# Install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs

# Install Python packages
RUN apt-get update && apt-get install -y python3-pip && \
    pip3 install \
        cs50 \
        check50 \
        Flask \
        Flask-Session \
        style50
ENV FLASK_APP="application.py"

# Configure shell
COPY ./etc/profile.d/baseimage.sh /etc/profile.d/

# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu/workspace && \
    chown -R ubuntu:ubuntu /home/ubuntu
USER ubuntu
WORKDIR /home/ubuntu/workspace

# Start with login shell
CMD ["bash", "-l"]
