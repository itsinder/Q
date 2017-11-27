-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
	-- TEST MIN MAX WITH SORT
	local meta = {
		{ name = "empid", has_nulls = true, qtype = "I4", is_load = true }
	}
	local result = Q.load_csv("I4.csv", meta)
	assert(type(result) == "table")
	for i, v in pairs(result) do
  	local x = result[i]
  	assert(type(x) == "lVector")
		-- Sort dsc & find min & max
		Q.sort(x, "dsc")
		local y = Q.min(x)
		local status = true repeat status = y:next() until not status
		assert(y:value():to_num() == 10 )
		assert(Q.min(x):eval():to_num() == 10)
		local min = Q.min(x):eval():to_num()

		local z = Q.max(x)
		local status = true repeat status = z:next() until not status
		assert(z:value():to_num() == 50 )
		assert(Q.max(x):eval():to_num() == 50)
		local max = Q.max(x):eval():to_num()
--[[
	-- Sort asc & find min & max
	local meta = {
 		{ name = "empid", has_nulls = true, qtype = "I4", is_load = true }
	}
	local result = Q.load_csv("I4.csv", meta)
	assert(type(result) == "table")
	for i, v in pairs(result) do 
    local x = result[i]
  	assert(type(x) == "lVector") ]]--
		Q.sort(x, "asc")
		local y1 = Q.min(x)
		local status = true repeat status = y1:next() until not status
		assert(y1:value():to_num() == 10 )
		assert(Q.min(x):eval():to_num() == 10)
		local min_new = Q.min(x):eval():to_num()

		local z1 = Q.max(x)
		local status = true repeat status = z1:next() until not status
		assert(z1:value():to_num() == 50 )
		assert(Q.max(x):eval():to_num() == 50)
		local max_new = Q.max(x):eval():to_num()

	-- Verifying min max remains the same.
  -- ToDo: How to capture values of min & max to br compared later?
	assert(min == min_new, "Value mismatch in the case of minimum")
	assert(max == max_new, "Value mismatch in the case of minimum")
  end
  print("test t1 succeeded")
end
--=======================================
return tests
