# ignore error if .env file does not exists
-include .env

.PHONY: install
install:
	test -f .env || cp -a .env.example .env
	make setup # re-include .env

.PHONY: setup
setup:
	test -d php-src || git clone https://github.com/php/php-src.git --branch=${PHP_BRANCH} php-src
	test -f php-src/php/bin/php || make build

.PHONY: build
build:
	cp -a build-php.sh php-src/
	docker compose run --rm php-fpm sh build-php.sh

.PHONY: gdb-php-fpm
gdb-php-fpm:
	docker compose run --rm php-fpm gdb /php-src/php/sbin/php-fpm

.PHONY: up
up:
	docker compose up -d

.PHONY: gdb-php-fpm-worker
gdb-php-fpm-worker:
	docker compose exec php-fpm /root/gdb-php-fpm-worker.sh

.PHONY: send-fcgi
send-fcgi:
	docker compose exec -e SCRIPT_FILENAME=/app/index.php -e REQUEST_METHOD=GET php-fpm cgi-fcgi -bind -connect 127.0.0.1:9000

.PHONY: gdb-php
gdb-php:
	docker compose run --rm php-fpm gdb /php-src/php/bin/php

.PHONY: dump-opcode
dump-opcode:
	docker compose run --rm php-fpm /php-src/php/bin/php -d zend_extension=opcache.so -d opcache.enable_cli=1 -d opcache.opt_debug_level=0x10000 /app/index.php

.PHONY: clean
clean:
	#docker compose run --rm php-fpm make clean
	docker compose down -v
