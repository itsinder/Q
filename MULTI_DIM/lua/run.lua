local Q = require 'Q'
local dload = require 'Q/MULTI_DIM/lua/dload'
local mk_ab = require 'Q/MULTI_DIM/lua/mk_ab'

local T, M = dload()
local n
for k, v in pairs(T) do 
  n = v:length() 
end

local a, b = mk_ab(n, 0.4)
local grp_by = { "f1", "f2", "f3", "f4" }
local avals = {}
local bvals = {}
for k, attr in pairs(grp_by) do 
  local vec = assert(T[attr], " k = " .. k)
  assert(type(vec) == "lVector")
  local x, y = Q.max(vec):eval()
  -- print(x, y, vec:get_name(), vec:fldtype())
  local nvals = x:to_num() + 1
  for k2, metric in pairs(M) do 
    assert(type(metric) == "lVector")
    avals[k] = Q.sumby(metric, vec, nvals, { where = a }):eval()
    bvals[k] = Q.sumby(metric, vec, nvals, { where = b }):eval()
    print("working on " .. metric:get_name() .. " for " .. vec:get_name())
  end
end

print("Successfully completed")
os.exit()
