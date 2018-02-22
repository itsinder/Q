-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")

-- require all the root operator files
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/PRINT/lua/print_csv"
require "Q/OPERATORS/SORT/lua/sort"
require "Q/OPERATORS/CLONE/lua/clone"
require "Q/OPERATORS/CAT/lua/cat"
require "Q/OPERATORS/IDX_SORT/lua/idx_sort"
require "Q/OPERATORS/MM/lua/mv_mul"
require "Q/UTILS/lua/save"
require "Q/UTILS/lua/restore"
require "Q/UTILS/lua/view_meta"
require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3"
require "Q/OPERATORS/F1S1OPF2/lua/_f1s1opf2"
require "Q/OPERATORS/S_TO_F/lua/_s_to_f"
require "Q/OPERATORS/F_TO_S/lua/_f_to_s"
require "Q/OPERATORS/AINB/lua/ainb"
require "Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez"
require "Q/OPERATORS/DROP_NULLS/lua/drop_nulls"
require "Q/OPERATORS/CAST/lua/cast"
require "Q/OPERATORS/AX_EQUALS_B/lua/linear_solver"
require "Q/OPERATORS/APPROX/QUANTILE/lua/approx_quantile"
require "Q/OPERATORS/APPROX/FREQUENT/lua/approx_frequent"
require "Q/OPERATORS/PCA/lua/corr_mat"
require 'libsclr'
require 'Q/OPERATORS/WHERE/lua/where'
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER
require 'Q/QTILS/lua/vvmax'
require 'Q/QTILS/lua/vvseq'
require 'Q/QTILS/lua/vvpromote'
require 'Q/QTILS/lua/fold'
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER

return require 'Q/q_export'
