#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing dependencies from apt-get"

#sudo apt-get update -y

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

apt-cache policy libncurses5-dev &> /dev/null || true
RES=$?
if [[ $RES -ne 0 ]] ; then
  sudo apt-get install libncurses5-dev -y # for lua-5.1.5
else
  bash my_print.sh "dependency libncurses5-dev is already installed"
fi

apt-cache policy libssl-dev &> /dev/null || true
RES=$?
if [[ $RES -ne 0 ]] ; then
  sudo apt-get install libssl-dev -y # for QLI
else
  bash my_print.sh "dependency libssl-dev is already installed"
fi

which m4 &> /dev/null || true
RES=$?
if [[ $RES -ne 0 ]] ; then
  sudo apt-get install m4 -y         # for QLI
else
  bash my_print.sh "dependency m4 is already installed"
fi

apt-cache policy libreadline-dev &> /dev/null || true
RES=$?
if [[ $RES -ne 0 ]] ; then
  sudo apt-get install libreadline-dev -y
else
  bash my_print.sh "dependency libreadline-dev is already installed"
fi

#installing LAPACK stuff
apt-cache policy liblapacke-dev &> /dev/null || true
RES=$?
if [[ $RES -ne 0 ]] ; then
  sudo apt-get install liblapacke-dev -y
else
  bash my_print.sh "dependency liblapacke-dev is already installed"
fi

bash my_print.sh "COMPLETED: Installing dependencies from apt-get"
