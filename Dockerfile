FROM php:8.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    unzip \
  && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install -j"$(nproc)" \
    curl \
    gd \
    intl \
    mbstring \
    mysqli \
    opcache \
    pdo_mysql \
    xml \
    zip \
  && a2enmod rewrite headers expires access_compat \
  && rm -rf /var/lib/apt/lists/*

COPY docker/php.ini /usr/local/etc/php/conf.d/ojs.ini
COPY docker/apache-ojs.conf /etc/apache2/sites-available/000-default.conf
COPY docker/configure-ojs.php /usr/local/bin/configure-ojs.php
COPY docker/entrypoint.sh /usr/local/bin/ojs-entrypoint.sh
RUN chmod +x /usr/local/bin/ojs-entrypoint.sh

WORKDIR /var/www/html
COPY . /var/www/html

RUN mkdir -p /var/www/files_dir /var/www/html/cache/t_compile /var/www/html/cache/t_cache /var/www/html/cache/_db \
  && chown -R www-data:www-data /var/www/files_dir /var/www/html/cache /var/www/html/public

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/ojs-entrypoint.sh"]
