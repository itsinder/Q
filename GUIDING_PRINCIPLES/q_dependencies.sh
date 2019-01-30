source aio_utils.sh ; my_print "STARTING: Installing q dependencies using luarocks"
#not needed right now
#sudo luarocks install luaposix
#sudo luarocks install luv
#sudo luarocks install busted
#sudo luarocks install luacov
#sudo luarocks install cluacov
sudo luarocks install http      # for QLI
sudo luarocks install linenoise # for QLI
source aio_utils.sh ; my_print "COMPLETED: Installing q dependencies using luarocks"
