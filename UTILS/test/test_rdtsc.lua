local qc      = require 'Q/UTILS/lua/q_core'

-- testing get_time_usec C function call from lua
local tests = {}
tests.t1 = function()
  local count = 10
  local start_time = qc['get_time_usec']()
  for i=0,10000000 do  
    count = count + 10;
  end
  local end_time = qc['get_time_usec']()
  print("Total execution time", tonumber(end_time)-tonumber(start_time))
end

tests.t2 = function()
  local count = 10
  local start_val = qc.RDTSC()
  for i=0,10000000 do
    count = count + 10;
  end
  local end_val = qc.RDTSC()
  print(start_val, end_val)
  print("Total cpu cycles", tonumber(end_val)-tonumber(start_val))
end

return tests
