require 'Q/UTILS/lua/globals'
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local q = require 'Q/UTILS/lua/q'
-- local dbg = require 'Q/UTILS/lua/debugger'

return function (a, x )
    local filename = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
    local spfn = assert(require(filename))
    assert(type(x) == "Column", "input should be a column")
    assert(x:has_nulls() == false, "Not set up for null values as yet")
    print("XXXXXXXXXXXXX")
    status, subs, tmpl = pcall(spfn, x:fldtype())
    assert(status, subs)
    local func_name = assert(subs.fn)
    local x_coro = assert(x:wrap(), "wrap failed for x")
    local buff = q.malloc(1024) -- TODO P3 fix amount to be allocated
    local is_first = true
    local coro = coroutine.create(function()
      local x_chunk, x_status
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        if x_status then
          assert(x_len > 0)
          q[func_name](x_chunk, x_len, buff, is_first);
          is_first = false
          coroutine.yield(x_len, buff, nn_buff)
        end
      end
    end)
    local w = q_core.cast(subs.reduce_ctype.." *", buff)
    return w[0], w[1]
end
