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
-- Find range for sumby
for k1, attr in pairs(grp_by) do 
  local vec = assert(T[attr], " k = " .. k1)
  assert(type(vec) == "lVector")
  local x, y = Q.max(vec):eval()
end
print("Setting up computation")
for _, attr in pairs(grp_by) do 
  local vec = assert(T[attr])
  assert(type(vec) == "lVector")
  local x, y = Q.max(vec):eval() -- should not need comoutation
  local nvals = x:to_num() + 1
  avals[attr] = {}
  bvals[attr] = {}
  for _, metric in pairs(M) do 
    assert(type(metric) == "lVector")
    avals[attr][metric] = Q.sumby(metric, vec, nvals, { where = a })
    bvals[attr][metric] = Q.sumby(metric, vec, nvals, { where = b })
    print("setting up " .. metric:get_name() .. " for " .. vec:get_name())
  end
end
print("Performing computation")
for _, attr in pairs(grp_by) do 
  for _, metric in pairs(M) do 
    avals[attr][metric]:eval()
    bvals[attr][metric]:eval()
    print("working on " .. metric:get_name() .. " for " .. attr)
  end
end

print("Successfully completed")
os.exit()
