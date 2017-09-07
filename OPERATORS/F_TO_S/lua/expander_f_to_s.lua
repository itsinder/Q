local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'Q/RUNTIME/lua/Scalar'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
-- local dbg = require 'Q/UTILS/lua/debugger'

return function (a, x )
    local sp_fn_name = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
    local spfn = assert(require(sp_fn_name), 
    "Specializer missing " .. sp_fn_name)
    assert(type(x) == "lVector", "input should be a column")
    assert(x:has_nulls() == false, "Not set up for null values as yet")
    local x_qtype = assert(x:fldtype())
    local status, subs, tmpl = pcall(spfn, x_qtype)
    assert(status, "Failure of specializer " .. sp_fn_name)
    local func_name = assert(subs.fn)
    assert(qc[func_name], "Function does not exist " .. func_name)
    local reduce_struct = assert(subs.c_mem)
    local getter = assert(subs.getter)
    assert(type(getter) == "function")
    local idx = 0
    --==================
    local gen1 = function(chunk_idx)
      local x_len, x_chunk, nn_x_chunk = x:chunk(chunk_idx) 
      if x_len and x_len > 0 then 
        qc[func_name](x_chunk, x_len, reduce_struct, idx);
        idx = idx + x_len
        return reduce_struct
      end -- if      
    end
    
    local s =  Scalar ( { next = gen1, func = getter } )
    return s
end
