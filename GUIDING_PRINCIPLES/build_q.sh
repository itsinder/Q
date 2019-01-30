#!/bin/bash
set -e
bash my_print.sh "STARTING: Building Q"
pwd
cd ../UTILS/build
pwd
make
cd ../GUIDING_PRINCIPLES
bash my_print.sh "COMPLETED: Building Q"