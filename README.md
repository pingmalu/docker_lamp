# docker_lamp
lamp 持久化环境

启动示例：

	docker run -p 771:22 -p 772:80 -p 773:3306 -e ROOT_PASS=pass -e MYSQL_PASS=pass -v /root/app/:/app -d xxxx

Elasticsearch:

	vim /app/mybash/firstrun.sh

	#!/bin/bash
	#MYENV=E1
	if [ "${MYENV}" != "**None**" ]; then
	  basepath=$(cd `dirname $0`; pwd)
	  cd $basepath/$MYENV
	  pwd
	  ./run.sh
	fi

	mkdir $MYENV
	touch $MYENV/run.sh
