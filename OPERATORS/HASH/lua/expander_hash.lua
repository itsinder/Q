local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local ffi      = require "Q/UTILS/lua/q_ffi"
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local is_in    = require 'Q/UTILS/lua/is_in'
local cmem     = require 'libcmem'
local Scalar   = require 'libsclr'
local lVector   = require 'Q/RUNTIME/lua/lVector'
local record_time = require 'Q/UTILS/lua/record_time'

local function init_spooky_struct(subs)
  local args_ctype = "SPOOKY_STATE"
  local cst_args_as = args_ctype .. " *"
  local sz_args = ffi.sizeof(args_ctype)
  local args = assert(cmem.new(sz_args), "malloc failed")
  local args_ptr = ffi.cast(cst_args_as, args)
  ffi.fill(args_ptr, sz_args)
  -- Following normally done by spooky_hash_init()
  args_ptr[0].m_length   = 0;
  args_ptr[0].m_remainder  = 0;
  args_ptr[0].m_state[0] = subs.seed1
  args_ptr[0].m_state[1] = subs.seed2
  -- needed by Q
  args_ptr[0].q_seed     = subs.seed
  args_ptr[0].q_stride   = subs.stride
  return args_ptr
end

local function expander_hash(f1, optargs)
  -- verification
  assert(type(f1) == "lVector", "input to hash() is not lVector")
  assert(f1:has_nulls() == false, "not prepared for nulls in hash")
  local spfn_name = "Q/OPERATORS/HASH/lua/hash_specialize"
  local spfn = assert(require(spfn_name))
  -- TODO: replace f1:meta().base with f1:lite_meta()
  -- lite_meta() will have vec basic info including vec_nn info
  -- without complex table structure
  local status, subs, tmpl = pcall(spfn, f1:meta().base, optargs)
  if not status then print(subs) end
  assert(status, "Specializer " .. spfn_name .. " failed")
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  -- RS: remove the if as per our earlier discussion
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  assert(qc[func_name], "Missing symbol " .. func_name)

  local cst_args = init_spooky_struct(subs)
  local out_qtype = assert(subs.out_qtype)
  local cst_f1_as  = subs.in_ctype  .. "*"
  local cst_out_as = subs.out_ctype .. "*"
  local out_width = qconsts.qtypes[out_qtype].width
  local buf_sz = qconsts.chunk_size * out_width
  -- RS: local out_buf = nil Should we replace following as shown below
  local out_buf = assert(cmem.new(buf_sz, out_qtype))
  local first_call = true
  local chunk_idx = 0
  --============================================
  local function hash_gen(chunk_num)
    assert(chunk_num == chunk_idx)
    --[[ RS: Why do we do the malloc inside the function? 
    if ( first_call ) then
      out_buf = assert(cmem.new(buf_sz, out_qtype))
      first_call = false
    end
    --]]
    local f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
    if f1_len == 0 then return 0, nil end

    local cst_f1_chunk  = ffi.cast("char *", get_ptr(f1_chunk))
    local cst_out_buf   = ffi.cast(cst_out_as, get_ptr(out_buf))
    local start_time = qc.RDTSC()
    qc[func_name](cst_f1_chunk, ffi.NULL, f1_len, cst_args,
      cst_out_buf, ffi.NULL)
    record_time(start_time, func_name)
    chunk_idx = chunk_idx + 1
    return f1_len, out_buf
  end
  return lVector{gen=hash_gen, has_nulls=false, qtype=out_qtype}
end
return expander_hash
