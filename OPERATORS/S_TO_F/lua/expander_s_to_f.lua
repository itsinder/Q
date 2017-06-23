local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
-- local dbg = require 'debugger'

return function (a, x)
    -- Get name of specializer function. By convention
  local filename = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_specialize"
  local spfn = assert(require(filename))
  status, subs, tmpl = pcall(spfn, x)
  assert(status, subs)
  local func_name = assert(subs.fn)
  local out_qtype = assert(x.qtype)
  assert(qc[func_name], "Function not found " .. func_name)
  assert(subs.c_mem)
  local w =  assert(qconsts.qtypes[out_qtype].width)
  local chunk_size = qconsts.chunk_size
  local buff =  assert(ffi.malloc(chunk_size * w))
  local num_blocks = math.ceil(subs.len / chunk_size)
  local lb = 0
  local coro = coroutine.create(function()
    for i =1,num_blocks do
      local ub = lb + chunk_size
      if ( ub > subs.len ) then 
        chunk_size = subs.len -lb
        ub = subs.len
      end
      qc[func_name](buff, chunk_size, subs.c_mem, lb)
      print(a, lb, ub, chunk_size)
      coroutine.yield(chunk_size, buff, nil)
      lb = lb + chunk_size
    end
  end)
  return Column{gen=coro, false, field_type=out_qtype}
end
