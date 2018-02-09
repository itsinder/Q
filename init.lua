-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")

-- require all the root operator files
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/PRINT/lua/print_csv"
require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3"
require 'libsclr'
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER
--require 'Q/QTILS/lua/vvmax'
--require 'Q/QTILS/lua/vvseq'
--require 'Q/QTILS/lua/vvpromote'
--require 'Q/QTILS/lua/fold'
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER

return require 'Q/q_export'
