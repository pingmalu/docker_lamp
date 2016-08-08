# docker_lamp
lamp 持久化环境

启动示例：

	docker run -p 771:22 -p 772:80 -p 773:3306 -e ROOT_PASS=pass -e MYSQL_PASS=pass -v /root/app/:/app -d xxxx