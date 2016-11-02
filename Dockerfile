FROM ubuntu:trusty
MAINTAINER MaLu <malu@malu.me> 

#时区设置
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD sources.list /etc/apt/sources.list

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen && \
    mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    apt-get install -y build-essential g++ curl libssl-dev git vim libxml2-dev python-software-properties software-properties-common byobu htop man unzip lrzsz wget supervisor apache2 libapache2-mod-php5 php5-redis pwgen php-apc php5-mcrypt php5-gd && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# 安装Composer,此物是PHP用来管理依赖关系的工具,laravel symfony等时髦的框架会依赖它.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    #添加PHP mcrypt扩展
    php5enmod mcrypt

# Install Node.js
RUN apt-get install -y nodejs npm && \
    npm config set registry http://registry.npm.taobao.org && \
    npm install -g n && \
    n stable && npm install -g newman

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
#获取系统位数: uname -m|awk '{if($1~/^x86_64/){print 64}else{print 32}}'
RUN wget https://hashcat.net/files_legacy/hashcat-2.00.7z -P /home && \
    cd /home ; 7z x hashcat-2.00.7z && \
    ln -s /home/hashcat-2.00/hashcat-cli`uname -m|awk '{if($1~/^x86_64/){print 64}else{print 32}}'`.bin /usr/local/bin/hashcat && \
    chmod 777 -R /home/hashcat-2.00

#cpulimit
RUN cd /home ; git clone https://github.com/opsengine/cpulimit.git ; cd cpulimit ; make && \
    cp /home/cpulimit/src/cpulimit /usr/local/bin/

#PIP
RUN apt-get install -y python-pip python-pyside xvfb ipython

#OCR文字识别(中文包)
RUN apt-get install -y tesseract-ocr tesseract-ocr-chi-sim python-opencv python-imaging

#mongodb redis mysql
RUN apt-get install -y mongodb redis-server mysql-server php5-mysql && \
    mkdir -p /app/data && \
    mkdir -p /app/mongodb/db && \
    mkdir -p /app/mysql

ADD my.cnf /etc/mysql/conf.d/my.cnf

#Add root files
ADD root/ /root
ADD superstart/ /

ADD run.sh /run.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

RUN mkdir -p /app/www && rm -fr /var/www/html && ln -s /app/www /var/www/html

RUN mkdir /root/.pip
ADD pip.conf /root/.pip/pip.conf

#scrapy
RUN apt-get install -y libffi-dev python-dev python-lxml && \
    pip install w3lib && \
    pip install cssselect && \
    pip install cryptography && \
    pip install Twisted && \
    pip install scrapy

#sitemap_online
RUN pip install beautifulsoup4 && \
    pip install redis && \
    pip install pymongo
#sitemap_online mysql-python install
RUN apt-get install libmysqlclient-dev && \
    pip install mysql-python

#webssh:gateone集成进apache反向代理
RUN wget https://pypi.python.org/packages/2d/9a/38e855094bd11cba89cd2a50a54c31019ef4a45785fe12be6aa9a7c633de/tornado-2.4.tar.gz#md5=c738af97c31dd70f41f6726cf0968941 -P /home/ && \
    tar zxvf /home/tornado-2.4.tar.gz -C /home/ && \
    cd /home/tornado-2.4/ ; python setup.py build && python2 setup.py install && \
    wget https://github.com/liftoff/GateOne/archive/v1.1.tar.gz -P /home/ && \
    tar zxvf /home/v1.1.tar.gz -C /home/ && \
    cd /home/GateOne-1.1/ ; python setup.py install

ADD apache2/proxy.conf /etc/apache2/conf-enabled/
ADD apache2/proxy.load /etc/apache2/mods-enabled/
RUN mkdir -p /home/webssh/auth
RUN mkdir -p /home/webssh/do
ADD apache2/.htaccess /home/webssh/
ADD apache2/static/.htaccess /home/webssh/static.htaccess
ADD apache2/auth/index.php /home/webssh/auth/
ADD apache2/do/index.php /home/webssh/do/

ADD apache2/server.conf /opt/gateone/

ADD apache2/usr /home/webssh/usr

#mongodb 1.6.14 ; 默认apt-get install php5-mongo 安装的是1.4.5
RUN apt-get install -y php5-dev
RUN wget http://pecl.php.net/get/mongo-1.6.14.tgz -P /home/ && \
    tar -zxvf /home/mongo-1.6.14.tgz -C /home/ && \
    cd /home/mongo-1.6.14/ ; phpize && \
    cd /home/mongo-1.6.14/ ; ./configure && \
    cd /home/mongo-1.6.14/ ; make install

# 安装百度网盘同步工具syncy
ADD syncy/syncy.conf /etc/syncy.conf
ADD syncy/syncy.py /usr/local/bin/syncy.py
ADD syncy/syncy.sh /etc/init.d/syncy
RUN chmod 777 /usr/local/bin/syncy.py && \
    chmod 777 /etc/init.d/syncy

RUN chmod 755 /*.sh

ADD apache2/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

# 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
RUN apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#COPY home/ /root

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 100M
ENV PHP_POST_MAX_SIZE 100M

ENV AUTHORIZED_KEYS **None**
ENV HOME /root
ENV REDIS_DIR /app/data

WORKDIR /root

VOLUME ["/root","/app"]

EXPOSE 22 80 6379 443 21 23 8080 8888 8000 27017 3306

CMD ["/run.sh"]
