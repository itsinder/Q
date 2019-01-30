#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing lua rocks"
#--TODO: instead of wget we can get this tar from Q repo
wget https://luarocks.org/releases/luarocks-2.4.1.tar.gz
tar zxpf luarocks-2.4.1.tar.gz
cd luarocks-2.4.1
./configure; sudo make bootstrap
cd ../
rm -rf luarocks-2.4.1
bash my_print.sh "COMPLETED: Installing lua rocks"


