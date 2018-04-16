Run below commands from 'luajit_vs_luaffi_independent_test' directory

- Access 'luajit_vs_luaffi_independent_test' directory
$ cd luajit_vs_luaffi_independent_test

- Generate library file (".so" file)
$ bash test_vvadd.sh

- Run test
$ <luajit/lua> test_vvadd.lua

You will get C execution time on console

Note: num_elements are set to 100000000, if you want to update num_elements then modify test_vvadd.lua
