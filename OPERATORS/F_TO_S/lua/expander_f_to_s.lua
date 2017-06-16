local qconsts = require 'Q/UTILS/lua/q_consts'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local ffi    = require 'Q/UTILS/lua/q_ffi'
local qc     = require 'Q/UTILS/lua/q_core'
-- local dbg = require 'Q/UTILS/lua/debugger'

return function (a, x )
    local filename = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
    local spfn = assert(require(filename))
    assert(type(x) == "Column", "input should be a column")
    assert(x:has_nulls() == false, "Not set up for null values as yet")
    local x_qtype = assert(x:fldtype())
    status, subs, tmpl = pcall(spfn, x_qtype)
    assert(status, subs)
    local func_name = assert(subs.fn)
    assert(qc[func_name], "Function does not exist " .. func_name)
    local x_coro = assert(x:wrap(), "wrap failed for x")
    --[[
    local reduce_struct = assert(subs.c_mem)
    --]]
    local reduce_struct_name = string.format("REDUCE_%s_ARGS", func_name)
    local reduce_struct = assert(ffi.malloc(ffi.sizeof(reduce_struct_name)))
    local reduce_struct = ffi.cast(reduce_struct_name .. "*", reduce_struct)
    return coroutine.create(function()
      local x_chunk, x_status
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        if x_status then
          assert(x_len > 0)
          qc[func_name](x_chunk, x_len, reduce_struct, 0);
          coroutine.yield(reduce_struct)
        end -- if
      end -- while 
    end)
end
