require 'globals'
require 'error_code'
local Column = require 'Column'

local t_permute = function(typ)
    return terra(a: &typ, idx: &typ, b: &typ, n: int)
      for i = 0,n do
        --b[idx[i]] = a[i]
        b[i]=a[idx[i]]
      end  
    end
end

t_permute = terralib.memoize(t_permute)

-- TODO can move to Column/globals? (nn may be issue)
function create_col_with_meta(c)
  return Column{
    field_type=c:fldtype(),
    field_size=c:sz(), 
    --filename= _G["Q_DATA_DIR"] .. "/_" .. M[i].name,
    write_vector=true }
    -- TODO NULLS, nn_vector
end

idx_qtype = "I4"

function permute(val_col, idx_col)
  assert(type(idx_col) == "Column", g_err.INPUT_NOT_COLUMN) 
  assert(type(val_col) == "Column", g_err.INPUT_NOT_COLUMN) 
  assert(idx_col:has_nulls(), "Index column cannot have nulls")
  assert(val_col:has_nulls(), "As of now, Value column cannot have nulls")

  local val_qtype = assert(val_col:fldtype())
  -- TODO Any asserts  on c_qtype
  --
  local idx_qtype = assert(idx_col:fldtype())
  assert( ( ( idx_qtype == "I1" ) or ( idx_qtype == "I2" ) or 
            ( idx_qtype == "I4" ) or ( idx_qtype == "I8" ) ), 
            "idx column must be integer type")

  local tertyp = terra_types[val_qtype]
  local val_n = val_col:length()
  local idx_n = idx_col:length()
  assert(idx_n == val_n, 
  "index array-length should equal column-length in permute")
  if ( idx_n > 127 ) then assert(qtype != "I1") end
  if ( idx_n > 32767 ) then assert(qtype != "I2") end
  if ( idx_n > 2147483647 ) then assert(qtype != "I4") end
  
  -- get one chunk with everything in it
  local chk_val_n, val_vec, nn_val_vec = val_col:chunk(-1)
  assert (chk_val_n == val_n, "Didn't get full input array in permute()")

  local chk_idx_n, idx_vec, nn_idx_vec = idx_col:chunk(-1)
  assert (chk_idx_n == idx_n, "Didn't get full input array in permute()")

  local idx_arr = Array(terra_types[idx_qtype])(val_n)
  init_arr(terra_types[idx_qtype], idx_arr, val_n, idx)
  local out_arr = Array(tertyp)(val_n)
  
  t_permute(tertyp)(vec, idx_arr, out_arr, val_n)
  local out_col = create_col_with_meta(c)
  out_col:put_chunk(n, out_arr, nil) 
  out_col:eov()
  return out_col
end
----- END PERMUTE CODE
