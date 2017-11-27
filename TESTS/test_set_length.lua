-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
	local x_len = 65537
	local y = Q.rand({ lb = 0, ub = 1, seed = 1234, qtype = "I1", len = x_len } )
	local c1 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
	local c2 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
	local X = {c1, c2}

	local A = {}
	local lengths = {}
	for i, _ in ipairs(X) do 
  	lengths[i] = 0
	end

	for iter = 1, 100 do 
		if ( iter == 1 ) then 
		for i, X_i in ipairs(X) do
			assert(X_i:materialized() == false)
			assert(X_i:length() == 0)
			end
		else
    for i, X_i in ipairs(X) do
    	assert(X_i:materialized() == true)
      assert(X_i:length() > 0)
    end
  end
  for i, X_i in ipairs(X) do
    if ( lengths[i] == 0 ) then
      lengths[i] = X_i:length()
    else
      assert(lengths[i] == X_i:length())
    end
    A[i] = {}
    for j, X_j in ipairs(X) do
      A[i][j] = Q.sum(Q.vvmul(X_i, X_j))
      local chk = A[i][j]:eval()
    end
  end
end
  print("test t1 succeeded")
end
--=======================================
return tests

