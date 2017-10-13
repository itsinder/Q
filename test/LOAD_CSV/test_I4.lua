local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'


-- LOAD CSV TEST
meta = {
 { name = "empid", has_nulls = true, qtype = "I4", is_load = true },
 { name = "yoj", has_nulls = false, qtype ="I2", is_load = true }
}
local result = Q.load_csv("test.csv", meta)
assert(type(result) == "table")
for i, v in pairs(result) do
  assert(type(result[i]) == "Column")
  Q.print_csv(result[i], nil, "")
  print("###########################")
end
print("PRINT Test Load CSV I4 DONE !!")
print("------------------------------------------")

require('Q/UTILS/lua/cleanup')()
os.exit()
