#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing dependencies from apt-get"

sudo apt-get update -y || true

which cmake &> /dev/null || true
RES=$?
if [[ $RES -ne 0 ]] ; then
  sudo apt-get install make cmake -y
else
  bash my_print.sh "dependency cmake is already installed"
fi

which unzip &> /dev/null || true
RES=$?
if [[ $RES -ne 0 ]] ; then
  sudo apt-get install unzip -y # for luarocks
else
  bash my_print.sh "dependency unzip is already installed"
fi

sudo apt-get install libncurses5-dev -y # for lua-5.1.5

sudo apt-get install libssl-dev -y # for QLI

which m4 &> /dev/null || true
RES=$?
if [[ $RES -ne 0 ]] ; then
  sudo apt-get install m4 -y         # for QLI
else
  bash my_print.sh "dependency m4 is already installed"
fi

sudo apt-get install libreadline-dev -y

#installing LAPACK stuff
sudo apt-get install liblapacke-dev liblapack-dev -y

bash my_print.sh "COMPLETED: Installing dependencies from apt-get"
