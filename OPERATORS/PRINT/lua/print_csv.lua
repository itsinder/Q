local err     = require 'Q/UTILS/lua/error_code'
local qc      = require 'Q/UTILS/lua/q_core'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local plstring = require 'pl.stringx'

local buf_size = 1024

local chunk_buf_table = {}
local chunk_nn_buf_table = {}

local function strip_trailing_LL(temp)
  local index1, index2 = string.find(temp,"LL")
  local string_length = #temp
  if index1 == string_length-1 and index2 == string_length then
    temp = string.sub(temp, 1, -3) 
  end
  return temp
end

local function get_B1_value(buffer, chunk_idx)
  local val
  local char_idx = chunk_idx / 8
  local bit_idx = chunk_idx % 8
  local char_value = buffer + char_idx
  local bit_value = tonumber(qc.get_bit(char_value, bit_idx))
  print("\nGetting B1\n")
  if bit_value == 0 then
     val = ffi.NULL
  else
     val = 1
  end
  print(val)
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
    print("\n Fetchin chunk \n")
    local len, base_data, nn_data = col:chunk(chunk_num)
    --TODO: check below condition if it is proper or not
    if len == nil or len == 0 then return 0 end
    if base_data then
      print("\n Base Data is not nil \n")
      base_data = ffi.cast(ctype.." *", base_data)
      chunk_buf_table[col] = base_data
      print("\n Base Data Casting Done \n")
    end
    if nn_data then
      print("\n NN Data is not nil \n")
      nn_data = ffi.cast("unsigned char *", nn_data)
      chunk_nn_buf_table[col] = nn_data
      print("\n NN Data Casting Done \n")
    end
  end
  
  local casted = chunk_buf_table[col]
  local nn_casted = chunk_nn_buf_table[col]
  
  if not casted then
    val = ffi.NULL
  else
    if qtype == "B1" then
      val = get_B1_value(casted, chunk_idx)
    else
      val = casted[chunk_idx]
    end

    if ( qtype == "I8" ) then
      -- Remove LL appended at end of I8 number
      val = tonumber(strip_trailing_LL(tostring(val)))
    elseif ( qtype == "SC" ) then
      val = ffi.string(casted + chunk_idx * col:field_width())
    elseif ( qtype == "SV" ) then 
      local dictionary = col:get_meta("dir")
      val = dictionary:get_string_by_index(tonumber(val))
    end

    -- Check for nn vector
    if nn_casted then
      nn_val = get_B1_value(casted, chunk_idx)
      if not nn_val then
        val = ffi.NULL
      end
    end
  end
  print("\n Returning \n")
  print(val)
  print(nn_val)
  return val, nn_val
end

local function chk_cols(column_list)
  assert(column_list)
  assert(type(column_list) == "table")
  assert(#column_list > 0)
  for i = 1, #column_list do
    assert(type(column_list[i]) == "lVector")
    assert(column_list[i]:length() > 0)    
  end
  
  local is_SC  = {}
  local is_SV  = {}
  local is_I8  = {}
  local is_col = {}
  local is_B1 = {}
  local max_length = column_list[1]:length()
  for i = 1, #column_list do
    assert( ((type(column_list[i]) == "lVector") or 
             (type(column_list[i]) == "number")),
      err.INPUT_NOT_COLUMN_NUMBER)
    
    is_col[i] = type(column_list[i]) == "lVector" 
    if is_col[i] then
      local qtype = column_list[i]:qtype()
      assert(qconsts.qtypes[qtype], err.INVALID_COLUMN_TYPE)
      -- dictionary cannot be null in get_meta for SV data type
      if qtype == "SV" then 
        assert(column_list[i]:get_meta("dir"), err.NULL_DICTIONARY_ERROR)
      end
      -- Take the maximum length of all columns
      if column_list[i]:length() > max_length then 
        max_length = column_list[i]:length() 
      end
      is_B1[i] = qtype == "B1"
      is_SC[i] = qtype == "SC"    
      is_SV[i] = qtype == "SV"    
      is_I8[i] = qtype == "I8" 
    end
    assert(max_length > 0, "Nothing to print")
  end
  return is_SC, is_SV, is_I8, is_col, is_B1, max_length
end

local function process_filter(filter, max_length)
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
      lb = assert(tonumber(lb))
      assert(lb >= 0,err.INVALID_LOWER_BOUND)
    else
      lb = 0;
    end
    if ( ub ) then
      assert(type(ub) == "number", err.INVALID_UPPER_BOUND_TYPE )
      ub = assert(tonumber(ub))
      assert(ub > lb ,err.UB_GREATER_THAN_LB)
      assert(ub <= max_length, err.INVALID_UPPER_BOUND)
    else
      ub = max_length
    end
  else
    lb = 0
    ub = max_length
  end
  return where, lb, ub
end

local print_csv = function (column_list, filter, opfile)    
  -- trimming whitespace if any
  if opfile ~= nil then
    opfile = plstring.strip(opfile)
  end
  
  assert(((type(column_list) == "table") or 
          (type(column_list) == "lVector")), err.INPUT_NOT_TABLE)
  -- to do unit testing with columns of differet length
  if type(column_list) == "lVector" then
    column_list = {column_list}
  end
  
  local is_SC, is_SV, is_I8, is_col, is_B1, max_length = chk_cols(column_list)
  local where, lb, ub = process_filter(filter, max_length)
  
  -- TODO remove hardcoding of 1024
  local buf = assert(ffi.malloc(buf_size))
  local num_cols = #column_list
  local fp = nil -- file pointer
  local tbl_rslt = nil 
  -- When output requires as string, we will accumulate partials in tbl_rslt
  if not opfile then 
    tbl_rslt = {}
  else
    if ( opfile ~= "" ) then
      fp = io.open(opfile, "w+")
      assert(fp ~= nil, g_err.INVALID_FILE_PATH)
      io.output(fp)
    else
      io.output(io.stdout)
    end
  end
  
  lb = lb + 1 -- for Lua style indexing
  -- recall that upper bounds are inclusive in Lua
  for rowidx = lb, ub do
    local status, result = nil
    if ( where ~= nil ) then
      status, result = pcall(get_element, where, rowidx)
    end
    if ( ( where == nil ) or 
         ( result ~= nil ) ) then
      for col_idx = 1, num_cols do
        local status, result = nil
        local col = column_list[col_idx]
        -- if input is scalar, assign scalar value
        if not is_col[col_idx] then
          result = col
        else
          status, result = pcall(get_element, col, rowidx)
          print("\n\n RESULT IS \n\n")
          print(result)
          print(status)
          print("\n\n")
          if status == false then
            --TODO: Handle this condition
          end
          if result == nil then
            if is_B1[col_idx] == true then result = 0 else result = "" end
          end
          if ( not ( is_SC[col_idx] or is_SV[col_idx] ) ) 
          and ( result ~= "" ) then
            result = tonumber(result)
          end                              
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
