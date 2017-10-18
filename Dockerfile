FROM ubuntu:trusty
MAINTAINER MaLu <malu@malu.me> 

WORKDIR /root

#时区设置
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Add root files
ADD root/ /root
ADD home/ /home
#Add to /
ADD superstart/ /
ADD run.sh /run.sh

RUN cat /home/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main' >> /etc/apt/sources.list && \
    echo 'deb http://packages.elasticsearch.org/logstash/2.4/debian stable main' >> /etc/apt/sources.list && \
    echo 'deb http://packages.elasticsearch.org/kibana/4.1/debian stable main' >> /etc/apt/sources.list

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen && \
    mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    apt-get install -y build-essential g++ curl libssl-dev git subversion vim libxml2-dev python-software-properties software-properties-common byobu htop man unzip lrzsz wget supervisor && \
    apt-get install -y apache2 libapache2-mod-php5 php5-redis pwgen php-apc php5-mcrypt php5-gd php5-curl php5-dev php5-mysql nginx && \
    #端口转发工具
    apt-get install -y rinetd && \
    #7z安装
    apt-get install -y p7zip p7zip-full && \
    #mongodb redis mysql
    apt-get install -y mongodb redis-server mysql-server && \
    ################ [Install PIP] ################
    apt-get install -y python-pip python3-pip python-pyside xvfb ipython libffi-dev python-dev libmysqlclient-dev libmysqld-dev python-lxml && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \

################ [elasticsearch packages] ################
#RUN curl http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
#    echo 'deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main' >> /etc/apt/sources.list && \
#    echo 'deb http://packages.elasticsearch.org/logstash/2.4/debian stable main' >> /etc/apt/sources.list && \
#    echo 'deb http://packages.elasticsearch.org/kibana/4.1/debian stable main' >> /etc/apt/sources.list && \
#    apt-get update && \
################ [elasticsearch packages] ################

################ [Install logstash] ################
    apt-get install -y openjdk-7-jre-headless logstash && \
    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    # */
ADD logstash/logstash.conf /etc/logstash/conf.d/
################ [Install logstash] ################


################ [Install elasticsearch ] ################
#RUN apt-get install -y elasticsearch && \
#    /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head
################ [Install elasticsearch ] ################


################ [Install Composer] ################
#此物是PHP用来管理依赖关系的工具,laravel symfony等时髦的框架会依赖它.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
################ [Install Composer] ################


################ [Node.js and newman] ################
#RUN apt-get install -y nodejs npm && \
#    npm config set registry http://registry.npm.taobao.org && \
#    npm install -g n && \
#    n stable && npm install -g newman
################ [Node.js and newman] ################


################ source install Node.js and newman ################
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
################ source install Node.js and newman ################


################ [hashcat v2.00] ################
#7z安装
#RUN apt-get install -y p7zip p7zip-full
#    p7zip-rar
#获取系统位数: uname -m|awk '{if($1~/^x86_64/){print 64}else{print 32}}'
#RUN wget https://hashcat.net/files_legacy/hashcat-2.00.7z -P /home && \
#    cd /home ; 7z x hashcat-2.00.7z && \
#    ln -s /home/hashcat-2.00/hashcat-cli`uname -m|awk '{if($1~/^x86_64/){print 64}else{print 32}}'`.bin /usr/local/bin/hashcat && \
#    chmod 777 -R /home/hashcat-2.00
################ [hashcat v2.00] ################


################ hashcat ################
#hashcat v3.10需要的opencl环境
#RUN apt-get install -y ocl-icd-libopencl1
#RUN wget http://registrationcenter-download.intel.com/akdlm/irc_nas/9019/opencl_runtime_16.1_x64_ubuntu_5.2.0.10002.tgz -P /home/
#RUN tar -zxvf /home/opencl_runtime_16.1_x64_ubuntu_5.2.0.10002.tgz -C /home/
#这里需要用户交互操作
#RUN cd /home/opencl_runtime_16.1_x64_ubuntu_5.2.0.10002/ ; ./install.sh
################ hashcat ################


################ [cpulimit] ####################
#RUN cd /home ; git clone https://github.com/opsengine/cpulimit.git ; cd cpulimit ; make && \
#    cp /home/cpulimit/src/cpulimit /usr/local/bin/
################ [cpulimit] ####################

#mongodb redis mysql
#RUN apt-get install -y mongodb redis-server mysql-server php5-mysql

#添加PHP mcrypt扩展
RUN php5enmod mcrypt

# config to enable .htaccess
RUN a2enmod rewrite

