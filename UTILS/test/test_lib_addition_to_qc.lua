-- require 'strict'
local Q_SRC_ROOT = os.getenv('Q_SRC_ROOT')
local Q_ROOT = os.getenv('Q_ROOT')
os.execute(string.format("rm %s/include/boom.h", Q_ROOT))
os.execute(string.format("rm %s/lib/libboom.so", Q_ROOT))
assert(os.execute(string.format("luajit %s/UTILS/test/test_q_core_compile.lua", Q_SRC_ROOT)) == 0, "Compiling lib must pass")
local qc = require 'Q/UTILS/lua/q_core'
qc.boom()

