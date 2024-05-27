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
        strace \
        procps \
        vim \
        python3 \
        wget \
        gdb

COPY ./gdb/local-gdbinit /root/.local_gdbinit
COPY ./php-fpm/php-fpm.conf /root/php-fpm.conf
COPY ./gdb-php-fpm-worker.sh /root/gdb-php-fpm-worker.sh

RUN wget -P ~ https://github.com/cyrus-and/gdb-dashboard/raw/master/.gdbinit \
    && echo "add-auto-load-safe-path /php-src/.gdbinit" >> ~/.gdbinit \
    && echo "source ~/.local_gdbinit" >> ~/.gdbinit

RUN echo "export PATH=$PATH:/php-src/php/bin:/php-src/php/sbin" >> ~/.bashrc

