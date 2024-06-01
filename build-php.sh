#!/bin/bash

set -e

cd /php-src

test -d php && rm -rf php
mkdir php

test -f Makefile && make clean

./buildconf
./configure --prefix=/php-src/php ${CONFIGURE_OPTIONS}
make -j $(grep -c processor /proc/cpuinfo)
make install
cp -a ~/php-fpm.conf /php-src/php/etc/php-fpm.conf