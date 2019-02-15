local Q = require 'Q'
local ldnn = require 'Q/RUNTIME/DNN/lua/ldnn'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function(n)
  local n = n or 100000000
  -- this is a ridiculously large number of layers
  -- but this test is just to verify gc working properly
  local Xin = {}; 
    Xin[1] = Q.mk_col({1, 2, 3}, "F4"):eval()
    Xin[2] = Q.mk_col({1, 2, 3}, "F4"):eval()
    Xin[3] = Q.mk_col({1, 2, 3}, "F4"):eval()
  local Xout = {}; 
    Xout[1] = Q.mk_col({1, 2, 3}, "F4"):eval()

  local nhl = 64
  local nphl = {}
  for i = 1, nhl do 
    nphl[i] = i + 1 
  end
  for i = 1, n do 
    local x = ldnn.new("new", Xin, Xout, { nphl = nphl })
    if ( ( i % 1000 ) == 0 )  then
      print("Iterations " .. i)
    end
  end
  print("Success on test t1")
end
tests.t2 = function(n)
  local Xin = {}; Xin[1] = Q.mk_col({1, 2, 3}, "F4"):eval()
  local Xout = {}; Xout[1] = Q.mk_col({1, 2, 3}, "F4"):eval()

  local nhl = 3
  local nphl = {}
  for i = 1, nhl do 
    nphl[i] = i
  end
  local x = ldnn.new("new", Xin, Xout, { nphl = nphl, bsz = 10 })
  assert(x:check())
  x:fit()
  print("Success on test t2")
end
return tests

