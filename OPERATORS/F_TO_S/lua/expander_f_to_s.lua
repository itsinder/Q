local qconsts = require 'Q/UTILS/lua/q_consts'
local Reducer = require 'Q/RUNTIME/lua/Reducer'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local chk_chunk      = require 'Q/UTILS/lua/chk_chunk'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qconsts = require 'Q/UTILS/lua/q_consts'

return function (a, x, y, optargs )
  local sp_fn_name = "Q/OPERATORS/F_TO_S/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name),
  "Specializer missing " .. sp_fn_name)
  assert(type(x) == "lVector", "input should be a lVector")
  assert(x:has_nulls() == false, "Not set up for null values as yet")
  local x_qtype = assert(x:fldtype())
  local status, subs, tmpl = pcall(spfn, x_qtype, y, optargs)
  assert(status, "Failure of specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Function does not exist " .. func_name)
  local reduce_struct = assert(subs.c_mem)
  local getter = assert(subs.getter)
  assert(type(getter) == "function")
  --==================
  local is_early_exit = false
  local chunk_index = 0
  local lgen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_index)
    local idx = chunk_index * qconsts.chunk_size
    local x_len, x_chunk, nn_x_chunk = x:chunk(chunk_index)
    assert(chk_chunk(x_len, x_chunk, nn_x_chunk))
    chunk_index = chunk_index + 1
    if x_len and ( x_len > 0 ) and ( is_early_exit == false ) then
      local casted_x_chunk = ffi.cast( qconsts.qtypes[x:fldtype()].ctype .. "*",  get_ptr(x_chunk))
      local casted_struct = ffi.cast(subs.c_mem_type, get_ptr(reduce_struct))
      qc[func_name](casted_x_chunk, x_len, casted_struct, idx);
      if ( a == "is_next" ) then 
        local X = ffi.cast(subs.rec_name .. ' *', reduce_struct)
        if ( tonumber(X[0].is_violation) == 1 ) then 
          is_early_exit = true 
        end
      end
      return reduce_struct
    end 
  end
  local s =  Reducer ( { gen = lgen, func = getter, value = reduce_struct} )
  return s
end
