#!/bin/bash
#MYENV=E2
if [ "${MYENV}" != "**None**" ] && [ "${MYENV}" != "" ]; then
  basepath=$(cd `dirname $0`; pwd)
  cd $basepath/$MYENV
  pwd
  chmod 777 run.sh
  ./run.sh
fi
