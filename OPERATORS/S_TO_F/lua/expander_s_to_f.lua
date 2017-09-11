local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
-- local dbg = require 'debugger'

return function (a, x)
    -- Get name of specializer function. By convention
  local sp_fn_name = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name), "Specializer not found")
  local status, subs, tmpl = pcall(spfn, x)
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  local out_qtype = assert(x.qtype)
  assert(qc[func_name], "Function not found " .. func_name)
  assert(subs.c_mem)
  assert(subs.len > 0)

  local coro = coroutine.create(function()
    local lb = 0
    local ub = 0
    local chunk_size = qconsts.chunk_size
    local num_blocks = math.ceil(subs.len / chunk_size)
    local width =  assert(qconsts.qtypes[out_qtype].width)
    if ( width < 1 ) then width = 1 end 
    local buff =  assert(ffi.malloc(chunk_size * width), "malloc failed")
    for i = 1, num_blocks do
      ub = lb + chunk_size
      if ( ub > subs.len ) then 
        chunk_size = subs.len -lb
        ub = subs.len
      end
      qc[func_name](buff, chunk_size, subs.c_mem, lb)
      -- print(a, lb, ub, chunk_size)
      coroutine.yield(chunk_size, buff, nil)
      lb = lb + chunk_size
    end
  end)
  return Column{gen=coro, false, field_type=out_qtype}
end
