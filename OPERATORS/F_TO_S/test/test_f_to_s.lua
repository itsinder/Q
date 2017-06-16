local Q = require 'Q'
local dbg = require 'Q/UTILS/lua/debugger'
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")

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


local z= Q.sum(c1)
z = get_val(z)
assert(z == 36 )
print("Completed " .. arg[0]) os.exit()

local z = Q.min(c1)
z = get_val(z)
assert(z == 1 )

local z = Q.max(c1)
z = get_val(z)
assert(z == 8 )

local z = Q.sum_sqr(c1)
z = get_val(z)
assert(z == XXXXX )
--=========================================
os.exit()
