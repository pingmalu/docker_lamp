#!/bin/bash

case "$1" in
  start)
        /usr/local/bin/syncy.py &
        ;;
  stop)
        if [ -e /var/run/syncy.pid ] ; then
           sypid=$(cat /var/run/syncy.pid)
           kill $sypid
        fi
        ;;
  restart)
        if [ -e /var/run/syncy.pid ] ; then
           sypid=$(cat /var/run/syncy.pid)
           kill $sypid
        fi
        sleep 1
        /usr/local/bin/syncy.py &
        ;;
esac