#!/bin/bash
tar -xvzf lua-5.3.3.tar.gz
cd lua-5.3.3/
sed -ri 's/MYCFLAGS=/MYCFLAGS= -fPIC/' src/Makefile
make linux
cd ../dyncall-0.9/
./configure
make
sudo make install
cd ../bindings/lua/luadc/
make
cd testFuncs/
gcc -shared -fPIC -o libtest.so test.c
../../../../lua-5.3.3/src/lua dctest.lua
../../../../lua-5.3.3/src/lua dctest2.lua
../../../../lua-5.3.3/src/lua dctest3.lua
../../../../lua-5.3.3/src/lua dctest4.lua
