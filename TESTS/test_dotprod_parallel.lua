-- STRESS
local Q = require 'Q'
-- local dbg = require 'Q/UTILS/lua/debugger'
require 'Q/UTILS/lua/strict'
require('Q/UTILS/lua/cleanup')()

local T = {}
for i = 1,9 do
  T[#T + 1] = 31
end
for i = 1,333 do
  T[#T + 1] = 32
end
for i = 1,55 do
  T[#T + 1] = 33
end
for i = 1,64 do
  T[#T + 1] = 34
end
for i = 1,35 do
  T[#T + 1] = 35
end
for i = 1,85 do
  T[#T + 1] = 36
end
for i = 1,22 do
  T[#T + 1] = 37
end
for i = 1,32 do
  T[#T + 1] = 38
end
local ysubp 
local X 
local b
local bt = {}
for i = 1, 20000 do 
  X = Q.mk_col(T, 'F8')
  X:eval()

  ysubp = Q.const({ val = 0.5, len = #T, qtype = 'F8' })
  ysubp:eval()

  bt[i] = Q.sum(Q.vvmul(X, ysubp))
  bt[i] = bt[i]:eval()
  if ( ( i % 100 ) == 1 ) then 
    print(i)
  end
  collectgarbage()
end
-- dbg()
X:eval()
ysubp:eval()

local b = Q.sum(Q.vvmul(X, ysubp))
b = b:eval()

local bt = {}
for i = 1,1000 do
  bt[i] = Q.sum(Q.vvmul(X, ysubp))
end
for i = 1,1000 do
  print(i)
  bt[i] = bt[i]:eval()
  collectgarbage()
end
--[[
for i = 1, 1000 do
  print("Iter ", i)
  local status = true
  while status do
    status = bt[i]:next()
    if not status then
      bt[i] = bt[i]:value()
    end
  end
end
--]]


for i = 1, 1000 do
  print("Iteration ", i)
  assert(bt[i] == b, "original result: "..b..", different result: "..bt[i])
end

require('Q/UTILS/lua/cleanup')()
print("SUCCESS for ", arg[0])
os.exit()
