#!/bin/bash
set -e 

cat min_chk.lua | sed s'/min_chk/max_chk/'g | sed s'/mcr_min/mcr_max/'g > max_chk.lua
cat min_chk.lua | sed s'/min_chk/sum_chk/'g | sed s'/mcr_min/mcr_sum/'g > sum_chk.lua
