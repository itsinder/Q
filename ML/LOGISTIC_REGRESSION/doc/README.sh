#!/bin/bash
set -e 
filename=$1
# How to compile documentation
# Sample usage if bash README.sh log_reg
# Assume that $1 is prefix of filename
touch .meta
eval `../../../DOC/latex/tools/setenv`
make -f ../../../DOC/latex/tools/docdir.mk ${filename}.pdf
echo "Created ${filename}.pdf"
