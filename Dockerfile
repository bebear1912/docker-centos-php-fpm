FROM centos:7

# install PHP and extensions
RUN yum clean all; yum -y update; \
    yum -y install epel-release http://rpms.remirepo.net/enterprise/remi-release-7.rpm; \
    yum -y --enablerepo=remi,remi-php71 install php \
    php-fpm \
    php-gd \
    php-json \
    php-mbstring \
    php-mysqlnd \
    php-xml \
    php-xmlrpc \
    php-opcache \
    php-cli \
    php-bcmath \
    php-mcrypt \
    php-pdo \
    php-pdo-dblib \
    php-pecl-geoip \
    php-pecl-memcache \
    php-pecl-memcached \
    php-pecl-redis \
    ext-pcntl \
    php-process \
    php-zip; \
    yum -y update; \
    yum clean all; \
    php --version;

RUN yum -y install nginx

# Adding the configuration file of the nginx
COPY ./nginx.conf /etc/nginx/nginx.conf

COPY ./default.conf /etc/nginx/conf.d/default.conf

COPY ./index.php /var/www/html/index.php

# create /tmp/lib/php
RUN mkdir -p /tmp/lib/php/session; \
    mkdir -p /tmp/lib/php/wsdlcache; \
    mkdir -p /tmp/lib/php/opcache; \
    mkdir /root/.composer; \
    chmod 777 -R /tmp/lib/php

# add custom config
COPY ./php.ini /etc/php.ini
COPY ./www.conf /etc/php-fpm.d/www.conf

RUN chmod 777 -R /etc/php-fpm.d ; \
  mkdir /var/run/php-fpm

# start install supervisor
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && \
 python get-pip.py

RUN pip install supervisor && \
    supervisord --version

# Adding the configuration file of the Supervisor
COPY ./supervisord.conf /etc/supervisord.conf

VOLUME ["/etc/nginx/conf.d", "/var/www/html" , "/var/log/php-fpm", "/var/log/nginx" ]

# install Composer and plugins
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer


# Set the port to 80 
EXPOSE 80

# Executing supervisord
CMD ["supervisord" , "-n"]