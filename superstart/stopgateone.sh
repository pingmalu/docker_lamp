#!/bin/bash
rm -f /app/supervisor_conf/supervisord-gateone.conf
rm -f /app/supervisor_conf/supervisord-sshd.conf
supervisorctl update