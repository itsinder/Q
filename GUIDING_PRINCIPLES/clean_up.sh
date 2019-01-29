function cleanup(){
  if [ -z "$1" ]; then
    bash aio_utils.sh my_print "No directory passed to cleanup" 1
    exit 1
  fi
  bash aio_utils.sh my_print  $1
  find $1 -name "*.o" -o -name "_*" | xargs rm -f
}

$1 $2
