Use below command (set paths as appropriate) to create luadc.so

c99 -shared -o luadc.so -fPIC -I/usr/include/lua5.1 -I/home/srinath/dyncall-0.9/include luadc.c /usr/local/lib/libdyncall_s.a /usr/local/lib/libdynload_s.a /usr/local/lib/libdyncallback_s.a
