-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
pca = require 'Q/OPERATORS/PCA/lua/pca'
assert(pca)
local x1 = Q.mk_col({7, 4, 6, 8, 8, 7, 5, 9, 7, 8}, "F4")
local x2 = Q.mk_col({4, 1, 3, 6, 5, 2, 3, 5, 4, 2}, "F4")
local x3 = Q.mk_col({3, 8, 5, 1, 7, 9, 3, 8, 5, 2}, "F4")
local X = {x1, x2, x3}
assert(pca)
local pca_info  = pca(X)
assert(type(pca_info) == "table")
assert(#pca_info == 3)
print("Completed pca")
for i=1,3 do
  assert(pca_info[i]:length() == 3)
  pca_info[i]:eval()
  --Q.print_csv(corrm[i], nil, "")
  --print("=====colbreak=======")
end
Q.print_csv(pca_info, nil, "")
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
