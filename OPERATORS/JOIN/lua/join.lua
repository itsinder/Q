
function join(join_type, src_val, src_lnk, dst_lnk)
  local is_base_qtype = require 'is_base_qtype'

  assert(type(join_type) == "string", "Join type must be a string")
  assert( ( join_type == "min" ) or ( join_type == "max" ) or 
          ( join_type == "sum" ) or ( join_type == "exists" ) or 
          ( join_type == "min_idx" ) or ( join_type == "max_idx" ),
          "Invalid join type " .. join_type)

  assert(type(src_val) == "Column", "src_val must be a column")
  assert(type(src_lnk) == "Column", "src_lnk must be a column")
  assert(type(dst_lnk) == "Column", "dst_lnk must be a column")

  assert(src_val:is_materialized(), "src_val must be materialized")
  assert(src_lnk:is_materialized(), "src_lnk must be materialized")
  assert(dst_lnk:is_materialized(), "dst_lnk must be materialized")

  assert(src_val:num_rows() == src_lnk:num_rows(), 
  "src_val and src_lnk must have same number of rows")

  assert(src_lnk:has_nulls() == false)
  assert(dst_lnk:has_nulls() == false)

  assert(is_base_qtype(src_val:fldtype()), 
  "join not supported for fldtype " .. src_val:fldtype())
  assert(is_base_qtype(src_lnk:fldtype())
  "join not supported for fldtype " .. src_lnk:fldtype())
  assert(is_base_qtype(dst_lnk:fldtype())
  "join not supported for fldtype " .. dst_lnk:fldtype())
  local src_val_type = src_val:fldtype()

  local src_val_len, src_val_ptr, nn_src_val_ptr = src_val:get_chunk(-1)
  local src_lnk_len, src_lnk_ptr, nn_src_lnk_ptr = src_lnk:get_chunk(-1)
  assert(src_val_len == src_lnk_len)
  assert(not nn_src_lnk_ptr)

  local dst_lnk_len, dst_lnk_ptr, nn_dst_lnk_ptr = dst_lnk:get_chunk(-1)

  --=== Determine type of dst_val
  local dst_val_type = nil
  if ( join_type == "sum" ) then
    if ( g_irof[src_val_type] == "integer" ) then 
      dst_val_type = "I8"
    elseif ( g_irof[src_val_type] == "floating_point" ) then 
      dst_val_type = "F8"
    else
      assert(nil, "Unable to determinen type of dst_val")
    end
  end
  if ( join_type == "exists" ) then
    dst_val_type = "B1"
  end
  if ( ( join_type == "min" ) or  ( join_type == "max" ) ) then
    dst_val_type = src_val_type
  end
  if ( ( join_type == "min_idx" ) or  ( join_type == "max_idx" ) ) then
    if ( src_val_len <= 127 ) then
      dst_val_type = "I1"
    elseif ( src_val_len <= 32767 ) then
      dst_val_type = "I2"
    elseif ( src_val_len <= 2147483647 ) then
      dst_val_type = "I4"
    else
      dst_val_type = "I8"
    end
  end
  assert(dst_val_type, "Unable to determinen type of dst_val")
  local join_specialize = require 'join_specialize')
  local status, subs, tmpl = pcall(join_specialize, src_val_type, 
  src_lnk_type, dst_lnk_type, dst_val_type)
  assert(status)
  assert(type(subs) == "table")
  return dst_val
end
