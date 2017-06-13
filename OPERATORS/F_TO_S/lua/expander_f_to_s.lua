local qconsts = require 'Q/UTILS/lua/q_consts'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local ffi    = require 'Q/UTILS/lua/q_ffi'
local q_core = require 'Q/UTILS/lua/q_core'
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
    local red_str = string.format("REDUCE_%s_ARGS", func_name)
    print("red", red_str, ffi.sizeof(red_str))
    local buff = ffi.cast(red_str .. "*", ffi.malloc(ffi.sizeof(red_str))) -- TODO P3 fix amount to be allocated
    return coroutine.create(function()
      local x_chunk, x_status, nn_buf

      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        if x_status then
          assert(x_len > 0)
          print("XXXXXXXXXX")
          print(func_name)
          qc[func_name](x_chunk, x_len, buff, 0);
          coroutine.yield(buff)
        end
      end
    end)
    local w = q_core.cast(subs.reduce_ctype.." *", buff)
    return w[0], w[1]
end
