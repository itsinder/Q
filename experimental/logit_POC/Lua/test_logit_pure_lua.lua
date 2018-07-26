local qconsts	= require 'Q/UTILS/lua/q_consts'
local timer = require 'posix.time'

local function logit(in_buf, num_elements, out_buf)
  for i = 1, num_elements do -- core operation is as follows
    out_buf[i] = 1.0 / (1.0 + math.exp(-1 * in_buf[i]))
  end
  return out_buf
end

local num_elements = 100000000
local in_buf = {}
local out_buf = {}

-- Initialize input arrays
for i = 1, num_elements do
  in_buf[i] = 2
end


local start_time = timer.clock_gettime(0)
local res = logit(in_buf, num_elements, out_buf )
local stop_time = timer.clock_gettime(0)
local time =  (stop_time.tv_sec*10^6 +stop_time.tv_nsec/10^3 - (start_time.tv_sec*10^6 +start_time.tv_nsec/10^3))/10^6

print("Time required for pure lua execution is = " .. tostring(time))

-- Validate result
for i = 1, num_elements do
  -- print(res[i])
  --assert(res[i] == i*2)
end
