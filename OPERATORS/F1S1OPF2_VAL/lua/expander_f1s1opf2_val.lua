local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qtils = require 'Q/QTILS/lua/is_sorted'
local sort = require 'Q/OPERATORS/SORT/lua/sort'
local record_time = require 'Q/UTILS/lua/record_time'

local function chk_params(op, a, s, optargs)
  assert( op == "vsgeq" or
          op == "vsgt" or
          op == "vsleq" or
          op == "vslt"
        )
  assert(type(a) == "lVector", "'a' must be a lVector ")
  assert(type(s) == "Scalar" or type(s) == "number", "s must be a Scalar/number ")
  
end

local function expander_f1s1opf2_val(op, a, s, optargs)
  chk_params(op, a, s, optargs)

  local sp_fn_name = "Q/OPERATORS/F1S1OPF2_VAL/lua/" .. op .. "_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, tmpl = pcall(spfn, a:fldtype(), s:fldtype(), optargs)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)

  local s_cmem		= s:to_cmem()
  local out_buf		= nil
  local first_call	= true
  local cmem_a_idx	= nil
  local a_idx		= nil
  local cmem_out_idx	= nil
  local out_idx		= nil
  local a_chunk_idx	= 0
  local chunk_size      = qconsts.chunk_size
  local sz_out          = chunk_size * qconsts.qtypes[subs.out_qtype].width

  local cst_a_as	= subs.a_ctype .. " *"
  local cst_s_as	= subs.s_ctype .. " *"
  local cst_out_as	= subs.out_ctype .. " *"

  local function f1s1opf2_val_gen()
    if ( first_call ) then
      -- allocate memory for output buffer, a_idx, out_idx
      out_buf = assert(cmem.new(sz_out))

      cmem_a_idx = assert(cmem.new(ffi.sizeof("uint64_t")))
      cmem_a_idx:zero()
      a_idx = ffi.cast("uint64_t *", get_ptr(cmem_a_idx))

      cmem_out_idx = assert(cmem.new(ffi.sizeof("uint64_t")))
      cmem_out_idx:zero()
      out_idx = ffi.cast("uint64_t *", get_ptr(cmem_out_idx))

      first_call = false
    end

    -- initialize out_idx to zero
    cmem_out_idx:zero()

    repeat
      local a_len, a_chunk, a_nn_chunk = a:chunk(a_chunk_idx)
      if ( a_len == 0 ) then
        return tonumber(out_idx[0]), out_buf, nil
      end
      assert(a_nn_chunk == nil, "Null is not supported")

      local cst_a_chunk = ffi.cast(cst_a_as, get_ptr(a_chunk))
      local cst_s_val = ffi.cast(cst_s_as, get_ptr(s_cmem))
      local cst_out_buf = ffi.cast(cst_out_as, get_ptr(out_buf))

      local start_time = qc.RDTSC()
      local status = qc[func_name](cst_a_chunk, cst_s_val, a_len,
        a_idx, cst_out_buf, chunk_size, out_idx)
      record_time(start_time, func_name)
      assert(status == 0, "C error in F1S1OPF2_VAL")
      if ( tonumber(a_idx[0]) == a_len ) then
        a_chunk_idx = a_chunk_idx + 1
        cmem_a_idx:zero()
      end
    until ( tonumber(out_idx[0]) == chunk_size )
    return tonumber(out_idx[0]), out_buf, nil
  end
  return lVector( { gen = f1s1opf2_val_gen, has_nulls = false, qtype = a:qtype() } )
end

return expander_f1s1opf2_val
