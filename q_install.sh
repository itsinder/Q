rm -rf /usr/local/share/lua/5.1/Q
mkdir /usr/local/share/lua/5.1/Q
cp -r ./OPERATORS /usr/local/share/lua/5.1/Q
cp -r ./UTILS /usr/local/share/lua/5.1/Q
cp -r ./RUNTIME /usr/local/share/lua/5.1/Q
cp -r  q_export.lua /usr/local/share/lua/5.1/Q
cp -r  init.lua /usr/local/share/lua/5.1/Q

# FIX THIS, pick library from build target
cp $Q_ROOT/lib/libq_core.so /usr/lib
cp $Q_ROOT/include/q_core.h /usr/local/share/lua/5.1/Q