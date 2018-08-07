#!/bin/bash
# sudo apt-get install texlive-full
set -e 
pdflatex sigconf.tex
echo "Created sigconf.pdf"
# For final paper submission
# git clone git@github.com:bardsoftware/template-acm-2017.git
