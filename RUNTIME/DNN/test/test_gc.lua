local Q = require 'Q'
local ldnn = require 'Q/RUNTIME/DNN/lua/ldnn'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function(n)
  local n = n or 100000000
  -- this is a ridiculously large number of layers

  local npl = {}
  local nl = 64
  for i = 1, nl do npl[i] = nl - i + 1 end

  for i = 1, n do 
    local x = ldnn.new({ npl = npl})
    assert(type(x) == "ldnn")
    if ( ( i % 1000 ) == 0 )  then
      print("Iterations " .. i)
    end
  end
  print("Success on test t1")
end
--========================================
tests.t2 = function(n)
  local n = n or 100000000
  local Xin = {}; 
    Xin[1] = Q.mk_col({1, 2, 3}, "F4"):eval()
    Xin[2] = Q.mk_col({10, 20, 30}, "F4"):eval()
    Xin[3] = Q.mk_col({100, 200, 300}, "F4"):eval()
  local Xout = {}; 
    Xout[1] = Q.mk_col({1000, 2000, 3000}, "F4"):eval()

  local npl = {}
  npl[1] = 3
  npl[2] = 4
  npl[3] = 1
  local x = ldnn.new({ npl = npl} )
  assert(x:check())
  for i = 1, n do 
    x:set_io(Xin, Xout)
    assert(x:check())
    x:unset_io()
    assert(x:check())
    if ( ( i % 1000 ) == 0 )  then
      print("Iterations " .. i)
    end
  end
  -- x:fit()
  print("Success on test t2")
end
return tests

