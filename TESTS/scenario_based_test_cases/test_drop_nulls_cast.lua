-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
Scalar = require 'libsclr'

local tests = {}
tests.t1 = function ()

	-- Create vector 'a' with Q.rand or by Q.seq
	local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 5} )
	-- Create binary vector b through Q.rand
	local b = Q.rand( { lb = 100, ub = 200, qtype = "I8", len = 5 } )
	b:eval()
	local b1 = Q.cast(b, "B1")
	local s2 = 10 - Q.sum(b1):eval():to_num()
	local sval = Scalar.new("10", "I4")
	a:make_nulls(b)
	local c = Q.drop_nulls(a, sval)
	assert(Q.sum(c):eval():to_num() == 76)
  print("Succeeded in test drop nulls cast t1")
end
  --=======================================
return tests


