## Calculate Q.vvadd total execution time

$ cd Q/experimental/q_performance_testing
$ luajit test_vvadd.lua

E.g
root@ubuntu:/opt/zbstudio/myprograms/Q/experimental/q_performance_testing# luajit test_vvadd.lua
vvadd total execution time : 22.218212
=========================

## Calculate vvadd C execution time

- Copy Q/experimental/q_performance_testing/init.lua to Q/init.lua
- Copy Q/experimental/q_performance_testing/expander_f1f2opf3.lua to Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3.lua
- run test
$ cd Q/experimental/q_performance_testing
$ luajit test_vvadd.lua

E.g
root@ubuntu:/opt/zbstudio/myprograms/Q/experimental/q_performance_testing# luajit test_vvadd.lua
vvadd total execution time : 22.44
=========================
vvadd_I4_I4_I4  0.522636
