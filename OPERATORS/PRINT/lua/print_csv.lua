local err	= require 'Q/UTILS/lua/error_code'
local qc	= require 'Q/UTILS/lua/q_core'
local ffi	= require 'Q/UTILS/lua/q_ffi'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local plstring	= require 'pl.stringx'
local utils	= require 'Q/UTILS/lua/utils'

local buf_size = 1024
local buf = ffi.malloc(buf_size)
local buf_copy = ffi.cast("char *", buf)

-- Below tables contains the pointers to chunk
-- Look for the memory constraints
local chunk_buf_table = {}
local chunk_nn_buf_table = {}

local function get_B1_value(buffer, chunk_idx)
  local val
  local bit_value = qc.get_bit_u64(buffer, chunk_idx)
  if bit_value == 0 then
     val = ffi.NULL
  else
     val = 1
  end
  return val
end

local function get_element(col, rowidx)
  local val = nil
  local nn_val = nil
  local chunk_num = math.floor((rowidx - 1) / qconsts.chunk_size)
  local chunk_idx = (rowidx - 1) % qconsts.chunk_size
  local qtype = col:qtype()
  local ctype =  qconsts.qtypes[qtype]["ctype"]
  
  if not chunk_buf_table[col] or chunk_idx == 0 then
    local len, base_data, nn_data = col:chunk(chunk_num)
    assert(len > 0, "Chunk length not greater than zero")
    assert(base_data, "Chunk should not be null")
    base_data = ffi.cast(ctype.." *", base_data)
    chunk_buf_table[col] = base_data
    if nn_data then
      nn_data = ffi.cast(qconsts.qtypes.B1.ctype .. " *", nn_data)
      chunk_nn_buf_table[col] = nn_data
    end
  end
  
  local casted = chunk_buf_table[col]
  local nn_casted = chunk_nn_buf_table[col]
  local status

  -- Check for nn vector
  if nn_casted then
    status, nn_val = pcall(get_B1_value, nn_casted, chunk_idx)
    assert(status, "Failed to get value for nn vec, Error: " .. tostring(nn_val))
    if not nn_val then
      -- Both val and nn_val are null
      return nil, nil
    end
  end

  if qtype == "B1" then
    status, val = pcall(get_B1_value, casted, chunk_idx)
    assert(status, "Failed to get value for B1 vec, Error " .. tostring(val))
  elseif qtype == "SC" then
    val = ffi.string(casted + chunk_idx * col:field_width())
  else
    -- Initialize output buf to zero
    ffi.fill(buf_copy, buf_size)
    
    -- Call respective q_to_txt function
    local q_to_txt_fn_name = qconsts.qtypes[qtype].ctype_to_txt
    status = qc[q_to_txt_fn_name](casted + chunk_idx, nil, buf, buf_size)
    
    -- Extract value
    val = ffi.string(buf)    
    if qtype == "SV" then
      val = col:get_meta("dir"):get_string_by_index(tonumber(val))
    end
  end
  
  return val, nn_val
end

local function chk_cols(vector_list)
  assert(vector_list)
  assert(type(vector_list) == "table")
  assert(utils.table_length(vector_list) > 0)  
  local vec_length = nil
  local is_first = true
  for i, v in pairs(vector_list) do
    assert((type(v) == "lVector"), err.INPUT_NOT_COLUMN_NUMBER)

    -- Check the vector for eval(), if not then call eval()
    if not v:is_eov() then
      v:eval()
    end

    -- eval'ed the vector before calling lenght()
    -- as elements will populate only after eval()
    if is_first then
      vec_length = v:length()
      is_first = false
    end

    -- Added below assert after discussion with Ramesh
    -- We are not supporting vectors with different length as this is a rare case
    -- All vectors should have same length
    assert(v:length() == vec_length, "All vectors should have same length")
    assert(v:length() > 0)
    local qtype = v:qtype()
    assert(qconsts.qtypes[qtype], err.INVALID_COLUMN_TYPE)

    -- dictionary cannot be null in get_meta for SV data type
    if qtype == "SV" then
      assert(v:get_meta("dir"), err.NULL_DICTIONARY_ERROR)
    end
  end
  return true
end

