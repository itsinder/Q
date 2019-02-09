local ldnn = require 'Q/RUNTIME/DNN/lua/ldnn'

local tests = {}
tests.t1 = function(n)
  local n = n or 100000000
  -- this is a ridiculously large number of layers
  -- but this test is just to verify gc working properly
  local nl = 64
  local npl = {}
  for i = 1, nl do 
    npl[i] = i
  end
  for i = 1, n do 
    x = ldnn.new("new", { nl == nl, npl = npl, bsz = 10 })
    if ( ( i % 10 ) == 0 )  then
      print("Iterations " .. i)
    end
  end
  print("Success on test t1")
end
tests.t2 = function(n)
  local nl = 3
  local npl = {}
  for i = 1, nl do 
    npl[i] = i
  end
  x = ldnn.new("new", { nl == nl, npl = npl, bsz = 10 })
  assert(x:check())
  print("Success on test t2")
end
return tests

