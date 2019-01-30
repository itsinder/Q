#!/bin/bash
set -e
DIR_PATH=$1
if [ -z $DIR_PATH ]; then
  bash my_print.sh "No directory passed to cleanup" 1
  exit 1
fi
bash my_print.sh $DIR_PATH
find $DIR_PATH -name "*.o" -o -name "_*" | xargs rm -f
