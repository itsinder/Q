local ldnn = require 'Q/RUNTIME/DNN/lua/ldnn'

local tests = {}
tests.t1 = function(n)
  local n = n or 100000000
  -- this is a ridiculously large number of layers
  -- but this test is just to verify gc working properly
  local nl = 100000
  local npl = {}
  for i = 1, nl do 
    npl[i] = i
  end
  for i = 1, n do 
    x = ldnn.new("new", { nl == nl, npl = npl, bsz = 10 })
    if ( ( i % 1000 ) == 0 )  then
      print("Iterations " .. i)
    end
  end
  print("Success on test t1")
end
return tests

