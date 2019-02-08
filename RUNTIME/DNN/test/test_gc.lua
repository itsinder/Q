local ldnn = require 'Q/RUNTIME/DNN/lua/ldnn'

local tests = {}
tests.t1 = function(n)
  n = n or 1 -- TODO make this a a large number 1000000
  for i = 1, n do 
    print("hello world ", i)
    x = ldnn.new("new", { nl == 3, npl = { 3, 4, 1 }, bsz = 10 })
    print("hello world again", i)
  end
  print("Success on test t1")
end
return tests

