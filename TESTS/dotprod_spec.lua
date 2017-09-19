local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local X = {}
for i = 1,9 do
  X[#X + 1] = 31
end
for i = 1,333 do
  X[#X + 1] = 32
end
for i = 1,55 do
  X[#X + 1] = 33
end
for i = 1,64 do
  X[#X + 1] = 34
end
for i = 1,35 do
  X[#X + 1] = 35
end
for i = 1,85 do
  X[#X + 1] = 36
end
for i = 1,22 do
  X[#X + 1] = 37
end
for i = 1,32 do
  X[#X + 1] = 38
end
local ysubp = Q.const({ val = 0.5, len = #X, qtype = 'F8' })
X = Q.mk_col(X, 'F8')
ysubp:eval()

local b = Q.sum(Q.vvmul(X, ysubp))
b = b:eval()
for i = 1,1000 do
  local btmp = Q.sum(Q.vvmul(X, ysubp)):eval()
  print("Iteration ", i)
  assert(btmp == b, "original result: "..b..", different result: "..btmp)
end

print("SUCCESS for ", arg[0])
os.exit()