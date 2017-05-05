require 'globals'
local g_err = require 'error_code'
local ffi_malloc = require 'ffi_malloc'
local ffi = require "ffi"
local plstring = require 'pl.stringx'

local function strip_trailing_LL(temp)
  local index1, index2 = string.find(temp,"LL")
  local string_length = #temp
  if index1 == string_length-1 and index2 == string_length then
    temp = string.sub(temp, 1, -3) 
  end
  return temp
end

local function chk_cols(column_list)
  local max_length = 0
  local is_SC  = {}
  local is_SV  = {}
  local is_I8  = {}
  local is_col = {}
  for i = 1, #column_list do
    assert( ((type(column_list[i]) == "Column") or 
             (type(column_list[i]) == "number")),
      g_err.INPUT_NOT_COLUMN_NUMBER)
      
    is_col[i] = type(column_list[i]) == "Column" 
    if is_col[i] then
      assert(g_valid_types[column_list[i]:fldtype()], 
      g_err.INVALID_COLUMN_TYPE)
      assert(g_qtypes[column_list[i]:fldtype()] ~= "B1", 
        g_err.COLUMN_B1_ERROR) --TODO TO BE IMPLEMENTED
      -- dictionary cannot be null in get_meta for SV data type
      if column_list[i]:fldtype() == "SV" then 
        assert(column_list[i]:get_meta("dir"), g_err.NULL_DICTIONARY_ERROR)
      end
      -- Take the maximum length of all columns
      local tmp = column_list[1]:length()
      if tmp > max_length then max_length = tmp end
      is_SC[i] = col:fldtype() == "SC"    
            -- if field type is SC , then pass field size, else nil
      is_SV[i] = col:fldtype() == "SV"    
            -- if field type is SV , then get value from dictionary
      is_I8[i] = col:fldtype() == "I8" 
            -- if field type is I8 , then remove LL appended at end
    end
    assert(max_length > 0, "Nothing to print")
    return is_SC, is_SV, is_I8, is_col, max_length
  end
end

function process_filter(filter)
  local lb = 0; local ub = 0; local where = nil
  if filter then
    assert(type(filter) == "table", g_err.FILTER_NOT_TABLE_ERROR)
    lb = filter.lb
    ub = filter.ub
    where = filter.where
    if ( where ) then
      assert(type(where) == "Vector",g_err.FILTER_TYPE_ERROR)
      -- VIJAY: Should above be Column instead of Vector?  
      assert(where:fldtype() == "B1",g_err.FILTER_INVALID_FIELD_TYPE)
    end
    if ( lb ) then
      assert(type(lb) == "number", g_err.INVALID_LOWER_BOUND_TYPE )
      lb = assert(tonumber(lb))
      assert(lb >= 0,g_err.INVALID_LOWER_BOUND)
    else
      lb = 0;
    end
    if ( ub ) then
      assert(type(ub) == "number", g_err.INVALID_UPPER_BOUND_TYPE )
      ub = assert(tonumber(ub))
      assert(ub > lb ,g_err.UB_GREATER_THAN_LB)
      assert(ub <= max_length, g_err.INVALID_UPPER_BOUND)
    else
      ub = max_length
    end
  else
    lb = 0
    ub = max_length
  end
  return where, lb, ub
end

return function (column_list, filter, opfile)  
  
  -- trimming whitespace if any
  if opfile ~= nil then
    opfile = plstring.strip(opfile)
  end
  
  assert( ((type(column_list) == "table") or 
          (type(column_list) == "Column")), g_err.INPUT_NOT_TABLE)
  -- to do unit testing with columns of differet length
  if type(column_list) == "Column" then
    column_list = {column_list}
  end
  
  -- Initially, all columns had to be same length. That has been relaxed.

  local is_SC, is_SV, is_I8, is_col, max_length = chk_cols(column_list)
  local where, lb, ub = process_filter(filter)
  -- TODO remove hardcoding of 1024
  local buf = ffi_malloc(1024) 
  local num_cols = #column_list
  local fp = nil -- file pointer
  local tbl_rslt = nil 
  -- When output requires as string, we will accumulate partials in tbl_rslt
  if not opfile then 
    tbl_rslt = {}
  else
    if ( opfile ~= "" ) then
      fp = io.open(opfile, "w+")
      io.output(fp)
      destination = "file"
    end
  end
  
  lb = lb + 1 -- for Lua style indexing
  -- recall that upper bounds are inclusive in Lua
  for rowidx = lb, ub do
    if ( ( where == nil ) or 
         ( where:get_element(rowidx -1 ) ~= ffi.NULL ) ) then
      for colidx = 1, num_cols do
        local temp = nil
        local col = column_list[colidx]
        -- if input is scalar, assign scalar value
        if is_col[colidx] then 
          temp = col 
        else
          local cbuf = col:get_element(rowidx-1)          
          if cbuf == ffi.NULL then
            temp = ""
          else
            local ctype =  assert(g_qtypes[col:fldtype()]["ctype"])
            local str = ffi.cast(ctype.." *",cbuf)
            temp = tostring(str[0])
            if is_I8[col_idx] then
              temp = strip_trailing_LL(temp)
            end
            if is_SC[col_idx] then
              temp = ffi.string(str)
            end
            if is_SV[col_idx] then 
               temp = str[0]
               local dictionary = col:get_meta("dir")
               temp = dictionary:get_string_by_index(temp)
            end
          end
        end
        if tbl_rslt then 
          table.insert(tbl_rslt, temp) 
          table.insert(tbl_rslt, ",") 
        else
          assert(io.write(temp), "Write failed")
          assert(io.write(","), "Write failed")
        end
      end
    else
      -- Filter says to skip this row 
    end
    -- Put in eoln because row is over
    if ( tbl_rslt ) then 
      table.insert(tbl_rslt,"\n") 
    else
      assert(io.write("\n"), "Write failed") 
    end
  end
  if ( tbl_rslt ) then 
    return table.concat(tbl_rslt)
  else
    if fp then io.close(fp) end
    return true
  end
end
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
