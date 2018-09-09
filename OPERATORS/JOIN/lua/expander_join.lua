local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local utils   = require 'Q/UTILS/lua/utils'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local function expander_join(op, src_lnk, src_fld, dst_lnk, join_type, optargs)
  print(type(src_lnk))
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

--  assert(is_base_qtype(src_lnk:fldtype()), 
--  "join not supported for fldtype " .. src_lnk:fldtype())
--  assert(is_base_qtype(src_fld:fldtype())
--  "join not supported for fldtype " .. src_fld:fldtype())
--  assert(is_base_qtype(dst_lnk:fldtype())
--  "join not supported for fldtype " .. dst_lnk:fldtype())

  local sp_fn_name = "Q/OPERATORS/JOIN/lua/join_specialize"
  local spfn = assert(require(sp_fn_name))
  -- calling specializer
  local status, subs, tmpl = pcall(spfn, src_lnk:fldtype(), src_fld:fldtype(), src_lnk:fldtype(), join_type)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  assert(type(subs) == "table")
  local pl = require 'pl.pretty'
  pl.dump(subs)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local sz_out          = qconsts.chunk_size 
  print("join type and its output qtype", join_type, subs.out_qtype)
  local sz_dst_in_bytes = sz_out * qconsts.qtypes[subs.out_qtype].width
  local dst_fld = nil
  local first_call = true
  local n_dst = nil
  local aidx  = nil
  local a_chunk_idx = 0
  
  local function where_join(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == a_chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      dst_fld = assert(cmem.new(sz_dst_in_bytes))
--      n_dst = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
--      n_dst = ffi.cast("uint64_t *", n_dst)
      aidx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      aidx = ffi.cast("uint64_t *", aidx)
      aidx[0] = 0
      
      first_call = false
    end
    
    -- Initialize to its value
      n_dst = dst_lnk:length()
    
    repeat
      local a_len, a_chunk, a_nn_chunk = src_lnk:chunk(a_chunk_idx)
      local b_len, b_chunk, b_nn_chunk = src_fld:chunk(a_chunk_idx)
      local c_len, c_chunk, c_nn_chunk = dst_lnk:chunk(a_chunk_idx)
      if a_len == 0 then
        return n_dst, dst_fld, nil 
      end
      assert(a_len == b_len)
      --TODO: null to be supported?
      assert(a_nn_chunk == nil, "Null is not supported")
      assert(b_nn_chunk == nil, "Where vector cannot have nulls")
      
      local casted_a_chunk = ffi.cast( qconsts.qtypes[src_lnk:fldtype()].ctype .. "*",  get_ptr(a_chunk))
      local casted_b_chunk = ffi.cast( qconsts.qtypes[src_fld:fldtype()].ctype .. "*",  get_ptr(b_chunk))
      local casted_c_buf = ffi.cast( qconsts.qtypes[dst_lnk:fldtype()].ctype .. "*",  get_ptr(c_chunk))
      local casted_out_buf = ffi.cast( qconsts.qtypes[subs.out_qtype].ctype .. "*",  get_ptr(c_chunk))
      print(func_name)
      local status = qc[func_name](casted_a_chunk, casted_b_chunk, a_len, aidx, casted_c_buf, casted_out_buf,       c_len, join_type, sz_out, n_dst)
      assert(status == 0, "C error in WHERE")
      if ( tonumber(aidx[0]) == a_len ) then
        a_chunk_idx = a_chunk_idx + 1
        aidx[0] = 0
      end
    until ( tonumber(n_out[0]) == sz_out )
    return n_dst, dst_fld, nil
  end
  return lVector( { gen = where_join, has_nulls = false, qtype = subs.out_qtype } )
end

return expander_join
