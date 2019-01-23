function install_apt_get_dependencies(){
  bash aio_utils.sh my_print "STARTING: Installing dependencies from apt-get"

  sudo apt-get update -y

  which cmake &> /dev/null
  RES=$?
  if [[ $RES -ne 0 ]] ; then
    sudo apt-get install make cmake -y
  else
    bash aio_utils.sh my_print "dependency cmake is already installed"
  fi

  which unzip &> /dev/null
  RES=$?
  if [[ $RES -ne 0 ]] ; then
    sudo apt-get install unzip -y # for luarocks
  else
    bash aio_utils.sh my_print "dependency unzip is already installed"
  fi

  apt-cache policy libncurses5-dev &> /dev/null
  RES=$?
  if [[ $RES -ne 0 ]] ; then
    sudo apt-get install libncurses5-dev -y # for lua-5.1.5
  else
    bash aio_utils.sh my_print "dependency libncurses5-dev is already installed"
  fi

  apt-cache policy libssl-dev &> /dev/null
  RES=$?
  if [[ $RES -ne 0 ]] ; then
    sudo apt-get install libssl-dev -y # for QLI
  else
    bash aio_utils.sh my_print "dependency libssl-dev is already installed"
  fi

  which m4 &> /dev/null
  RES=$?
  if [[ $RES -ne 0 ]] ; then
    sudo apt-get install m4 -y         # for QLI
  else
    bash aio_utils.sh my_print "dependency m4 is already installed"
  fi

  apt-cache policy libreadline-dev &> /dev/null
  RES=$?
  if [[ $RES -ne 0 ]] ; then
    sudo apt-get install libreadline-dev -y
  else
    bash aio_utils.sh my_print "dependency libreadline-dev is already installed"
  fi

  #installing LAPACK stuff
  apt-cache policy liblapacke-dev &> /dev/null
  RES=$?
  if [[ $RES -ne 0 ]] ; then
    sudo apt-get install liblapacke-dev -y
  else
    bash aio_utils.sh my_print "dependency liblapacke-dev is already installed"
  fi

  bash aio_utils.sh my_print "COMPLETED: Installing dependencies from apt-get"
}

$1
