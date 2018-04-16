Run below commands from 'luajit_vs_luaffi_independent_test' directory

- Access 'luajit_vs_luaffi_independent_test' directory
$ cd luajit_vs_luaffi_independent_test

- Generate library file (".so" file)
$ bash vvadd_I4_I4_I4.sh

- Run test
$ <luajit/lua> vvadd_src.lua

You will get C execution time on console
