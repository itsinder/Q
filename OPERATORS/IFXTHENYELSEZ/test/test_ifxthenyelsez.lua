-- FUNCTIONAL
local Q = require 'Q'
Scalar = require 'libsclr' ; 
require 'Q/UTILS/lua/strict'

local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
local y = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
local z = Q.mk_col({-1, -2, -3, -4, -5, -6, -7}, "I4")
local exp_w = Q.mk_col({1, -2, 3, -4, 5, -6, 7}, "I4")
local w = Q.ifxthenyelsez(x, y, z)
local n = Q.sum(Q.vveq(w, exp_w))
m = n:eval()
assert(m == 7)
-- w:eval()
-- Q.print_csv({w, exp_w, y, z}, nil, "")
--==========================
z = Scalar.new("10", "I4")
local w = Q.ifxthenyelsez(x, y, z)
local n = Q.sum(Q.vseq(w, 10))
m = n:eval()
assert(m == 3)
-- w:eval()
-- Q.print_csv({w, exp_w, y}, nil, "")
--===========================
y = Scalar.new("100", "I4")
z = Q.mk_col({-1, -2, -3, -4, -5, -6, -7}, "I4")
w = Q.ifxthenyelsez(x, y, z)
local n = Q.sum(Q.vseq(w, 100))
m = n:eval()
assert(m == 4)
-- w:eval()
-- Q.print_csv({w, z}, nil, "")
--===========================
y = Scalar.new("100", "I4")
z = Scalar.new("-100", "I4")
w = Q.ifxthenyelsez(x, y, z)
local n = Q.sum(Q.vseq(w, 100))
m = n:eval()
assert(m == 4)
-- w:eval()
-- Q.print_csv({w, x}, nil, "")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
