local Q = require 'Q'

local tests = {}

tests.t1 = function()
  
  col1 = Q.mk_col({10,20,30,40,50}, "I4")

  Q.save("/tmp/saving_it.lua")
  local status, ret = pcall(Q.restore, "/tmp/saving_it.lua")
  
  assert(status, ret)
  assert(col1:num_elements() == 5)
  print("Successfully executed test t1")
end

return tests


