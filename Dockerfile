FROM php:7.3-fpm

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    net-tools \
    nmap \
    vim \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    libzip-dev \
    curl \
    libmemcached-dev \
    zlib1g-dev \
    libicu-dev \
    g++ \
    libc-client-dev \
    libkrb5-dev \
    && pecl install memcached-3.1.5 

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Config locale
RUN locale-gen id_ID && \
    locale-gen id_ID.UTF-8 && \
    dpkg-reconfigure locales
ENV LANG=id_ID.UTF-8
ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY ./default_locale /etc/default/locale

# configure extensions
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# Install extensions
RUN docker-php-ext-install pdo_mysql bcmath mysqli mbstring exif pcntl opcache intl imap gd zip

# Enable extensions
RUN docker-php-ext-enable memcached

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy ini file
COPY ./local.ini /usr/local/etc/php/conf.d/
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www


# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]