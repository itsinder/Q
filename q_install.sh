#!/bin/bash

rm -rf /usr/local/share/lua/5.1/Q
mkdir /usr/local/share/lua/5.1/Q
cp -r ./OPERATORS /usr/local/share/lua/5.1/Q
cp -r ./UTILS /usr/local/share/lua/5.1/Q
cp -r ./RUNTIME /usr/local/share/lua/5.1/Q
cp -r  q_export.lua /usr/local/share/lua/5.1/Q
cp -r  init.lua /usr/local/share/lua/5.1/Q

# FIX THIS, pick library from build target
cp $HOME/Q/lib/libq.so /usr/lib
cp $HOME/Q/include/q_core.h /usr/local/share/lua/5.1/Q