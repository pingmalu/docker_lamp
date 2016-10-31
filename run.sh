#!/bin/bash

if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi

if [ ! -f /.root_pw_set ]; then
	/set_root_pw.sh
fi

VOLUME_HOME_MYSQL="/app/mysql"

if [[ ! -d $VOLUME_HOME_MYSQL/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME_MYSQL"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

sed -i '1i\requirepass '$REDIS_PASS /etc/redis/redis.conf
sed -i 's/^daemonize yes/daemonize no/' /etc/redis/redis.conf
sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
sed -i 's/^dir \/var\/lib\/redis/dir \/app\/data/' /etc/redis/redis.conf
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
sed -i 's/^bind_ip = 127.0.0.1/bind_ip = 0.0.0.0/' /etc/mongodb.conf
sed -i 's/^dbpath=\/var\/lib\/mongodb/dbpath=\/app\/mongodb\/db/' /etc/mongodb.conf
sed -i 's/^logpath=\/var\/log\/mongodb\/mongodb.log/logpath=\/app\/mongodb\/log/' /etc/mongodb.conf
echo 'extension=mongo.so' >> /etc/php5/apache2/php.ini

#gateone
# sed -i 's/^port =.*/port = 50360/' /opt/gateone/server.conf
# sed -i 's/^origins =.*/origins = "*"/' /opt/gateone/server.conf
# sed -i 's/^disable_ssl =.*/disable_ssl = True/' /opt/gateone/server.conf
mkdir -p /app/www/webssh
mkdir -p /app/www/static
mkdir -p /app/www/auth
mkdir -p /app/www/do
# 存在不覆盖并不提示
awk 'BEGIN { cmd="cp -ri /home/webssh/.htaccess /app/www/webssh/.htaccess"; print "n" |cmd; }'
awk 'BEGIN { cmd="cp -ri /home/webssh/static.htaccess /app/www/static/.htaccess"; print "n" |cmd; }'
awk 'BEGIN { cmd="cp -ri /home/webssh/auth/index.php /app/www/auth/index.php"; print "n" |cmd; }'
awk 'BEGIN { cmd="cp -ri /home/webssh/usr /app/www/usr"; print "n" |cmd; }'
awk 'BEGIN { cmd="cp -ri /home/webssh/do/index.php /app/www/do/index.php"; print "n" |cmd; }'

# syncy
awk 'BEGIN { cmd="cp -ri /etc/syncy.conf /app/syncy.conf"; print "n" |cmd; }'
mkdir -p /app/syncy

sed -i 's/^files = .*/files = \/app\/supervisor_conf\/*.conf/' /etc/supervisor/supervisord.conf
mkdir -p /app/supervisor_conf
ln -s -f /supervisord-apache2.conf /app/supervisor_conf/supervisord-apache2.conf
exec /usr/bin/supervisord -n
