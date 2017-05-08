#!/bin/bash
###Install lua , luajit and luarocks
### Install lua ####
sudo apt-get install lua5.1
sudo apt-get install liblua5.1-dev  


######## Lua JIT #########
wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
tar -xvf LuaJIT-2.0.4.tar.gz
cd LuaJIT-2.0.4/
make
sudo make install

wget https://luarocks.org/releases/luarocks-2.4.1.tar.gz
tar zxpf luarocks-2.4.1.tar.gz
cd luarocks-2.4.1
./configure; sudo make bootstrap
sudo luarocks install penlight
sudo luarocks install luaposix
