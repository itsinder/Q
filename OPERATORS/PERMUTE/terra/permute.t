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

function permute(c, idx)
  assert(type(idx) == "table",g_err.INPUT_NOT_TABLE)
  assert(type(c) == "Column", g_err.INPUT_NOT_COLUMN) -- TODO CHECK c.f. print_csv  
  local n = c:length()
  local tertyp = terra_types[c:fldtype()]
  assert(n == #idx, "index array-length should equal column-length in permute()")
  
  -- get one chunk with everything in it
  -- TODO pass in -1 here - yet to implement?!
  local vec_size, vec, nn_vec = c:chunk(0)
  assert (vec_size == n, "Didn't get full input array in permute()")
  local idx_arr = Array(terra_types[idx_qtype])(n)
  init_arr(terra_types[idx_qtype], idx_arr, n, idx)
  local out_arr = Array(tertyp)(n)
  
  t_permute(tertyp)(vec, idx_arr, out_arr, n)
  local out_col = create_col_with_meta(c)
  out_col:put_chunk(n, out_arr, nil) -- TODO nn
  out_col:eov()
  return out_col
end
----- END PERMUTE CODE