#!/bin/bash
while true
do
    /usr/local/php/sbin/php-fpm -F -y /usr/local/etc/php-fpm.conf
    sleep 1
done