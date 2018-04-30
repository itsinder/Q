local qconsts = require 'Q/UTILS/lua/q_consts'
-- local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

  -- This operator produces 1 vector
local function expander_getk(a, fval, k, optargs)
  assert(a)
  assert(type(a) == "string")
  assert( ( a == "min" ) or ( a == "max" ) )
  local sp_fn_name = "Q/OPERATORS/GETK/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, tmpl = pcall(spfn, f1in_qytpe, optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not available" .. func_name)
  local is_ephemeral = assert(subs.is_ephemeral)
  local qtype = assert(subs.qtype)
  local ctype = assert(subs.ctype)
  local width = assert(subs.width)
  local sort_fn = subs.sort_fn 

  --=================================================
  -- create a buffer to sort each chunk as you get it 
  local n = qconsts.chunk_size
  local sort_buf_val = cmem.new(n * width, qtype)
  --=== create buffers for keeping topk from each chunk
  local bufX = cmem.new(k * width, qtype)
  local nX = 0
  local bufZ = cmem.new(k * width, qtype)
  local nZ = 0
  local num_in_Z = cmem.new(4, "I4");
  local ptr_num_in_Z = ffi.cast("uint32_t *",  get_ptr(num_in_Z))
  --============================================
  -- create vectors to return 
  local val_vec = lVector{nn= false, gen = true, qtype = qtype, has_nulls = false}
  -- TODO Consider case where there are less than k elements to return

  local chunk_idx = 0
  while ( true ) do
    local len, chunk, casted_chunk, nY
    len, chunk = fval:chunk(chunk_idx)
    if ( len == 0 ) then break end 
    -- copy chunk into local buffer and sort it in right order
    casted_chunk = ffi.cast(ctype .. "*",  get_ptr(chunk))
    assert(qc[sort_fn], "function not found " .. sort_fn)
    ffi.C.memcpy(sort_val_buf, chunk, len*width)
    qc[sort_fn](chunk, len)
    --================================
    if ( k < len ) then nY = k else nY = len end 
    if ( chunk_idx == 0 )  then 
      ffi.C.memcpy(bufX, casted_chunk, nY * width)
    else
      qc[subs.merge_fn](bufX, nX, casted_chunk, nY, bufZ, nZ, ptr_num_in_Z)
    end
    -- copy from bufZ to bufX
    local num_in_Z = ptr_num_in_Z[0]
    ffi.C.memcpy(bufZ, bufX, num_in_Z * width)
    nX = num_in_Z
    chunk_idx = chunk_idx + 1
  end
  val_vec:put_chunk(buf1, n_buf1)
  return val_vec
end
return expander_getk
