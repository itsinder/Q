-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")

-- require all the root operator files
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/PRINT/lua/print_csv"
require "Q/OPERATORS/MM/lua/mvmul"
require "Q/UTILS/lua/save"
require "Q/OPERATORS/F1F2OPF3/lua/f1f2opf3"

return require 'Q/q_export'
