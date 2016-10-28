FROM ubuntu:trusty
MAINTAINER MaLu <malu@malu.me> 

#时区设置
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD sources.list /etc/apt/sources.list

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN apt-get install -y build-essential g++ curl libssl-dev git vim libxml2-dev python-software-properties software-properties-common byobu htop man unzip lrzsz wget supervisor apache2 libapache2-mod-php5 php5-redis pwgen php-apc php5-mcrypt php5-gd && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# 安装Composer,此物是PHP用来管理依赖关系的工具,laravel symfony等时髦的框架会依赖它.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN apt-get install -y nodejs npm
RUN npm config set registry http://registry.npm.taobao.org
RUN npm install -g n
RUN n stable && npm install -g newman

#RUN \
#  cd /tmp && \
#  wget http://nodejs.org/dist/node-latest.tar.gz && \
#  tar xvzf node-latest.tar.gz && \
#  rm -f node-latest.tar.gz && \
#  cd node-v* && \
#  ./configure && \
#  CXX="g++ -Wno-unused-local-typedefs" make && \
#  CXX="g++ -Wno-unused-local-typedefs" make install && \
#  cd /tmp && \
#  rm -rf /tmp/node-v* && \
#  npm install -g npm && \
#  printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Install newman
#RUN npm install -g newman

#7z安装
RUN apt-get install -y p7zip p7zip-full p7zip-rar

#hashcat
#hashcat v3.10需要的opencl环境
#RUN apt-get install -y ocl-icd-libopencl1
#RUN wget http://registrationcenter-download.intel.com/akdlm/irc_nas/9019/opencl_runtime_16.1_x64_ubuntu_5.2.0.10002.tgz -P /home/
#RUN tar -zxvf /home/opencl_runtime_16.1_x64_ubuntu_5.2.0.10002.tgz -C /home/
#这里需要用户交互操作
#RUN cd /home/opencl_runtime_16.1_x64_ubuntu_5.2.0.10002/ ; ./install.sh

#hashcat v2.00
RUN wget https://hashcat.net/files_legacy/hashcat-2.00.7z -P /home
RUN cd /home ; 7z x hashcat-2.00.7z
#获取系统位数：uname -m|awk '{if($1~/^x86_64/){print 64}else{print 32}}'
RUN ln -s /home/hashcat-2.00/hashcat-cli`uname -m|awk '{if($1~/^x86_64/){print 64}else{print 32}}'`.bin /usr/local/bin/hashcat
RUN chmod 777 -R /home/hashcat-2.00

#cpulimit
RUN cd /home ; git clone https://github.com/opsengine/cpulimit.git ; cd cpulimit ; make
RUN cp /home/cpulimit/src/cpulimit /usr/local/bin/

#PIP
RUN apt-get install -y python-pip python-pyside xvfb ipython

#OCR文字识别(中文包)
RUN apt-get install -y tesseract-ocr tesseract-ocr-chi-sim python-opencv python-imaging

#添加PHP mcrypt扩展
RUN php5enmod mcrypt

#mongodb redis
RUN apt-get install -y mongodb redis-server
ADD start-redis.sh /start-redis.sh
ADD start-mongodb.sh /start-mongodb.sh
#ADD supervisord-redis.conf /etc/supervisor/conf.d/supervisord-redis.conf
ADD supervisord-redis.conf /supervisord-redis.conf
#ADD supervisord-mongodb.conf /etc/supervisor/conf.d/supervisord-mongodb.conf
ADD supervisord-mongodb.conf /supervisord-mongodb.conf
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
ADD home/.profile /root/.profile
ADD home/.bashrc /root/.bashrc
ADD home/.gitconfig /root/.gitconfig
ADD home/.scripts /root/.scripts
ADD home/.vimrc /root/.vimrc

ADD start-apache2.sh /start-apache2.sh
#ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-apache2.conf /supervisord-apache2.conf
#ADD supervisord-sshd.conf /etc/supervisor/conf.d/supervisord-sshd.conf
ADD supervisord-sshd.conf /supervisord-sshd.conf

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

RUN mkdir -p /app/www && rm -fr /var/www/html && ln -s /app/www /var/www/html

RUN mkdir /root/.pip
ADD pip.conf /root/.pip/pip.conf

#scrapy
RUN apt-get install -y libffi-dev python-dev python-lxml
RUN pip install w3lib && \
    pip install cssselect && \
    pip install cryptography && \
    pip install Twisted && \
    pip install scrapy

#sitemap_online
RUN pip install beautifulsoup4 && \
    pip install redis && \
    pip install pymongo
#sitemap_online mysql-python install
RUN apt-get install libmysqlclient-dev
RUN pip install mysql-python

#webssh:gateone集成进apache反向代理
RUN wget https://pypi.python.org/packages/2d/9a/38e855094bd11cba89cd2a50a54c31019ef4a45785fe12be6aa9a7c633de/tornado-2.4.tar.gz#md5=c738af97c31dd70f41f6726cf0968941 -P /home/
RUN tar zxvf /home/tornado-2.4.tar.gz -C /home/
RUN cd /home/tornado-2.4/ ; python setup.py build && python2 setup.py install

RUN wget https://github.com/liftoff/GateOne/archive/v1.1.tar.gz -P /home/
RUN tar zxvf /home/v1.1.tar.gz -C /home/
RUN cd /home/GateOne-1.1/ ; python setup.py install

ADD apache2/proxy.conf /etc/apache2/conf-enabled/
ADD apache2/proxy.load /etc/apache2/mods-enabled/
RUN mkdir -p /home/webssh/auth
ADD apache2/.htaccess /home/webssh/
ADD apache2/static/.htaccess /home/webssh/static.htaccess
ADD apache2/auth/index.php /home/webssh/auth/

ADD apache2/server.conf /opt/gateone/
ADD start-gateone.sh /start-gateone.sh
#ADD supervisord-gateone.conf /etc/supervisor/conf.d/supervisord-gateone.conf
ADD supervisord-gateone.conf /supervisord-gateone.conf

ADD apache2/usr /home/webssh/usr


ENV HOME /root
ENV REDIS_DIR /app/data
WORKDIR /root

VOLUME ["/root","/app"]

#mongodb 1.6.14 ; 默认apt-get install php5-mongo 安装的是1.4.5
RUN apt-get install -y php5-dev
RUN wget http://pecl.php.net/get/mongo-1.6.14.tgz -P /home/
RUN tar -zxvf /home/mongo-1.6.14.tgz -C /home/
RUN cd /home/mongo-1.6.14/ ; phpize
RUN cd /home/mongo-1.6.14/ ; ./configure
RUN cd /home/mongo-1.6.14/ ; make install

	# 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
RUN	apt-get clean && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 安装百度网盘同步工具syncy
ADD syncy/syncy.conf /etc/syncy.conf
ADD syncy/syncy.py /usr/local/bin/syncy.py
ADD syncy/syncy.sh /etc/init.d/syncy
RUN chmod 777 /usr/local/bin/syncy.py
RUN chmod 777 /etc/init.d/syncy

RUN chmod 755 /*.sh

#COPY home/ /root

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 100M
ENV PHP_POST_MAX_SIZE 100M

ENV AUTHORIZED_KEYS **None**

EXPOSE 22 80 6379 443 21 23 8080 8888 8000 27017 3306
CMD ["/run.sh"]
