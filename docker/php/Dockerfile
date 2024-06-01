FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        autoconf \
        libtool \
        bison \
        re2c \
        pkg-config \
        git \
        libfcgi-bin \
        zlib1g-dev \
        libzip-dev \
        libonig-dev \
        libxml2-dev \
        libssl-dev \
        libsqlite3-dev \
        strace \
        procps \
        vim \
        python3 \
        wget \
        gdb

COPY ./gdb/local-gdbinit /root/.local_gdbinit
COPY ./gdb/.gdbinit.d /root/.gdbinit.d
COPY ./php-fpm/php-fpm.conf /root/php-fpm.conf
COPY ./gdb-php-fpm-worker.sh /root/gdb-php-fpm-worker.sh

RUN wget -P ~ https://github.com/cyrus-and/gdb-dashboard/raw/master/.gdbinit \
    && echo "add-auto-load-safe-path /php-src/.gdbinit" >> ~/.gdbinit \
    && echo "source ~/.local_gdbinit" >> ~/.gdbinit

RUN echo 'export PATH=/php-src/php/bin:/php-src/php/sbin:$PATH' >> ~/.bashrc

