#!/bin/bash
set -e 
paper=cidr2019
touch .meta
eval `../latex/tools/setenv`
make -f  ../latex/tools/docdir.mk ${paper}.pdf
echo "Created ${paper}.pdf"
