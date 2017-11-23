-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}
tests.t1 = function ()
-- this must work because B1 must be multiple of 8 bytes
  local c1 = Q.mk_col( {1,1,1,1}, "I4")
  local c2 = Q.cast(c1, "B1")
  local n1, n2 = Q.sum(c2):eval()
  assert(n1:to_num() == 4)
  assert(n2:to_num() == 4*32)
  print("test t1 succeeded")
end

tests.t2 = function ()
--=========== Note that since we are counting number of bits, same rslt
	local c1 = Q.mk_col( {2,2,2,2}, "I4")
	local c2 = Q.cast(c1, "B1")
	local n1, n2 = Q.sum(c2):eval()
  assert(n1:to_num() == 4)
  assert(n2:to_num() == 4*32)
  print("test t2 succeeded")
end

tests.t3 = function ()
--============================= Now twice as many bits set 
	local c1 = Q.mk_col( {3,3,3,3}, "I8")
	local c2 = Q.cast(c1, "B1")
	local n1, n2 = Q.sum(c2):eval()
  assert(n1:to_num() == 8)
  assert(n2:to_num() == 8*32)
  print("test t3 succeeded")
end

tests.t4 = function ()
--=============================
	local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I8")
	local sum1 = Q.sum(c1):eval():to_num()
	local c2 = Q.cast(c1, "I4")
	assert(c2:num_elements() == 16)
	local sum2 = Q.sum(c2):eval():to_num()
	assert(sum1 == sum2)
  print("test t4 succeeded")
end

tests.t5 = function ()
-- let's do some things that should not work
-- this will not work because file size not multiple of element size
	local c1 = Q.mk_col( {1,2,3}, "I4")
	local status, c2 = pcall(Q.cast, c1, "F8")
	assert(not status)
  print("test t5 succeeded")
end

tests.t6 = function ()
-- this will not work because B1 must be multiple of 8 bytes
	local c1 = Q.mk_col( {1,2,3}, "I4")
	local status, c2 = pcall(Q.cast, c1, "B1")
	assert(not status)
  print("test t6 succeeded")
end
--=======================================
return tests
