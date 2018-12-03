#!/bin/bash
set -e
touch .meta
eval ` ../../../DOC/latex/tools/setenv`
make -f ../../../DOC/latex/tools/docdir.mk dt.pdf
