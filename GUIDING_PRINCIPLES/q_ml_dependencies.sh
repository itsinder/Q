#TODO: need to test it on new VM
bash my_print.sh "STARTING: Installing Q-ML dependencies"
  sudo apt-get install python3-pip
  sudo pip3 install numpy
  sudo pip3 install pandas
  sudo apt-get install build-essential python3-dev python3-setuptools python3-
  numpy python3-scipy python3-pip libatlas-dev libatlas3gf-base
  sudo pip3 install scikit-learn
bash my_print.sh "COMPLETED: Installing Q-ML dependencies"
