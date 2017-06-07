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
    local red_str = string.format("REDUCE_%s_ARGS", func_name)
    print("red", red_str, q.sizeof(red_str))
    local buff = q.cast(red_str .. "*", q.malloc(q.sizeof(red_str))) -- TODO P3 fix amount to be allocated
    return coroutine.create(function()
      local x_chunk, x_status, nn_buf
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        if x_status then
          assert(x_len > 0)
          print("XXXXXXXXXX")
          print(func_name)
          q[func_name](x_chunk, x_len, buff, 0);
          coroutine.yield(buff)
        end
      end
    end)
    -- TODO P0 return args but after converting to lua 
end
