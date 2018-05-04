local qconsts = require 'Q/UTILS/lua/q_consts'
-- local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local ffi     = require 'Q/UTILS/lua/q_ffi'

  -- This operator produces 1 vector
local function expander_getk(a, fval, k, optargs)
  assert(a)
  assert(type(a) == "string")
  assert( ( a == "mink" ) or ( a == "maxk" ) )
  local sp_fn_name = "Q/OPERATORS/GETK/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, tmpl = pcall(spfn, fval, k, optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.sort_fn)
  assert(qc[func_name], "Symbol not available" .. func_name)
  local is_ephemeral = subs.is_ephemeral
  local qtype = assert(subs.qtype)
  local ctype = assert(subs.ctype)
  local width = assert(subs.width)
  local sort_fn = subs.sort_fn 

  --=================================================
  -- create a buffer to sort each chunk as you get it 
  local n = qconsts.chunk_size
  local sort_buf_val = cmem.new(n * width, qtype)
  sort_buf_val:zero()
  local casted_sort_buf_val = ffi.cast(ctype .. "*", get_ptr(sort_buf_val))

  --=== create buffers for keeping topk from each chunk
  local bufX = cmem.new(k * width, qtype)
  bufX:zero()
  local casted_bufX = ffi.cast(ctype .. "*", get_ptr(bufX))
  local nX = 0

  local bufZ = cmem.new(k * width, qtype)
  bufZ:zero()
  local casted_bufZ = ffi.cast(ctype .. "*", get_ptr(bufZ))
  local nZ = 0

  local num_in_Z = cmem.new(4, "I4");
  local ptr_num_in_Z = ffi.cast("uint32_t *",  get_ptr(num_in_Z))
  --============================================
  -- create vectors to return 
  local val_vec = lVector{nn= false, gen = true, qtype = qtype, has_nulls = false}
  -- TODO Consider case where there are less than k elements to return

  local chunk_idx = 0
  while ( true ) do
    local len, chunk, nn_chunk, casted_chunk, nY
    len, chunk, nn_chunk = fval:chunk(chunk_idx)
    if ( len == 0 ) then break end 
    -- copy chunk into local buffer and sort it in right order
    casted_chunk = ffi.cast(ctype .. "*",  get_ptr(chunk))
    assert(qc[sort_fn], "function not found " .. sort_fn)
    sort_buf_val:zero()
    ffi.C.memcpy(casted_sort_buf_val, casted_chunk, len*width)
    qc[sort_fn](casted_sort_buf_val, len)
    --================================
    if ( k < len ) then nY = k else nY = len end
    if ( chunk_idx == 0 )  then 
      ffi.C.memcpy(casted_bufX, casted_sort_buf_val, nY*width)
      nX = nY
    else
      qc[subs.merge_fn](casted_bufX, nX, casted_sort_buf_val, nY, casted_bufZ, nZ, ptr_num_in_Z)
      -- copy from bufZ to bufX
      local num_in_Z = ptr_num_in_Z[0]
      ffi.C.memcpy(casted_bufX, casted_bufZ, num_in_Z*width)
      nX = num_in_Z
    end
    chunk_idx = chunk_idx + 1
  end
  val_vec:put_chunk(bufX, nil, nX)
  return val_vec
end
return expander_getk
