#!/bin/bash
ln -s -f /supervisord-gateone.conf /app/supervisor_conf/
ln -s -f /supervisord-sshd.conf /app/supervisor_conf/
supervisorctl update
