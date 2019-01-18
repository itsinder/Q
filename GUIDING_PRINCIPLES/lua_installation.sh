function install_lua_from_apt_get(){
  source aio_utils.sh ; my_print "STARTING: Installing lua from apt-get"
  sudo apt-get install lua5.1 -y
  sudo apt-get install liblua5.1-dev -y
  source aio_utils.sh ; my_print "COMPLETED: Installing lua from apt-get"
}

function install_lua_from_source(){
  source aio_utils.sh ; my_print "STARTING: Installing lua from source"
  wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
  tar -xvzf lua-5.1.5.tar.gz
  cd lua-5.1.5/
  make linux
  sudo make install
  sudo cp ./etc/lua.pc /usr/lib/pkgconfig/
  cd ../
  rm -rf lua-5.1.5 lua-5.1.5.tar.gz
  source aio_utils.sh ; my_print "COMPLETED: Installing lua from source"
}

$1
