#!/bin/sh

pid=$(ps aux | grep 'php-fpm: pool' | grep -v grep | awk '{print $2}')
gdb -p $pid