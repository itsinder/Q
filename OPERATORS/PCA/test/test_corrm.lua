-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local x1 = Q.mk_col({7, 4, 6, 8, 8, 7, 5, 9, 7, 8}, 'F8')
local x2 = Q.mk_col({4, 1, 3, 6, 5, 2, 3, 5, 4, 2}, 'F8')
local x3 = Q.mk_col({3, 8, 5, 1, 7, 9, 3, 8, 5, 2}, 'F8')
local X = {x1, x2, x3}
local corrm  = Q.corr_mat(X)
--assert(type(corrm) == "table")
--print("Completed corrm")
--Q.print_csv(corrm,  nil, "")
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