local function process_filter(filter, vec_length)
  local lb = 0; local ub = 0; local where = nil
  if filter then
    assert(type(filter) == "table", err.FILTER_NOT_TABLE_ERROR)
    lb = filter.lb
    ub = filter.ub
    where = filter.where
    if ( where ) then
      assert(type(where) == "lVector",err.FILTER_TYPE_ERROR)
      assert(where:qtype() == "B1",err.FILTER_INVALID_FIELD_TYPE)
    end
    if ( lb ) then
      assert(type(lb) == "number", err.INVALID_LOWER_BOUND_TYPE )
      assert(lb >= 0,err.INVALID_LOWER_BOUND)
    else
      lb = 0;
    end
    if ( ub ) then
      assert(type(ub) == "number", err.INVALID_UPPER_BOUND_TYPE )
      assert(ub > lb ,err.UB_GREATER_THAN_LB)
      assert(ub <= vec_length, err.INVALID_UPPER_BOUND)
    else
      ub = vec_length
    end
  else
    lb = 0
    ub = vec_length
  end
  return where, lb, ub
end

local print_csv = function (vector_list, opfile, filter)
  -- Convention
  -- Q.print_csv(X) -- will print stdout
  -- Q.print_csv(X, "file", <filter>) -- will print to file
  -- Q.print_csv(X, "", <filter>) -- will return string
  
  -- trimming whitespace if any
  if opfile then
    opfile = plstring.strip(opfile)
  end
  assert(((type(vector_list) == "table") or 
          (type(vector_list) == "lVector")), err.INPUT_NOT_TABLE)
  if type(vector_list) == "lVector" then
    vector_list = {vector_list}
  end
  assert(chk_cols(vector_list), "Vectors verification failed")
  local vec_length
  for i, v in pairs(vector_list) do
    vec_length = v:length()
    break
  end
  local where, lb, ub = process_filter(filter, vec_length)
  -- TODO remove hardcoding of 1024
  -- local buf = assert(ffi.malloc(buf_size))
  local num_cols = utils.table_length(vector_list)
  local fp = nil -- file pointer
  local tbl_rslt = nil
  
  -- When output requires as string, we will accumulate partials in tbl_rslt
  if not opfile then
    io.output(io.stdout)
  else
    if ( opfile ~= "" ) then
      fp = io.open(opfile, "w+")
      assert(fp ~= nil, err.INVALID_FILE_PATH)
      io.output(fp)
    else
      tbl_rslt = {}
    end
  end
  
  lb = lb + 1 -- for Lua style indexing
  -- recall that upper bounds are inclusive in Lua
  for rowidx = lb, ub do
    local status, result, is_filter = nil
    if ( where ) then
      status, is_filter = pcall(get_element, where, rowidx)
      assert(status, "Failed to get filter value, Error: " .. tostring(is_filter))
    end
    if ( ( not where ) or ( is_filter ) ) then
      -- Using below modified for loop because if we pass load_csv output to this, it doesn't work
      -- load_csv output doesn't contain integer indices rather it contains column names as indices
      local col_idx = 1
      for _, col in pairs(vector_list) do
        local status, result = nil
        status, result = pcall(get_element, col, rowidx)
        assert(status, "Failed to get value from vector, Error: " .. tostring(result))
        if not result then
          if col:qtype() == "B1" then result = 0 else result = "" end
        end                              
        if tbl_rslt then
          table.insert(tbl_rslt, result) 
          if ( col_idx ~= num_cols ) then 
            table.insert(tbl_rslt, ",") 
          else
            table.insert(tbl_rslt,"\n") 
          end
        else
          assert(io.write(result), "Write failed")
          if ( col_idx ~= num_cols ) then 
            assert(io.write(","), "Write failed")
          else
            assert(io.write("\n"), "Write failed") 
          end
        end
        col_idx = col_idx + 1
      end
    else
      -- Filter says to skip this row 
    end
  end
  if ( tbl_rslt ) then 
    return table.concat(tbl_rslt)
  else
    if fp then io.close(fp) end
    -- return true
  end
end

return require('Q/q_export').export('print_csv', print_csv)
--[[
However, there is a caveat to be aware of. Since strings in Lua are immutable, each concatenation creates a new string object and copies the data from the source strings to it. That makes successive concatenations to a single string have very poor performance.

The Lua idiom for this case is something like this:

function listvalues(s)
    local t = { }
    for k,v in ipairs(s) do
        t[#t+1] = tostring(v)
    end
    return table.concat(t,"\n")
end
By collecting the strings to be concatenated in an array t, the standard library routine table.concat can be used to concatenate them all up (along with a separator string between each pair) without unnecessary string copying.
--]]
