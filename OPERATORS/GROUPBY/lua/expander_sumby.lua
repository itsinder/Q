local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_sumby(a, b, nb, optargs)
  -- Verification
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(b) == "lVector", "b must be a lVector ")
  assert(type(nb) == "number")
  assert( ( nb > 0) and ( nb < qconsts.chunk_size) )
  local sp_fn_name = "Q/OPERATORS/GROUPBY/lua/sumby_specialize"
  local spfn = assert(require(sp_fn_name))
  local c -- conditional evaluation

  -- Keeping default is_safe value as true
  -- This will not allow C code to write values at incorrect locations
  local is_safe = true
  if optargs then
    assert(type(optargs) == "table")
    if ( optargs["is_safe"] == false ) then
      is_safe =  optargs["is_safe"]
      assert(type(is_safe) == "boolean")
    end
    if ( optargs.where ) then
      c = optargs.where
      assert(type(c) == "lVector")
      assert(c:fldtype == "B1")
    end
  end

  local status, subs, tmpl = pcall(spfn, a:fldtype(), b:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation

  assert(qc[func_name], "Symbol not defined " .. func_name)
  local sz_out = nb
  local sz_out_in_bytes = sz_out * qconsts.qtypes[subs.out_qtype].width
  local out_buf = nil
  local first_call = true
  local chunk_idx = 0
  
  local a_ctype = qconsts.qtypes[a:fldtype()].ctype 
  local b_ctype = qconsts.qtypes[b:fldtype()].ctype 
  local out_ctype = qconsts.qtypes[subs.out_qtype].ctype 
  
  local function sumby_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      out_buf = assert(cmem.new(sz_out_in_bytes))
      out_buf:zero()
      first_call = false
    end
    while true do
      local a_len, a_chunk, a_nn_chunk = a:chunk(chunk_idx)
      local b_len, b_chunk, b_nn_chunk = b:chunk(chunk_idx)
      local c_len, c_chunk, c_nn_chunk 
      if ( c ) then 
        c_len, c_chunk, c_nn_chunk = c:chunk(chunk_idx)
      end
      assert(a_len == b_len)
      if a_len == 0 then
        if chunk_idx == 0 then
          return 0, nil, nil
        else
          return nb, out_buf, nil
        end
      end
      assert(a_nn_chunk == nil, "Null is not supported")
      assert(b_nn_chunk == nil, "Null is not supported")
    
      local cst_a_chnk = ffi.cast( a_ctype .. "*",  get_ptr(a_chunk))
      local cst_b_chnk = ffi.cast( b_ctype .. "*",  get_ptr(b_chunk))
      local cst_c_chunk  = nil
      if ( c ) then 
        cst_c_chunk = ffi.cast( "uint64_t *",    get_ptr(c_chunk))
      end
      local cst_out_buf = ffi.cast( out_ctype .. "*",  get_ptr(out_buf))
      local status = qc[func_name](
        cst_a_chnk, a_len, cst_b_chnk, 
        cst_out_buf, nb, 
        cst_c_chunk, is_safe)
      assert(status == 0, "C error in SUMBY")
      chunk_idx = chunk_idx + 1
      if a_len < qconsts.chunk_size then
        return nb, out_buf, nil
      end
    end
  end
  return lVector( { gen = sumby_gen, has_nulls = false, qtype = subs.out_qtype } )
end

return expander_sumby
