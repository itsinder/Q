-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
-- local dbg = require 'Q/UTILS/lua/debugger'
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")

local z= Q.sum(c1)
assert(type(z) == "Scalar")
-- dbg()
local status = true 
repeat 
  status = z:next() 
until not status
local val, num = z:value()
assert(val == 36 )

-- assert(num == 8 ) TODO  Verify what getter returns 

assert(Q.sum(c1):eval() == 36)

local z = Q.min(c1)
local status = true repeat status = z:next() until not status
local val = z:value()
assert(val == 1 )
assert(Q.min(c1):eval() == 1)

local z = Q.max(c1)
local status = true repeat status = z:next() until not status
local val = z:value()
assert(val == 8 )
assert(Q.max(c1):eval() == 8)

local z = Q.sum_sqr(c1)
local status = true repeat status = z:next() until not status
local val = z:value()
local n = c1:length()
assert(val ==(n * (n+1) * (2*n+1) )/6) 

function fold( fns, vec)
local  gens = {}
  for i, v in ipairs(fns) do
    gens[i] = Q[v](vec)
    -- print(type(gens[i]))
  end
  local status = true
  repeat
    for i, v in ipairs(fns) do
      status = gens[i]:next() 
    end
  until not status
  local rvals = {}
  for i, v in ipairs(gens) do
    rvals[i] = gens[i]:value() 
  end
  for i, v in ipairs(rvals) do 
    print(rvals[i])
  end
  return unpack(rvals)
end

x, y, z = fold({ "sum", "min", "max" }, c1)
print (x, y, z)
print("SUCCESS for " .. arg[0])
require 'Q/UTILS/lua/strict'
os.exit()
