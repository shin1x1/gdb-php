cd /php-src

test -d php && rm -rf php
mkdir php

./buildconf
./configure --prefix=/php-src/php --disable-all --disable-cgi --disable-phpdbg --enable-fpm --enable-debug --enable-opcache
make
make install
cp -a ~/php-fpm.conf /php-src/php/etc/php-fpm.conf