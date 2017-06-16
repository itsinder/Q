local Q = require 'Q'
local dbg = require 'Q/UTILS/lua/debugger'
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")

--[[
function get_val(coro)
local res = 0
local status, x
repeat
   local y
   status, y = coroutine.resume(coro)
   if y ~= nil then 
      print(y, y[0].cum_val)
      x = y
   end
until coroutine.status(coro) == "dead" 
return tonumber(x[0].cum_val)
end
--]]


local z= Q.sum(c1)
assert(type(z) == "Scalar")
local status = true repeat status = z:next() until not status
local val = z:value()
assert(val == 36 )

local z = Q.min(c1)
local status = true repeat status = z:next() until not status
local val = z:value()
assert(val == 1 )


local z = Q.max(c1)
local status = true repeat status = z:next() until not status
local val = z:value()
assert(val == 8 )
print("Completed " .. arg[0]); os.exit()

local z = Q.sum_sqr(c1)
local status = true repeat status = z:next() until not status
local val = z:value()
local n = c1:length()
assert(val ==(n * (n+1) * (2*n+1) )/6) 
print("Completed " .. arg[0]); os.exit()
--=========================================
