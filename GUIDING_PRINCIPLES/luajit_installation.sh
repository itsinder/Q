#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing luajit from source"
# TODO: instead of wget we can get this tar from Q repo
#wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
# TODO: instead of wget we can get this tar from Q repo
wget http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz
#tar -xvf LuaJIT-2.0.4.tar.gz
tar -xvf LuaJIT-2.1.0-beta3.tar.gz
#cd LuaJIT-2.0.4/
cd LuaJIT-2.1.0-beta3/
sed -i '114s/#//' src/Makefile # to enable gc64
make TARGET_FLAGS=-pthread
sudo make install
cd /usr/local/bin
sudo ln -sf luajit-2.1.0-beta3 /usr/local/bin/L
sudo ln -sf luajit-2.1.0-beta3 /usr/local/bin/luajit

cd -
cd ../
rm -rf LuaJIT-2.1.0-beta3
bash my_print.sh "COMPLETED: Installing luajit from source"
