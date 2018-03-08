cmem = require 'libcmem' ; 

local tests = {}
local niter = 100000000

tests.t1 = function()
  -- basic test 
  for i = 1, niter do 
    local buf = cmem.new(1048576, "I4", "hello world")
    assert(type(buf) == "CMEM")
    if ( ( i % 100000 ) == 0 ) then print(i) end 
  end
end

  
return tests
