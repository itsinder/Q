local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local c1 = Q.mk_col({-0.494191, -0.472019, 0.730111}, "F8")
local c2 = Q.mk_col({-0.558050, 0.816142, 0.149979}, "F8")
local c3 = Q.mk_col({0.6667, 0.3333, 0.6667}, "F8")

local n = 3

local c1mean = Q.sum(c1):eval() / n
local c2mean = Q.sum(c2):eval() / n 
local c3mean = Q.sum(c3):eval() / n 

local diff1 = Q.vssub(c1, c1mean)
local sigma1 = math.sqrt( (1 / (n - 1)) * Q.sum_sqr(diff1):eval() )
local c1 = Q.vsdiv(diff1, sigma1):eval()
Q.print_csv(diff1, nil, "")
print(type(diff1))
print(type(sigma1))
print(type(c1))
os.exit()



Q.print_csv(c1, nil, "")

print("Completed " .. arg[0])
os.exit()

