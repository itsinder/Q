local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- TEST MIN MAX WITH SORT
meta = {
 { name = "empid", has_nulls = true, qtype = "I4", is_load = true }
}
local result = Q.load_csv("I4.csv", meta)
assert(type(result) == "table")
for i, v in pairs(result) do
    x = result[i]
  assert(type(x) == "lVector")
end
 -- Q.print_csv(x, nil, "")


-- Sort dsc & find min & max
Q.sort(x, "dsc")
local y = Q.min(x)
local status = true repeat status = y:next() until not status
local val = y:value()
assert(val == 10 )
assert(Q.min(x):eval() == 10)
min = Q.min(x):eval()
print(min)

local z = Q.max(x)
print(z)
local status = true repeat status = z:next() until not status
local val = z:value()
assert(val == 50 )
assert(Q.max(x):eval() == 50)
max = Q.max(x):eval()
print(max)

------------------------------------------------

-- Sort asc & find min & max
meta = {
 { name = "empid", has_nulls = true, qtype = "I4", is_load = true }
}
local result = Q.load_csv("I4.csv", meta)
assert(type(result) == "table")
for i, v in pairs(result) do
    x = result[i]
  assert(type(x) == "lVector")
end
Q.sort(x, "asc")
local y1 = Q.min(x)
local status = true repeat status = y1:next() until not status
local val = y1:value()
assert(val == 10 )
assert(Q.min(x):eval() == 10)
min_new = Q.min(x):eval()
print(min_new)

local z1 = Q.max(x)
print(z1)
local status = true repeat status = z1:next() until not status
local val = z1:value()
assert(val == 50 )
assert(Q.max(x):eval() == 50)
max_new = Q.max(x):eval()
print(max_new)

-- Verifying min max remains the same.

assert(min == min_new, "Value mismatch in the case of minimum")
assert(max == max_new, "Value mismatch in the case of minimum")


  print("##########")
print("MIN MAX ON SORT Test DONE !!")
print("------------------------------------------")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
