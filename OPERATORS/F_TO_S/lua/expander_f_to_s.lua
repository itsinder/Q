require 'Q/UTILS/lua/globals'
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local q = require 'Q/UTILS/lua/q'
-- local dbg = require 'Q/UTILS/lua/debugger'

return function (a, x )
    -- Get name of specializer function. By convention
    local filename = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
    local spfn = assert(require(filename))
    assert(type(x) == "Column", "input should be a column")
    -- assert(x:has_nulls() == false, "Not set up for null values as yet")
    status, subs, tmpl = pcall(spfn, x:fldtype())
    assert(status, subs)
    local func_name = assert(subs.fn)
    local x_coro = assert(x:wrap(), "wrap failed for x")
    local buff = q.malloc(1024) -- TODO P3 fix amount to be allocated
    local coro = coroutine.create(function()
      local x_chunk, x_status
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        if x_status then
          assert(x_len > 0)
          print("XXXXXXXXXX")
          q[func_name](x_chunk, x_len, buff, 0);
          coroutine.yield(x_len, buff, nn_buff)
        end
      end
    end)
    -- TODO P0 return args but after converting to lua 
end
