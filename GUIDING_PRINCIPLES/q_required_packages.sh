bash my_print.sh "STARTING: Installing Q-required packages"
sudo luarocks install luaposix
#for now included pkg "penlight" as our Q build is using it
sudo luarocks install penlight
bash my_print.sh "COMPLETED: Installing Q-required packages"
