local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local lVector = require 'Q/RUNTIME/lua/lVector'
local multiple_of_8 = require 'Q/UTILS/lua/multiple_of_8'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

return function (a, args)
    -- Get name of specializer function. By convention
  local sp_fn_name = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_specialize"
  local mem_init_name = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_mem_initialize"
  local req_status, mem_initialize = pcall(require, mem_init_name)
  local spfn = assert(require(sp_fn_name), "Specializer not found")
  --TODO: remove below pcall,
  -- currently calling it in pcall as mem_initialize is supported for rand only
  local status, subs, tmpl = pcall(spfn, args)
  if ( not status ) then print(subs) end 
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  local out_qtype = assert(args.qtype)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Function not found " .. func_name)

  -- calling mem_initializer
  -- TODO: remove below temporary hack
  print(req_status, mem_initialize)
  local casted_struct
  if req_status then
    casted_struct = mem_initialize(subs)
  else
    casted_struct = ffi.cast(subs.c_mem_type, get_ptr(subs.c_mem))
  end
  local chunk_size = qconsts.chunk_size
  local width =  assert(qconsts.qtypes[out_qtype].width)
  local bufsz =  multiple_of_8(chunk_size * width)
  local buff =  nil
  local chunk_idx = 0
  local first_call = true
  local myvec
  
  local gen1 = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then
      first_call = false
      buff = assert(cmem.new(bufsz, out_qtype))
      myvec:no_memcpy(buff) -- hand control of this buff to the vector
    else
      myvec:flush_buffer() -- tell the vector to flush its buffer
    end
    local lb = chunk_size * chunk_idx
    local ub = lb + chunk_size
    local chunk_size = ub - lb;
    chunk_idx = chunk_idx + 1
    if ( ub > subs.len ) then 
      chunk_size = subs.len - lb
    end
    if ( chunk_size <= 0 ) then
      return 0
    else
      local casted_buff = ffi.cast( qconsts.qtypes[out_qtype].ctype .. "*",  get_ptr(buff))
      local start_time = qc.RDTSC()
      qc[func_name](casted_buff, chunk_size, casted_struct, lb)
      record_time(start_time, func_name)
      return chunk_size, buff
    end
  end
  myvec = lVector{gen=gen1, has_nulls=false, qtype=out_qtype}
  return myvec
end
