-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")

-- require all the root operator files
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/PRINT/lua/print_csv"
-------OLD-----------------------------------
local plpath = require 'pl.path'

local q_root = assert(os.getenv("Q_ROOT"), "Q_ROOT must be set")
assert(plpath.isdir(q_root), "Q_ROOT not found")
assert(plpath.isdir(q_root .. "/lib/" ), "Q_ROOT/lib not found")
assert(plpath.isdir(q_root .. "/include/" ), "Q_ROOT/include not found")

-- TODO check
----------------------------------
return require 'Q/q_export'