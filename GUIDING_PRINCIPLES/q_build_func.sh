function clean_q(){
  source aio_utils.sh ; my_print "STARTING: Cleaning Q"
  cd ../UTILS/build
  make clean
  cd -
  source aio_utils.sh ; my_print "COMPLETED: Cleaning Q"
}

function build_q(){
  source aio_utils.sh ; my_print "STARTING: Building Q"
  cd ../UTILS/build
  make all
  cd -
  source aio_utils.sh ; my_print "COMPLETED: Building Q"
}

$1
