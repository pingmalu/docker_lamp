#!/bin/bash
#MYENV=malu
if [ "${MYENV}" != "**None**" ] && [ "${MYENV}" != "" ]; then
   cd /app/mybash/${MYENV}
   ln -s -f -n /app/mybash/${MYENV} /root/myenv
   sed -i 's/.*AllowOverride FileInfo.*/                AllowOverride All/' /etc/apache2/sites-enabled/000-default.conf
   sed -i 's/^files = .*/files = \/app\/supervisor_conf\/*.conf \/app\/mybash\/'${MYENV}'\/*.conf/' /etc/supervisor/supervisord.conf
   #sed -i 's/^files = .*/files = \/app\/mybash\/'${MYENV}'\/*.conf/' /etc/supervisor/supervisord.conf
   #crontab < root
   #cron
   #ln -s -f /app/mybash/${MYENV}/logstash/logstash.conf /etc/logstash/conf.d/logstash.conf
   #MYSQL config
   #ln -s -f /app/mybash/${MYENV}/my.cnf /etc/mysql/my.cnf
   #chmod 777 /app/mysql -R
   #PORT proxy
   #ln -s -f /app/mybash/${MYENV}/rinetd.cnf /etc/rinetd.conf
   #ln -s -f -n /app/mybash/${MYENV}/www /var/www/html
   #cp -r /app/mybash/.mysec/.subversion /root/
fi
#/app/proxy-mysql/mysql-proxy/bin/mysql-proxy --defaults-file=/app/proxy-mysql/mysql-proxy/mysql-proxy.conf &
#sed -i 's/^#server-id.*/server-id               = 1/' /etc/mysql/my.cnf
#sed -i 's/^#log_bin.*/log_bin                 = \/app\/mysql\/mysql-bin.log/' /etc/mysql/my.cnf
