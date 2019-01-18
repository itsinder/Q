function install_luarocks_from_source(){
  source aio_utils.sh ; my_print "STARTING: Installing lua rocks"
  wget https://luarocks.org/releases/luarocks-2.4.1.tar.gz
  tar zxpf luarocks-2.4.1.tar.gz
  cd luarocks-2.4.1
  ./configure; sudo make bootstrap
  cd ../
  rm -rf luarocks-2.4.1
  source aio_utils.sh ; my_print "COMPLETED: Installing lua rocks"
}

function install_luarocks_dependencies(){
  source aio_utils.sh ; my_print "STARTING: Installing dependencies using luarocks"
  sudo luarocks install penlight
  sudo luarocks install luaposix
  sudo luarocks install luv
  sudo luarocks install busted
  sudo luarocks install luacov
  sudo luarocks install cluacov
  sudo luarocks install http      # for QLI
  sudo luarocks install linenoise # for QLI
  source aio_utils.sh ; my_print "COMPLETED: Installing dependencies using luarocks"
}

$1
