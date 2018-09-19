local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local utils   = require 'Q/UTILS/lua/utils'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local function expander_join(op, src_lnk, src_fld, dst_lnk, join_type, optargs)
  assert(op == "join")
  assert(type(join_type) == "string", "Join type must be a string")
  assert( ( join_type == "min" ) or ( join_type == "max" ) or 
          ( join_type == "sum" ) or ( join_type == "exists" ) or 
          ( join_type == "min_idx" ) or ( join_type == "max_idx" ) or
          ( join_type == "and" ) or ( join_type == "or" ) or
          ( join_type == "count" ) or ( join_type == "arbitary" ),
          "Invalid join type " .. join_type)

  assert(type(src_lnk) == "lVector", "src_lnk must be a lVector")
  assert(type(src_fld) == "lVector", "src_fld must be a lVector")
  assert(type(dst_lnk) == "lVector", "dst_lnk must be a lVector")

  assert(src_lnk:is_eov(), "src_lnk must be materialized")
  assert(src_fld:is_eov(), "src_fld must be materialized")
  assert(dst_lnk:is_eov(), "dst_lnk must be materialized")

  assert(src_lnk:length() == src_fld:length(), 
  "src_lnk and src_fld must have same number of rows")
  -- TODO: check this assert
  assert(src_lnk:fldtype() == dst_lnk:fldtype(),
  "src_lnk and dst_lnk must have same qtype")

  -- TODO : are we supporting nulls in src_lnk and dst_lnk?
  assert(src_lnk:has_nulls() == false)
  assert(dst_lnk:has_nulls() == false)

  assert(is_base_qtype(src_lnk:fldtype()),
  "join not supported for fldtype " .. src_lnk:fldtype())
  assert(is_base_qtype(src_fld:fldtype()),
  "join not supported for fldtype " .. src_fld:fldtype())
  assert(is_base_qtype(dst_lnk:fldtype()),
  "join not supported for fldtype " .. dst_lnk:fldtype())

  local out_qtype
  if join_type == "sum" or join_type == "and" or join_type == "or" then
    if ( ( src_fld:fldtype() == "I1" ) or ( src_fld:fldtype() == "I2" ) or
      ( src_fld:fldtype() == "I4" ) or ( src_fld:fldtype() == "I8" ) ) then
      out_qtype = "I8"
    elseif ( ( src_fld:fldtype() == "F4" ) or ( src_fld:fldtype() == "F8" ) ) then
      out_qtype = "F8"
    end
  elseif join_type == "min" or join_type == "max" then
    out_qtype = src_fld:fldtype()
  elseif join_type == "min_idx" or join_type == "max_idx" or join_type == "count" then
    out_qtype = "I8"
  else
    -- TODO : for arbitary abd exists?
  end

  local sp_fn_name = "Q/OPERATORS/JOIN/lua/join_specialize"
  local spfn = assert(require(sp_fn_name))
  -- calling specializer
  local status, subs, tmpl = pcall(spfn, src_lnk:fldtype(), src_fld:fldtype(), src_lnk:fldtype(), out_qtype, join_type)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  assert(type(subs) == "table")
  local pl = require 'pl.pretty'
  pl.dump(subs)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local sz_out          = qconsts.chunk_size
  local sz_dst_in_bytes = sz_out * qconsts.qtypes[subs.dst_fld_qtype].width
  local dst_fld = nil
  local first_call = true
  local aidx  = nil
  local didx  = nil
  local a_chunk_idx = 0
  local nn_dst_fld
  local brk_n_write
  
  local function join_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == a_chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      dst_fld = assert(cmem.new(sz_dst_in_bytes))
      aidx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      aidx = ffi.cast("uint64_t *", aidx)
      aidx[0] = 0
      -- TODO sz_out * nn dst fld width?
      nn_dst_fld = assert(cmem.new(sz_out * 8))
      didx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      didx = ffi.cast("uint64_t *", didx)
      didx[0] = 0
      
      brk_n_write = assert(get_ptr(cmem.new(ffi.sizeof("bool"))))
      brk_n_write = ffi.cast("bool *", brk_n_write)
      
      first_call = false
    end
    
    -- Initialize to its value
    if join_type == "max" then
      dst_fld:set_min()
    elseif join_type == "min" then
      dst_fld:set_max()
--    elseif join_type == "max_idx" or join_type == "min_idx" then
--      --initialize dst_fld to -1
--      dst_fld = ffi.cast(qconsts.qtypes[subs.dst_fld_qtype].ctype .. "*", get_ptr(dst_fld))
--      for i = 0, dst_lnk:length() do
--        dst_fld[i] = -1
--      end
    else
      dst_fld:zero()
    end
    nn_dst_fld:zero()
    
    brk_n_write[0] = false
    
    repeat
      local c_chunk_idx = math.floor(tonumber(didx[0])/qconsts.chunk_size)
      local a_len, a_chunk, a_nn_chunk = src_lnk:chunk(a_chunk_idx)
      local b_len, b_chunk, b_nn_chunk = src_fld:chunk(a_chunk_idx)
      local c_len, c_chunk, c_nn_chunk = dst_lnk:chunk(c_chunk_idx)
      if a_len == 0 then
        return dst_lnk:length(), dst_fld, nil
      end
      if c_len == 0 then
        return dst_lnk:length(), dst_fld, nil
      end
      assert(a_len == b_len)
      --TODO: null to be supported?
      assert(a_nn_chunk == nil, "Null is not supported")
      assert(b_nn_chunk == nil, "join vector cannot have nulls")
      -- vec_pos indicates how many elements of vector we have consumed
      local vec_pos = a_chunk_idx * qconsts.chunk_size
      
      local casted_a_chunk = ffi.cast( qconsts.qtypes[src_lnk:fldtype()].ctype .. "*",  get_ptr(a_chunk))
      local casted_b_chunk = ffi.cast( qconsts.qtypes[src_fld:fldtype()].ctype .. "*",  get_ptr(b_chunk))
      local casted_c_buf   = ffi.cast( qconsts.qtypes[dst_lnk:fldtype()].ctype .. "*",  get_ptr(c_chunk))
      local casted_out_buf = ffi.cast( qconsts.qtypes[subs.dst_fld_qtype].ctype .. "*",  get_ptr(dst_fld))
      local casted_out_nn_buf = ffi.cast( "uint64_t *",  get_ptr(nn_dst_fld))
      print(func_name)
      
      local status = qc[func_name](join_type, casted_b_chunk, casted_a_chunk, aidx, a_len, casted_out_buf, casted_out_nn_buf, casted_c_buf, c_len, didx, sz_out, brk_n_write, vec_pos)
      assert(status == 0, "C error in JOIN")
      if ( tonumber(aidx[0]) == a_len ) then
        a_chunk_idx = a_chunk_idx + 1
        aidx[0] = 0
      end
      print("didx", didx[0])
      --TODO: need to handle dst_fld:length() > chunk_size
      -- if didx is above chunk_size
    until ( tonumber(didx[0]) == c_len and brk_n_write[0] == true)
    return dst_lnk:length(), dst_fld, nil
  end
  return lVector( { gen = join_gen, has_nulls = false, qtype = subs.dst_fld_qtype } )
end

return expander_join
