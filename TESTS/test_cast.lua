-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests ={}
tests.t1 = function() 
  -- this must work because B1 must be multiple of 8 bytes
  c1 = Q.mk_col( {1,1,1,1}, "I4")
  c2 = Q.cast(c1, "B1")
  assert(Q.sum(c2):eval():to_num() == 4)
end
--=============================
tests.t2 = function()
  -- Note that since we are counting number of bits, same rslt
  c1 = Q.mk_col( {2,2,2,2}, "I4")
  c2 = Q.cast(c1, "B1")
  assert(Q.sum(c2):eval():to_num() == 4)
end
--=============================
tests.t3 = function()
  -- Now twice as many bits set 
  c1 = Q.mk_col( {3,3,3,3}, "I4")
  c2 = Q.cast(c1, "B1")
  assert(Q.sum(c2):eval():to_num() == 8)
end
--=============================
tests.t4 = function()
  -- can convert 8 I*s into 16 I4's or 32 I2's or 64 I1's
  c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I8")
  local num_elems_I8 = c1:length()
  sum1 = Q.sum(c1):eval():to_num()
  c2 = Q.cast(c1, "I4")
  assert(c2:num_elements() == 2*num_elems_I8)
  sum2 = Q.sum(c2):eval():to_num()
  assert(sum1 == sum2)

  c2 = Q.cast(c1, "I2")
  assert(c2:num_elements() == 4*num_elems_I8)

  c2 = Q.cast(c1, "I1")
  assert(c2:num_elements() == 8*num_elems_I8)
end
--=============================
tests.t5 = function()
  -- let's do some things that should not work
  -- this will not work because file size not multiple of element size
  c1 = Q.mk_col( {1,2,3}, "I4")
  print("START DELIBERATE FAILURE")
  status, c2 = pcall(Q.cast, c1, "F8")
  print("STOP  DELIBERATE FAILURE")
  assert(not status)
end
--===========================
tests.t6 = function() 
  -- this will not work because B1 must be multiple of 8 bytes
  c1 = Q.mk_col( {1,2,3}, "I4")
  print("START DELIBERATE FAILURE")
  status, c2 = pcall(Q.cast, c1, "B1")
  print("STOP  DELIBERATE FAILURE")
  assert(not status)
end
return tests
