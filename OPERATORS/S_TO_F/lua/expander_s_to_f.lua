require 'Q/UTILS/lua/globals'
q = require 'Q/UTILS/lua/q'
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
-- local dbg = require 'debugger'

return function (a, x )
    -- Get name of specializer function. By convention
  local filename = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_specialize"
  local spfn = assert(require(filename))
  status, subs, tmpl = pcall(spfn, x)
  assert(status, subs)
  local func_name = assert(subs.fn)
  local out_qtype = assert(x.qtype)
  assert(q[func_name], "Function not found " .. func_name)
  assert(subs.c_mem)
  local w =  assert(g_qtypes[out_qtype].width)

  local buff =  assert(q.malloc(g_chunk_size*w))
  local num_blocks = math.ceil(subs.len / g_chunk_size)
  local coro = coroutine.create(function()
    for i in 1, num_blocks do
      if ( i == num_blocks ) then 
        x_len = subs.len - (num_blocks-1)*g_chunk_size
      else
        x_len = g_chunk_size
      end
      q[func_name](x_chunk, x_len, subs.c_mem)
      coroutine.yield(x_len, buff, nil)
    end
  end)
  return Column{gen=coro, false, field_type=out_qtype}
end
