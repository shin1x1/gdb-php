.PHONY: install
install: setup

.PHONY: setup
setup:
	test -d php-src || git clone https://github.com/php/php-src.git --branch=PHP-8.3 php-src

.PHONY: build
build:
	cp -a build-php.sh php-src/
	docker compose run --rm php-fpm sh build-php.sh

.PHONY: gdb-php-fpm
gdb-php-fpm:
	docker compose run --rm php-fpm gdb /php-src/php/sbin/php-fpm

.PHONY: gdb-php
gdb-php:
	docker compose run --rm php-fpm gdb /php-src/php/bin/php

.PHONY: send-request
up:
	docker compose run --rm php-fpm  cgi-fcgi

.PHONY: clean
clean:
	#docker compose run --rm php-fpm make clean
	docker compose down -v
