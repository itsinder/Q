GCCVER=$(gcc --version | awk '/gcc /{print $4;exit 0;}')
GCCVER=$(echo "${GCCVER//.}")
REQUIRED=5.4.0
REQUIRED=$(echo "${REQUIRED//.}")
if [ $(bc <<< "$GCCVER >= $REQUIRED") -eq 1 ];then
  bash aio_utils.sh my_print "STARTING: GCC version is appropriate"
else
  #todo: Error msg color red
  bash aio_utils.sh my_print "Required GCC version is 5.4.0"
  exit 1;
fi


