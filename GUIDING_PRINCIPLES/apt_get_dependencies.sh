function install_apt_get_dependencies(){
  source aio_utils.sh ; my_print "STARTING: Installing dependencies from apt-get"
  sudo apt-get update
  sudo apt-get install make cmake -y
  sudo apt-get install unzip -y # for luarocks
  sudo apt-get install libncurses5-dev -y # for lua-5.1.5
  sudo apt-get install libssl-dev -y # for QLI
  sudo apt-get install m4 -y         # for QLI
  sudo apt-get install libreadline-dev -y 
  source aio_utils.sh ; my_print "COMPLETED: Installing dependencies from apt-get"
}

$1
