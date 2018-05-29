local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_numby(a, nb, optargs)
  -- Verification
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(nb) == "number")
  assert( ( nb > 0) and ( nb < qconsts.chunk_size) )
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/numby_specialize"
  local spfn = assert(require(sp_fn_name))

  -- Keeping default is_safe value as true
  -- This will not allow C code to write values at incorrect locations
  local is_safe = true
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs["is_safe"] == false ) then
      is_safe =  optargs["is_safe"]
      assert(type(is_safe) == "boolean")
    end
  end

  local status, subs, len = pcall(spfn, a:fldtype(), is_safe)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  local out_qtype = subs.out_qtype
  assert(qc[func_name], "Symbol not defined " .. func_name)
  local sz_out = nb
  local sz_out_in_bytes = sz_out * qconsts.qtypes[out_qtype].width
  local out_buf = nil
  local first_call = true
  local chunk_idx = 0
  local in_ctype  = subs.in_ctype
  local out_ctype = subs.out_ctype
  local function numby_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      out_buf = assert(cmem.new(sz_out_in_bytes))
      out_buf:zero() -- particularly important for this operator
      first_call = false
    end
    while true do
      local a_len, a_chunk, a_nn_chunk = a:chunk(chunk_idx)
      if a_len == 0 then
        if chunk_idx == 0 then
          return 0, nil, nil
        else
          return nb, out_buf, nil
        end
      end
      assert(a_nn_chunk == nil, "Null is not supported")
    
      local casted_a_chunk = ffi.cast(in_ctype .. " *",  get_ptr(a_chunk))
      local casted_out_buf = ffi.cast(out_ctype .. "*",  get_ptr(out_buf))
      local status = qc[func_name](casted_a_chunk, a_len, casted_out_buf, nb, is_safe)
      assert(status == 0, "C error in NUMBY")
      chunk_idx = chunk_idx + 1
      if a_len < qconsts.chunk_size then
        return nb, out_buf, nil
      end
    end
  end
  return lVector( { gen = numby_gen, has_nulls = false, qtype = out_qtype } )
end

return expander_numby