FROM daocloud.io/ubuntu:latest
MAINTAINER MaLu <malu@malu.me> 

ADD sources.list /etc/apt/sources.list

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN apt-get install -y build-essential g++ curl libssl-dev git vim libxml2-dev python-software-properties software-properties-common byobu htop man unzip lrzsz wget supervisor apache2 libapache2-mod-php5 php5-redis pwgen php-apc php5-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN apt-get install -y python-pip python-pyside xvfb

#mongodb redis
RUN apt-get install -y mongodb redis-server
ADD start-redis.sh /start-redis.sh
ADD start-mongodb.sh /start-mongodb.sh
#ADD supervisord-redis.conf /etc/supervisor/conf.d/supervisord-redis.conf
ADD supervisord-redis.conf /supervisord-redis.conf
ADD supervisord-mongodb.conf /etc/supervisor/conf.d/supervisord-mongodb.conf
#ADD supervisord-mongodb.conf /supervisord-mongodb.conf
RUN mkdir -p /app/data
RUN mkdir -p /app/mongodb/db

RUN apt-get install -y mysql-server php5-mysql
ADD start-mysqld.sh /start-mysqld.sh
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
#ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supervisord-mysqld.conf /supervisord-mysqld.conf
RUN mkdir -p /app/mysql

# Add files.
ADD home/.bashrc /root/.bashrc
ADD home/.gitconfig /root/.gitconfig
ADD home/.scripts /root/.scripts

ADD start-apache2.sh /start-apache2.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-sshd.conf /etc/supervisor/conf.d/supervisord-sshd.conf

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
#RUN chmod +x /*.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

RUN mkdir -p /app/www && rm -fr /var/www/html && ln -s /app/www /var/www/html

RUN mkdir /root/.pip
ADD pip.conf /root/.pip/pip.conf

#scrapy
RUN apt-get install -y libffi-dev python-dev python-lxml
RUN pip install w3lib
RUN pip install cssselect
RUN pip install cryptography
RUN pip install Twisted
RUN pip install scrapy

ENV HOME /root
ENV REDIS_DIR /app/data
WORKDIR /root

VOLUME ["/root","/app"]

#mongodb
RUN apt-get install -y php5-dev
RUN wget http://pecl.php.net/get/mongo-1.6.14.tgz -P /home/
RUN tar -zxvf /home/mongo-1.6.14.tgz -C /home/
RUN cd /home/mongo-1.6.14/ ; phpize
RUN cd /home/mongo-1.6.14/ ; ./configure
RUN cd /home/mongo-1.6.14/ ; make install

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 100M
ENV PHP_POST_MAX_SIZE 100M

ENV AUTHORIZED_KEYS **None**

EXPOSE 22 80 6379 443 21 23 8080 8888 8000 27017 3306
CMD ["/run.sh"]
