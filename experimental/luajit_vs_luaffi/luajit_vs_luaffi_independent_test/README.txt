Run below commands from 'luajit_vs_luaffi_independent_test' directory

- Access 'luajit_vs_luaffi_independent_test' directory
$ cd experimental/luajit_vs_luaffi/luajit_vs_luaffi_independent_test/

- Run test (provide require interpreter name as first argument)
$ bash run_vvadd.sh <luajit/lua>

You will get C execution time on console

Note: num_elements are set to 100000000, if you want to update num_elements then modify run_vvadd.lua
