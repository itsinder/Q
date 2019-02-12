bash my_print.sh "STARTING: Installing Q-test dependencies using luarocks"
sudo luarocks install luaposix #posix.time lib has been used for capturing timers
sudo luarocks install penlight #pl lib has been used for Q unit test
sudo luarocks install luacov #luacov is used in Q/TEST_RUNNER/q_testrunner.lua :line 70
bash my_print.sh "COMPLETED: Installing Q-test dependencies using luarocks"
