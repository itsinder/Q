function cleanup(){
  if [ -z "$1" ]; then
    my_print "No directory passed to cleanup" 1
    exit 1
  fi
  my_print $1
  find $1 -name "*.o" -o -name "_*" | xargs rm
}

$1