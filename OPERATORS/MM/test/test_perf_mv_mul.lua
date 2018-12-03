-- PERFORMANCE 
local Q = require 'Q'
local Vector = require 'libvec'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function(
  num_iters
  )
  local n = 16*1048576 -- number of rows
  local m = 1024 -- number of columns
  local modes = { "opt", "simple" }
  for _, mode in pairs(modes) do 
    local X = {}
    for i = 1, m do 
      X[i] = Q.const({val  = 1, len = n, qtype = "F4"}):memo(false)
    end
    local Y = Q.const({val  = 1, len = m, qtype = "F4"}):eval()
    _G['g_time'] = {}
    Vector.reset_timers()
    local t_start = tonumber(qc.RDTSC())
    local Z = Q.mv_mul(X, Y, { mode = mode}):eval()
    local t_stop = tonumber(qc.RDTSC())
    Vector.print_timers()
    local time = ( t_stop - t_start ) 
    print(mode, time, time / (2500.0 * 1000000.0 ))
    -- Q.print_csv(Z)
    if _G['g_time'] then
      for k, v in pairs(_G['g_time']) do
        local niters  = _G['g_ctr'][k] or "unknown"
        local ncycles = tonumber(v)
        print("0," .. k .. "," .. niters .. "," .. ncycles)
      end
    end
    print("=====================================")
  end
end
-- tests.t1()
return tests
