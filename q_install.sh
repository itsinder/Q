#!/bin/bash

sudo rm -rf /usr/local/share/lua/5.1/Q
sudo mkdir /usr/local/share/lua/5.1/Q
sudo cp -r ./OPERATORS /usr/local/share/lua/5.1/Q
sudo cp -r ./UTILS /usr/local/share/lua/5.1/Q
sudo cp -r ./RUNTIME /usr/local/share/lua/5.1/Q
sudo cp -r  q_export.lua /usr/local/share/lua/5.1/Q
sudo cp -r  init.lua /usr/local/share/lua/5.1/Q

# FIX THIS, pick library from build target

sudo cp $HOME/local/Q/include/q_core.h /usr/local/share/lua/5.1/Q
sudo cp $HOME/Q/lib/libq_core.so /usr/lib
sudo cp $HOME/Q/include/q_core.h /usr/local/share/lua/5.1/Q
