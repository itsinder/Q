#!/bin/bash
set -e 

cat min_chk.lua | sed s'/min_/max_/'g | sed s'/mcr_min/mcr_max/'g > max_chk.lua
cat min_chk.lua | sed s'/min_/sum_/'g | sed s'/mcr_min/mcr_sum/'g > sum_chk.lua
