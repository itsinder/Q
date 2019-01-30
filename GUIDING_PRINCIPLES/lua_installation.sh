#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing lua from source"
#--TODO: instead of wget we can get this tar from Q repo
wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
tar -xvzf lua-5.1.5.tar.gz
cd lua-5.1.5/

IS_LUA_DEBUG=$1
#debug flag is set then append the -g flag
if [ "$#" -eq 1 -a $IS_LUA_DEBUG == "LUA_DEBUG" ];then
  sed -i '11s/CFLAGS=/CFLAGS= -g/' src/Makefile
fi

make linux
sudo make install

#debug flag is set then creating a link to L
if [ "$#" -eq 1 -a $IS_LUA_DEBUG == "LUA_DEBUG" ];then
  sudo ln -sf /usr/local/bin/lua /usr/local/bin/L
fi

sudo cp ./etc/lua.pc /usr/lib/pkgconfig/
cd ../
rm -rf lua-5.1.5 lua-5.1.5.tar.gz
bash my_print.sh "COMPLETED: Installing lua from source"