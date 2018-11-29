local Q = require 'Q'
local Vector = require 'libvec'
local file_name = "profile_result.txt"

local n = 128*1048576

--[[
--TODO See if you can do a restore only if there is soemthing to resotre
--
a = Q.const({ val = 1, len = n, qtype = "F8" }):set_name("a"):eval()
b = Q.const({ val = 1, len = n, qtype = "F8" }):set_name("b"):eval()
c = Q.const({ val = 1, len = n, qtype = "F8" }):set_name("c"):eval()
d = Q.const({ val = 1, len = n, qtype = "F8" }):set_name("d"):eval()
e = Q.const({ val = 1, len = n, qtype = "F8" }):set_name("e"):eval()

Q.save()
os.exit()
]]

Q.restore()
_G['g_time']  = {}
Vector.reset_timers()
local start_time, stop_time, time
start_time = qc.RDTSC()

local t1 = Q.vvadd( a,b):memo(false):set_name("t1")
local t2 = Q.vvsub(t1,c):memo(false):set_name("t2")
local t3 = Q.vvmul(t2,d):memo(false):set_name("t3")
local t4 = Q.vvdiv(t3,e):memo(false):set_name("t4")
local r = Q.sum(t4)
local n1, n2 = r:eval()

stop_time = qc.RDTSC()
Vector.print_timers()
-- print(n1, n2)
print("Time: sum((((a+b)-c)*d)/e) = time : " .. 
  tostring(tonumber(stop_time-start_time)))
print("=========================")

if _G['g_time'] then
  for k, v in pairs(_G['g_time']) do
    local niters  = _G['g_ctr'][k] or "unknown"
    local ncycles = tonumber(v)
    print("0," .. k .. "," .. niters .. "," .. ncycles)
  end
end
Q.save()

