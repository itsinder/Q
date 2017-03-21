#!/bin/bash
set -e 

cat min_specialize.lua | \
    sed s'/min_/max_/'g | \
    sed s'/mcr_min/mcr_max/'g | \
    sed s'/MIN/MAX/'g \
    > max_specialize.lua

cat min_specialize.lua | \
  sed s'/min_/sum_/'g | \
  sed s'/mcr_min/mcr_sum/'g | \
  sed s'/MIN/SUM/'g \
  > sum_specialize.lua

cat min_specialize.lua | \
  sed s'/min_/sum_sqr_/'g | \
  sed s'/mcr_min/mcr_sum_sqr/'g | \
  sed s'/MIN/SUM_SQR/'g \
  > sum_sqr_specialize.lua