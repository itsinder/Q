function install_luaffi(){
  source aio_utils.sh ; my_print "STARTING: Installing luaffi"
  git clone https://github.com/jmckaskill/luaffi.git
  cd luaffi
  make
  # EX_PATH=`echo $LUA_CPATH | awk -F'/' 'BEGIN{OFS=FS} {$NF=""; print $0}'`;
  EX_PATH="${Q_ROOT}/lib"
  echo $EX_PATH
  cp ffi.so $EX_PATH
  cd ../
  sudo rm -rf luaffi
  source aio_utils.sh ; my_print "COMPLETED: Installing luaffi"
}

$1
