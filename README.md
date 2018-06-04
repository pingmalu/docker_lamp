# docker_lamp
lamp 持久化环境

Build:

	docker build -t docker_lamp:base -f docker_lamp/Dockerfile docker_lamp/

启动示例：

	docker run \
	-p 5211:22 \
	-p 5212:80 \
	-p 5213:6379 \
	-p 5214:443 \
	-p 5215:21 \
	-p 5216:23 \
	-p 5217:3306 \
	-p 5218:27017 \
	-p 5219:9200 \
	-p 5220:9300 \
	-p 5221:5221 \
	-p 5222:5222 \
	-p 5223:5223 \
	-e ROOT_PASS=password \
	-e MYSQL_PASS=password \
	-v /home/workspace/malu/docker/app:/app \
	-h lamp \
	--name lamp \
	-d malu.me/malu/docker_lamp:master

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
