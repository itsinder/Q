#installing git
package=$(which git )
if [ "$package" = "" ]; then 
	sudo apt-get install git
else
	echo "git already installed"
fi;


#installation of lua 5.1 
package=$(dpkg -s lua5.1  | grep '^Version:')
echo $package

if [ "$package" = "Version: 5.1.5-5ubuntu0.1" ] || [ "$package" = "Version: 5.1.3-5ubuntu0.1" ]; then 
	echo "lua5.1 package Matched" #no installation required if version matched
else echo "lua 5.1 package not installed or Matched $package" 
	sudo apt-get install lua5.1
fi;


#installation of liblua5.1
if [ -f /usr/include/lua5.1/lua.h ] ;then
	echo "lualib5.1 already exists"
else
	sudo apt-get install liblua5.1-dev
fi


#installation of luajit 2.0.4
package=$(which luajit)
echo $package
if [ "$package" = "/usr/local/bin/luajit" ]; then 
	echo "luajit 2.0.4 package Matched" #no installation required if version matched
else echo "luajit2.0.4 package not installed or Matched $package" #we can write install steps here
	wget -P /tmp http://luajit.org/download/LuaJIT-2.0.4.tar.gz
	cd /tmp
	tar -xvzf LuaJIT-2.0.4.tar.gz
	cd LuaJIT-2.0.4/
	make && sudo make install
fi;


#installation of LuaRocks
package=$(luarocks | grep '^LuaRocks')
echo $package
if [ "$package" = "LuaRocks 2.4.1, a module deployment system for Lua" ]; then 
echo "luarocks package Matched" #no installation required if version matched
else echo "luarocks package is NOT Matched $package" #we can write install steps here
	wget -P /tmp http://luarocks.github.io/luarocks/releases/luarocks-2.4.2.tar.gz
	cd /tmp
	tar -xvzf luarocks-2.4.2.tar.gz
	cd luarocks-2.4.2/
	./configure
	make build && sudo make install
fi;
	
# install lua socket 
sudo luarocks install luasocket 3.0-rc1

# install luaunit
sudo luarocks install luaunit 3.2.1-1

#install penlight 
sudo luarocks install penlight 1.4.1-1


#installation of luaffi
if [ -f /usr/local/lib/lua/5.1/ffi.so ] ;then
	echo "lauffi already installed"
else
	mkdir /tmp/luaffi 
	cd /tmp
	git clone https://github.com/jmckaskill/luaffi/ luaffi
	sed -i '6s@.*@LUA_CFLAGS=`$(PKG_CONFIG) --cflags lua5.2 2>/dev/null || $(PKG_CONFIG) --cflags lua5.1` @' Makefile
	make clean all
	sudo cp ffi.so /usr/local/lib/lua/5.1/	
fi


#cloning to Q repository
cd ~
mkdir Q/
git clone https://github.com/NerdWalletOSS/Q.git Q
cd Q/
git checkout dev


#to install Zerobrane-IDE
wget -P /tmp https://download.zerobrane.com/ZeroBraneStudioEduPack-1.50-linux.sh
cd /tmp
bash ZeroBraneStudioEduPack-1.50-linux.sh 


#install emacs
package=$(which emacs)
echo $package
if [ "$package" = "/usr/bin/emacs" ]; then 
	echo "package Matched" #no installation required if version matched
else echo "package not installed or Matched $package" #we can write install steps here
	sudo apt-get install emacs24	
fi;

