require 'globals'
local Column = require 'Column'
local dbg = require 'debugger'

assert(nil, "WORK IN PROGRESS")

function expander_f_to_s(a, x )
    -- Get name of specializer function. By convention
    local spfn = require(a .. "_specialize" )
    status, subs, tmpl = pcall(spfn, x:fldtype())
    assert(status, subs)
    local func_name = assert(subs.fn)
    local x_coro = assert(x:wrap(), "wrap failed for x")
    local buff = q_core.malloc(1024)  -- TODO P1 Should this be within coro?
    -- TODO: P3 Improve 1024 above. For now, it is plenty
    local coro = coroutine.create(function()
      local x_chunk, x_status
      if x:has_nulls() then
        assert(nil, "TO BE IMPLEMENTED")
      end
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        if x_status then
          assert(x_len > 0)
          q[func_name](x_chunk, x_len, buff, 0);
          coroutine.yield(x_len, buff, nn_buff)
        end
      end
    end)
    -- TODO P0 return args but after converting to lua 
end
