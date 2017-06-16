#!/bin/bash

sudo rm -rf /usr/local/share/lua/5.1/Q
sudo rm -rf /usr/lib/libq_core.so
sudo mkdir /usr/local/share/lua/5.1/Q
sudo cp -r ./OPERATORS /usr/local/share/lua/5.1/Q
sudo cp -r ./UTILS /usr/local/share/lua/5.1/Q
sudo cp -r ./RUNTIME /usr/local/share/lua/5.1/Q
sudo cp -r  q_export.lua /usr/local/share/lua/5.1/Q
sudo cp -r  init.lua /usr/local/share/lua/5.1/Q

# FIX THIS, pick library from build target
sudo cp $Q_ROOT/lib/libq_core.so /usr/lib
sudo cp $Q_ROOT/include/q_core.h /usr/local/share/lua/5.1/Q
