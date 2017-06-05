require 'globals'
local Column = require 'Column'
local dbg = require 'debugger'

assert(nil, "WORK IN PROGRESS")

function expander_s_to_f(a, x )
    -- Get name of specializer function. By convention
    local spfn = assert(require(a .. "_specialize" ))
    status, subs, tmpl = pcall(spfn, x:fldtype())
    assert(status, subs)
    local func_name = assert(subs.fn)

    local coro = coroutine.create(function()
      local buff =  assert(q.malloc(g_chunk_size*g_qtypes[out_qtype].width))
      num_blocks = math.ceil(subs.len / g_chunk_size)
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
end