RUN mkdir -p /app/www && rm -fr /var/www/html && ln -s /app/www /var/www/html

################ [Install PIP] ################
#RUN apt-get install -y python-pip python3-pip python-pyside xvfb ipython libffi-dev python-dev libmysqlclient-dev libmysqld-dev
################ [Install PIP] ################



################ [爬虫相关] ################
##OCR文字识别(中文包)
#RUN apt-get install -y tesseract-ocr tesseract-ocr-chi-sim python-opencv python-imaging && \
#
##scrapy
#    apt-get install -y libffi-dev python-dev python-lxml && \
#    pip install w3lib && \
#    pip install cssselect && \
#    pip install cryptography && \
#    pip install Twisted && \
#    pip install scrapy && \
#
##sitemap_online
#RUN pip install mysql-python
RUN pip install beautifulsoup4 && \
    pip install mysql-python && \
    pip install redis && \
    pip install pymongo && \
    pip install elasticsearch && \
    pip install socketio-client && \
    pip install pyinstaller && \
    pip install psutil
    #apt-get install -y python-lxml
################ [爬虫相关] ################

################ [Install scapy] ################
#RUN pip3 install scapy-python3
################ [Install scapy] ################


#webssh:gateone集成进apache反向代理
RUN pip install tornado==2.4 && \
    wget https://github.com/liftoff/GateOne/archive/v1.1.tar.gz -P /home/ && \
    tar zxvf /home/v1.1.tar.gz -C /home/ && \
    cd /home/GateOne-1.1/ ; python setup.py install

ADD apache2/apache_default /etc/apache2/sites-available/000-default.conf
ADD apache2/proxy.conf /etc/apache2/conf-enabled/
ADD apache2/proxy.load /etc/apache2/mods-enabled/
#apache内存优化
ADD apache2/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf
ADD apache2/webssh/ /home/webssh/
ADD apache2/server.conf /opt/gateone/
#apache开启反向代理真实IP获取
RUN ln -s /etc/apache2/mods-available/remoteip.load /etc/apache2/mods-enabled/remoteip.load && \
    sed -i '/^LogFormat "%v/i\RemoteIPHeader X-Forwarded-For' /etc/apache2/apache2.conf && \
    sed -i '/^LogFormat "%v/i\RemoteIPInternalProxy 10.0.0.0/8' /etc/apache2/apache2.conf && \
    sed -i 's/^LogFormat "%h/LogFormat "%a/g' /etc/apache2/apache2.conf

################ php mongodb 1.6.14 ################
##默认apt-get install php5-mongo 安装的是1.4.5
#RUN apt-get install -y php5-dev && \
RUN wget http://pecl.php.net/get/mongo-1.6.14.tgz -P /home/ && \
    tar -zxvf /home/mongo-1.6.14.tgz -C /home/ && \
    cd /home/mongo-1.6.14/ ; phpize && \
    cd /home/mongo-1.6.14/ ; ./configure && \
    cd /home/mongo-1.6.14/ ; make install
################ php mongodb 1.6.14 ################

################ 百度网盘同步工具syncy ################
#ADD syncy/syncy.conf /etc/syncy.conf
#ADD syncy/syncy.py /usr/local/bin/syncy.py
#ADD syncy/syncy.sh /etc/init.d/syncy
#RUN chmod 777 /usr/local/bin/syncy.py && \
#    chmod 777 /etc/init.d/syncy
################ 百度网盘同步工具syncy ################

#mysql config
ADD mysql/my.cnf /etc/mysql/conf.d/my.cnf


RUN chmod 777 /home/mybash/*.sh && \
    #*/
    #Add n1 显示网速脚本
    echo '#!/bin/bash\nwatch -d -n 2 /home/mybash/net.sh eth0' >/usr/local/bin/n1 && \
    chmod 777 /usr/local/bin/* && \
    chmod 755 /*.sh
    #*/

# 添加国内源
ADD sources.list /etc/apt/sources.list
RUN mv /root/.pip/pip.conf.bak /root/.pip/pip.conf
#RUN apt-get update

# 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
#RUN apt-get clean && \
#    apt-get autoclean && \
#    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 100M
ENV PHP_POST_MAX_SIZE 100M

ENV AUTHORIZED_KEYS **None**
ENV REDIS_PASS **None**
ENV MYENV **None**
ENV MYSQL_PASS malupasswd
ENV HOME /root
ENV REDIS_DIR /app/redis


VOLUME ["/root","/app"]

EXPOSE 22 80 6379 443 21 23 8080 8888 8000 27017 3306 9200 9300

CMD ["/run.sh"]
