#!/bin/sh
set -e

mkdir -p /run/nginx
nginx -g 'daemon off;' &
php-fpm
#php /var/www/core/artisan queue:work
