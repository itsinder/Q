local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

-- TEST MIN MAX WITH SORT
meta = {
 { name = "cd", has_nulls = true, qtype = "I2", is_load = true }
}
local result = Q.load_csv("I4_null.csv", meta)
assert(type(result) == "table")
for i, v in pairs(result) do
    x = result[i]
  assert(type(x) == "lVector")
end
 -- Q.print_csv(x, nil, "")

-- find min & max
local y = Q.min(x)
local status = true repeat status = y:next() until not status
local val = y:value()
assert(val == 0 )
assert(Q.min(x):eval() == 0)
min = Q.min(x):eval()
print(min)

local z = Q.max(x)
print(z)
local status = true repeat status = z:next() until not status
local val = z:value()
assert(val == 0 )
assert(Q.max(x):eval() == 0)
max = Q.max(x):eval()
print(max)


assert(min == max, "Value mismatch in the case of min & max of a null vector")


print("##########")
print("MIN MAX ON NULL VECTOR DONE !!")
print("------------------------------------------")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
