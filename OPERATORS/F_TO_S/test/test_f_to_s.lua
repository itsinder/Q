-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
local n = c1:length()

tests.t_sum = function ()
  local z = Q.sum(c1)
  assert(type(z) == "Reducer")
  local status = true repeat status = z:next() until not status
  local val, num = z:value()
  assert(type(val) == "Scalar")
  assert(val:to_num() == 36 )
  assert(Q.sum(c1):eval():to_num() == n*(n+1)/2)
  print("t_sum succeeded")
end

tests.t_min = function ()
  local z = Q.min(c1)
  assert(type(z) == "Reducer")
  local status = true repeat status = z:next() until not status
  local val, num = z:value()
  assert(type(val) == "Scalar")
  assert(val:to_num() == 1 )
  assert(Q.min(c1):eval():to_num() == 1)
  print("t_min succeeded")
end

tests.t_max = function ()
  local z = Q.max(c1)
  assert(type(z) == "Reducer")
  local status = true repeat status = z:next() until not status
  local val, num = z:value()
  assert(type(val) == "Scalar")
  assert(val:to_num() == 8 )
  assert(Q.max(c1):eval():to_num() == 8)
  print("t_max succeeded")
end

tests.t_sum_sqr = function ()
  local z = Q.sum_sqr(c1)
  assert(type(z) == "Reducer")
  local status = true repeat status = z:next() until not status
  local val, num = z:value()
  assert(type(val) == "Scalar")
  assert(val:to_num() == 204 )
  assert(Q.sum_sqr(c1):eval():to_num() == (n * (n+1) * (2*n+1) / 6))
  print("t_sum_sqr succeeded")
end

return tests

