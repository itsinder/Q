local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
-- local dbg = require 'debugger'

return function (a, x )
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
  local buff =  assert(ffi.malloc(qconsts.chunk_size*w))
  local num_blocks = math.ceil(subs.len / qconsts.chunk_size)
  local coro = coroutine.create(function()
    local x_len
    for i =1,num_blocks do
      if ( i == num_blocks ) then 
        x_len = subs.len % qconsts.chunk_size
      else
        x_len = qconsts.chunk_size
      end
      qc[func_name](buff, x_len, subs.c_mem)
      coroutine.yield(x_len, buff, nil)
    end
  end)
  return Column{gen=coro, false, field_type=out_qtype}
end
