local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local lVector = require 'Q/RUNTIME/lua/lVector'
local multiple_of_8 = require 'Q/UTILS/lua/multiple_of_8'
-- local dbg = require 'debugger'

return function (a, args)
    -- Get name of specializer function. By convention
  local sp_fn_name = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name), "Specializer not found")
  local status, subs, tmpl = pcall(spfn, args)
  if ( not status ) then print(subs) end 
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  local out_qtype = assert(args.qtype)
  assert(qc[func_name], "Function not found " .. func_name)
  assert(subs.c_mem)

  local chunk_size = qconsts.chunk_size
  local width =  assert(qconsts.qtypes[out_qtype].width)
  local bufsz =  multiple_of_8(chunk_size * width)
  local buff =  assert(ffi.malloc(bufsz), "malloc failed")

  local gen1 = function(chunk_idx)
    local lb = chunk_size * chunk_idx
    local ub = lb + chunk_size
    local chunk_size = ub - lb;
    if ( ub > subs.len ) then 
      chunk_size = subs.len - lb
    end
    if ( chunk_size <= 0 ) then
      return nil
    else
      qc[func_name](buff, chunk_size, subs.c_mem, lb)
      return chunk_size, buff, nil
    end
  end
  return lVector{gen=gen1, has_nulls=false, qtype=out_qtype}
end
