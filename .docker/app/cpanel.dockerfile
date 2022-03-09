FROM php:8.0-fpm-alpine

ARG SERVER_ENVIRONMENT

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/community" >> /etc/apk/repositories

# fix work iconv library with alpine
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Add Build Dependencies
RUN apk update && apk add --no-cache  \
    libzip-dev \
    libmcrypt-dev \
    libjpeg-turbo-dev \
    libjpeg-turbo \
    jpeg-dev \
    libpng-dev \
    libxml2-dev \
    bzip2-dev \
    libwebp-dev \
    zip \
    bash \
    nginx \
    jpegoptim \
    pngquant \
    optipng \
    icu-dev \
    freetype-dev \
    zlib-dev \
    curl-dev \
    imap-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-configure imap

# Configure & Install Extension
RUN docker-php-ext-configure \
    opcache --enable-opcache &&\
    docker-php-ext-configure zip && \
    docker-php-ext-install -j "$(nproc)" \
    opcache \
    mysqli \
    pdo \
    pdo_mysql \
    json \
    intl \
    gd \
    xml \
    bz2 \
    bcmath \
    zip

# Add Composer
RUN curl -sS https://getcomposer.org/installer | \
php -- --install-dir=/usr/bin/ --filename=composer --version=2.0.6
#RUN composer install  --no-interaction --optimize-autoloader --no-dev --prefer-dist

COPY nginx/cpanel.conf /etc/nginx/conf.d/default.conf
COPY opcache.ini $PHP_INI_DIR/conf.d/
COPY php.ini $PHP_INI_DIR/conf.d/

# Remove Build Dependencies
#RUN apk del -f .build-deps

# Setup Working Dir
WORKDIR /var/www/app

COPY cpanel-start.sh /usr/local/bin
RUN chmod +x /usr/local/bin/cpanel-start.sh

ENTRYPOINT ["/usr/local/bin/cpanel-start.sh"]