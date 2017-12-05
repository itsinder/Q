--  FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local Scalar = require 'libsclr'
local tests = {} 

local len = 1048576+17
val = 127
y_qtype = "I1"
x_qtype = "I4"
local x = Q.const({ len = len, qtype = x_qtype, val = Scalar.new(val, x_qtype)})
sum1 = Q.sum(x):eval():to_num()
print(sum1)
x:eval()
sum2 = Q.sum(x):eval():to_num()
print(sum2)
assert(sum1 == sum2)
assert(sum1 == val * len)

--=====================================
t7_I1 = function()
  local len = 1048576+17
  local old_qtype = "I1"
  local val =  127
  local new_qtype = "I1"
  local x = Q.const({ len = len, qtype = old_qtype, val = Scalar.new(val, old_qtype)})
  x:eval()
  print("XX", Q.sum(x):eval():to_num(), len*val)
  local chksum = Q.sum(x):eval():to_num()
  assert(chksum == len  * val)
  local y = Q.convert(x, new_qtype)
  local z = Q.convert(y, old_qtype)
  z:eval()
  -- print(">>>>>>>>>>>>>>>>>>")
  Q.print_csv({x, z}, nil, "_xxx_" .. val)
  -- print("<<<<<<<<<<<<<<<<<<")
  assert(Q.sum(Q.vvneq(x, z)):eval():to_num() == 0)
  print("Test completed t7_I1")
end
t7_I1()
