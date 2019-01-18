function install_debug_lua_from_source(){
  source aio_utils.sh ; my_print "STARTING: Installing lua with -g flag"
  wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
  tar -xvzf ./lua-5.1.5.tar.gz
  cd lua-5.1.5/
  # sed -i '17s/MYCFLAGS=/MYCFLAGS= -g/' src/Makefile
  # sed -i '99s/MYFLAGS=/MYFLAGS=-g /' src/Makefile
  sed -i '11s/CFLAGS=/CFLAGS= -g/' src/Makefile
  make linux
  sudo make install
  sudo ln -sf /usr/local/bin/lua /usr/local/bin/L
  sudo cp ./etc/lua.pc /usr/lib/pkgconfig/
  cd ../
  sudo rm -rf lua-5.1.5
  source aio_utils.sh ; my_print "COMPLETED: Installing lua with -g flag"
}

$1
