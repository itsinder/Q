local Q = require 'Q'

for i = 1,1000 do
  local c1 = Q.mk_col({1, 9, 2, 8, 3, 7}, "I4")
  local c2 = Q.mk_col({7, 1, 3, 2, 1, 0}, "I4")
  local z = Q.vvmul(c1, c2)
  assert(type(z) == "Column", "Z NOT COLUMN WRONG")
  local s = Q.sum(z)
  assert(type(s) == "Scalar", "S NOT SCALAR WRONG")
  local val = s:eval() 
  assert(val == 41, "WRONG, val = " .. val)
end

for i = 1,1000 do
  local c1 = Q.rand({ lb = 10, ub = 20, seed = 1234, qtype = "F4", len = 65537 } )
  local c2 = Q.rand({ lb = 10, ub = 20, seed = 1234, qtype = "F4", len = 65537 } )
  local z = Q.vvmul(c1, c2)
  assert(type(z) == "Column", "Z NOT COLUMN WRONG")
  local s = Q.sum(z)
  assert(type(s) == "Scalar", "S NOT SCALAR WRONG")
  local val = s:eval() 
  local w = Q.vvmul(c1, c1)
  w:eval()
end

print("SUCCESS for ", arg[0])
os.exit()
