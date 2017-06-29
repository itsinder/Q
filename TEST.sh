#!/bin/bash
source setup.sh
is_exclude() {
  if [ $# -ne 1 ] ; then
    echo "error in number of arguments"
    exit 1
  fi

}

find_matches() {
  if [ $# -ne 1 ] ; then
    echo "error in number of args"
    exit 1
  fi
  # find . -type d \( \
    #    -path ./.git -o \
    #    -path ./experimental -o \
    #    -path "*/DEPRECATED*" -o \
    #    -path ./*DOC -o \
    #    -path '*/\.*' -o \
    #    -name "_*" \
    #    \) -prune -o -name "$1"
  find . \
    -not -path '*/.*' \
    -and -not -path '*/*DEPRECAT*' \
    -and -not -path '*/*experiment*' \
    -and -not -path '*/DOC/*' \
    -and -name "$1"

}
# find_matches "_spec.lua"

echo "hello all "
source setup.sh &>/dev/null
rm luacov* &>/dev/null
# find_matches "test_*.lua"
# For lua scripts
TOTAL=0
SUCCESS=0
FAIL=0
NA=0
while read -r line
do
  luajit $line &>/dev/null
  CODE=$?
  echo $CODE
  if [ $CODE -eq 0 ] ; then
    (( SUCCESS++ ))
  elif [ $CODE -eq 2 ]; then
    (( NA++ ))
  else
    (( FAIL++ ))
    echo "$line failed"
  fi
  (( TOTAL++ ))
done < <( find_matches 'test_*.lua' )

# for busted scripts
echo "busted"
while read -r line
do
  busted -v -c $line &>/dev/null
  CODE=`echo $?`
  if [ $CODE -neq 0  ] ; then
    echo "$line failed"
  fi
  (( EXIT += $? ))
done < <( find_matches "spec_*.lua" )

echo "SUCCESS/ NA/ FAIL/ TOTAL $SUCCESS/$NA/$FAIL/$TOTAL"

if [ $FAIL -eq 0 ]; then
  exit 0
else
  exit 1
fi
