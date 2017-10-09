-- When 2 complete vectors are added its resultant can be sorted. At present an issue to be fixed 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
local c2 = Q.mk_col( {20,35,26,50,11,30,45,17}, "I4")
local z = Q.vvadd(c1, c2)
z:eval()
Q.sort(z, "asc")
Q.print_csv(z, nil, "")
