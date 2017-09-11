-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local eigen = require 'Q/OPERATORS/PCA/lua/eigen'

local x1 = Q.mk_col({3, 2, 4}, 'F8')
local x2 = Q.mk_col({2, 0, 2}, 'F8')
local x3 = Q.mk_col({4, 2, 3}, 'F8')
local X = {x1, x2, x3}
local eigen_info = eigen(X)
assert(type(eigen_info) == "table")
print("Completed eigen")
Q.print_csv(eigen_info["eigenvalues"],  nil, "")
Q.print_csv(eigen_info.eigenvectors, nil, "")
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
