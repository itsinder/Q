local Q = require 'Q'
local dload = require 'Q/MULTI_DIM/lua/dload'
local qc    = require 'Q/UTILS/lua/q_core'
local mk_ab = require 'Q/MULTI_DIM/lua/mk_ab'
local first_time = false
if ( first_time ) then 
  local T, M = dload()
  local n
  for k, v in pairs(T) do 
    n = v:length() 
  end

  local grp_by = { "f1", "f2", "f3", "f4" }
  -- Find range for sumby
  for k1, attr in pairs(grp_by) do 
    local vec = assert(T[attr], " k = " .. k1)
    assert(type(vec) == "lVector")
    local x, y, z = Q.max(vec):eval()
    vec:set_meta("max", {x, y, z})
  end
  
  local a, b = mk_ab(n, 0.4)
  Q.save()
  os.exit()
end

Q.restore()
print("Setting up computation")

local grp_by = { "f1", "f2", "f3", "f4" }
local avals = {}
local bvals = {}
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
local is_chunking = true
print("Performing computation")
local t_start = qc.RDTSC()
if ( is_chunking ) then 
  local chunk_num = 0
  local keep_going = true
--  for _, attr in pairs(grp_by) do 
    attr = "f1"
    for _, metric in pairs(M) do 
      print("aa: chunk_num = ", chunk_num)
      local x = avals[attr][metric]:chunk(chunk_num)
      -- local y = bvals[attr][metric]:chunk(chunk_idx)
      -- assert(x == y)
      if ( not x ) then 
        keep_going = false 
        print("Breaking on chunk ", chunk_num)
      end 
      chunk_num = chunk_num + 1
    end
    -- if ( not keep_going ) then break end 
  -- end
else
  for _, attr in pairs(grp_by) do 
    for _, metric in pairs(M) do 
      avals[attr][metric]:eval()
      bvals[attr][metric]:eval()
      print("working on " .. metric:get_name() .. " for " ..  attr)
    end
  end
end
local t_stop = qc.RDTSC()
local clockspeed = 2200
print("Time = ", tonumber((t_stop-t_start))/(2200.0 * 1000000.0))

print("Successfully completed")
os.exit()
