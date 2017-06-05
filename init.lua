-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")

-- require all the root operator files
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/PRINT/lua/print_csv"
require "Q/OPERATORS/MM/lua/mvmul"
require "Q/UTILS/lua/save"
require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3"
require "Q/OPERATORS/F1S1OPF2/lua/_f1s1opf2"
require "Q/OPERATORS/S_TO_F/lua/s_to_f"

require "Q/OPERATORS/F_TO_S/lua/_f_to_s"

require "Q/OPERATORS/_FOT_S/lua/_f_to_s"

return require 'Q/q_export'
