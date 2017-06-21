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
  local chunk_size = 4 --qconsts.chunk_size
  local buff =  assert(ffi.malloc(chunk_size * w))
  local num_blocks = math.ceil(subs.len / chunk_size)
  local is_first = true
  local coro = coroutine.create(function()
    local x_len
    for i =1,num_blocks do
      if ( i == num_blocks ) then 
        x_len = subs.len % chunk_size
      else
        x_len = chunk_size
      end
      print(func_name)
      qc[func_name](buff, x_len, subs.c_mem, is_first)
      is_first = false
      if ( a == "seq" ) then
        subs.c_mem[0].start = subs.c_mem[0].start + x_len * subs.c_mem[0].by
      end
      coroutine.yield(x_len, buff, nil)
    end
  end)
  return Column{gen=coro, false, field_type=out_qtype}
end
