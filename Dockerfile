FROM alpine:3.11
MAINTAINER Wesley Haegens <wesley@weha.be>

# Add basics first
RUN apk update && apk upgrade && apk add --no-cache \
	bash apache2 php7-apache2 curl ca-certificates openssl openssh git php7 php7-phar php7-json php7-iconv php7-openssl tzdata nano

# Add Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Setup apache and php
RUN apk add --no-cache \
	php7-ftp \
	php7-xdebug \
	php7-mcrypt \
	php7-mbstring \
	php7-soap \
	php7-gmp \
	php7-pdo_odbc \
	php7-dom \
	php7-pdo \
	php7-zip \
	php7-mysqli \
	php7-sqlite3 \
	php7-pdo_pgsql \
	php7-bcmath \
	php7-gd \
	php7-odbc \
	php7-pdo_mysql \
	php7-pdo_sqlite \
	php7-gettext \
	php7-xml \
	php7-xmlreader \
	php7-xmlwriter \
	php7-tokenizer \
	php7-xmlrpc \
	php7-bz2 \
	php7-pdo_dblib \
	php7-curl \
	php7-ctype \
	php7-session \
	php7-redis \
	php7-exif \
	php7-intl \
	php7-fileinfo \
	php7-ldap \
	php7-apcu

# Problems installing in above stack
RUN apk add --no-cache php7-simplexml

RUN cp /usr/bin/php7 /usr/bin/php \
    && rm -f /var/cache/apk/*

# Add apache to run and configure
RUN sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_module/LoadModule\ session_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_cookie_module/LoadModule\ session_cookie_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_crypto_module/LoadModule\ session_crypto_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ deflate_module/LoadModule\ deflate_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ unique_id_module/LoadModule\ unique_id_module/" /etc/apache2/httpd.conf \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/var/www/html\"#g" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#/var/www/html#" /etc/apache2/httpd.conf \
    && printf "\n<Directory \"/var/www/html\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf
    
RUN adduser -u 82 -D -S -G www-data www-data \
    && addgroup apache www-data \
    && chown www-data:www-data /var/www/html \
    && chmod 777 /var/www/html

ADD start.sh /bootstrap/
RUN chmod +x /bootstrap/start.sh

EXPOSE 80
ENTRYPOINT ["/bootstrap/start.sh"]
