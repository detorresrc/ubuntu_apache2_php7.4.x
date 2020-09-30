FROM ubuntu:bionic
MAINTAINER Rommel de Torres <detorresrc@gmail.com>

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
    build-essential \
    wget \
    libaprutil1-dev \
    libpcre3-dev \
    liblua5.3-dev \
    libssl-dev \
    libz-dev \
    libmemcached-dev \
    autoconf \
    unzip \
    libxml2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libxpm-dev \
    libmysqlclient-dev \
    libpq-dev \
    libicu-dev \
    libfreetype6-dev \
    libldap2-dev \
    libxslt-dev \
    libldb-dev \
    libsqlite3-0 \
    libsqlite3-dev \
    libonig-dev \
    && ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/

# Compile Apache
RUN cd /usr/local/src \
    && wget http://mirror.rise.ph/apache//httpd/httpd-2.4.46.tar.bz2 -O httpd-2.4.46.tar.bz2 \
    && tar -xjf  httpd-2.4.46.tar.bz2 \
    && rm httpd-2.4.46.tar.bz2 \
    && cd /usr/local/src/httpd-2.4.46 \
    && ./configure \
    --prefix=/usr/local \
    --enable-ldap=shared \
    --enable-lua=shared \
    --enable-ssl \
    --enable-so \
    --enable-mpms-shared=all \
    && make \
    && make install \
    && rm -Rf /usr/local/src/httpd-2.4.46

# Compile OpenSSL
RUN cd /usr/local/src/ \
    && wget https://ftp.openssl.org/source/openssl-1.1.1h.tar.gz -O openssl-1.1.1h.tar.gz \ 
    && cd /usr/local/src \
    && tar -xzf openssl-1.1.1h.tar.gz \
    && cd openssl-1.1.1h \
    && ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib \
    && make \
    && make install \
    && rm -Rf /usr/local/src/openssl-1.1.1h.tar.gz /usr/local/src/openssl-1.1.1h

# Compile PHP
RUN cd /usr/local/src \
    && wget https://www.php.net/distributions/php-7.4.10.tar.bz2 -O php-7.4.10.tar.bz2 \
    && tar -xjf php-7.4.10.tar.bz2 \
    && cd /usr/local/src/php-7.4.10 \
    && ./configure --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/etc \
    --with-apxs2=/usr/local/bin/apxs \
    --enable-mbstring \
    --with-curl \
    --with-xmlrpc \
    --enable-soap \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --enable-intl \
    --with-xsl \
    --with-zlib \
    --with-openssl=/usr/local/ssl \
    --enable-opcache \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --enable-bcmath \
    --enable-calendar \
    --enable-ftp \
    --without-iconv \
    --enable-sockets \
    --with-xsl \
    && make \
    && make install \
    && cd /usr/local/src/ \
    && rm -Rf php-7.4.10.tar.bz2 php-7.4.10

# Setup supervisor
RUN apt install -y supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/var/www"]
WORKDIR /var/www

COPY config/httpd.conf /usr/local/conf/
COPY config/httpd-mpm.conf /usr/local/conf/extra/httpd-mpm.conf
COPY config/php.conf /usr/local/conf/extra/php.conf
COPY config/security.conf /usr/local/conf/extra/security.conf
COPY config/cache.conf /usr/local/conf/extra/cache.conf
COPY config/php.prod.ini /usr/local/etc/php.ini
COPY config/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY src/index.php /var/www/

EXPOSE 80

CMD ["/usr/bin/supervisord"]