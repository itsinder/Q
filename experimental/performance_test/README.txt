This directory contains files reqquired for performance comparison between "C call using luajit ffi" Vs "C call using lua-C api"

Following are the steps to run the test

-- Run the test from 'performance_test' directory
$ cd Q/experimental/performance_test

- Create library file
$ bash build.sh
This will create 'libadd.so' (used in case of luajit ffi) & 'add.so' (used in case of lua-C api)

- Run luajit ffi C test
$ time luajit run_add_luajit_ffi.lua

- Run lua-C api C test
$ time luajit run_add_lua_c_api.lua


Results that I got on my VM are as below
Average timing:
luajit ffi C test = 5.681 sec
lua-C api C test = 26.6723 sec
