require 'globals'
local g_err = require 'error_code'
local fn_malloc = require 'ffi_malloc'
local ffi = require "ffi"
local plstring = require 'pl.stringx'

return function (column_list, filter, opfile)  
  
  -- trimming whitespace if any
  if opfile ~= nil then
    opfile = plstring.strip(opfile)
  end
  
  assert(type(column_list) == "table" or type(column_list) == "Column",g_err.INPUT_NOT_TABLE)
  -- to do unit testing with columns of differet length
  if type(column_list) == "Column" then
    column_list = {column_list}
  end
  
  local max_length = 0
  for i = 1, #column_list do
    assert(type(column_list[i]) == "Column" or type(column_list[i]) == "number", 
      g_err.INPUT_NOT_COLUMN_NUMBER)
      
    local is_column = type(column_list[i]) == "Column" 
    if is_column then
      --assert(column_list[i]:length() == max_length, "All columns should have the same length")
      assert(g_valid_types[column_list[i]:fldtype()] ~= nil, g_err.INVALID_COLUMN_TYPE)
      assert(g_qtypes[column_list[i]:fldtype()] ~= "B1", g_err.COLUMN_B1_ERROR)
      assert(g_qtypes[column_list[i]:fldtype()]["width"] ~= nil, g_err.NULL_WIDTH_ERROR)
      assert(g_qtypes[column_list[i]:fldtype()]["ctype"] ~= nil, g_err.NULL_CTYPE_ERROR)
      assert(g_qtypes[column_list[i]:fldtype()]["ctype_to_txt"] ~= nil, g_err.NULL_CTYPE_TO_TXT_ERROR)
      -- dictionary cannot be null in get_meta for SV data type
      if column_list[i]:fldtype() == "SV" then 
        assert(column_list[i]:get_meta("dir"), g_err.NULL_DICTIONARY_ERROR)
      end
      -- Take the maximum length of all columns
      local tmp = column_list[1]:length()
      if tmp > max_length then max_length = tmp end
    end
  end
  
  local lb = 0; local ub = 0
  local where
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
  -- to do remove hardcoding of 1024
  local buf = fn_malloc(1024) 
  local num_cols = #column_list
  local file = nil
  local final_result = ""
  local flag = { }
  if not opfile then 
    final_result = ""  -- we will produce string as output
    flag[1] = true     -- if input csv file is nil, then set flag[1] to true  
  else
    if ( opfile == "" ) then
      -- we will write to stdout
      final_result = ""
      flag[2] = true      -- if input csv file is empty string, then set flag[2] to true
    else
      file = io.open(opfile, "w+")
      io.output(file)
      flag[3] = true      --  if input csv file is valid, then set flag[3] to true
    end
  end
  
  local result = { }
  lb = lb + 1 -- for Lua style indexing
  for rowidx = lb, ub do
    if where == nil or where:get_element(rowidx -1 ) ~= ffi.NULL then
      for colidx = 1, num_cols do
        local temp
        local col = column_list[colidx]
        -- if input is scalar, assign scalar value
        if type(col) == "number" then 
          temp = col 
        else
          local cbuf = col:get_element(rowidx-1)          
          
          if cbuf == ffi.NULL then
            temp = ""
          else
            local is_SC = col:fldtype() == "SC"    -- if field type is SC , then pass field size, else nil
            local is_SV = col:fldtype() == "SV"    -- if field type is SV , then get value from dictionary
            local is_I8 = col:fldtype() == "I8" 
            
            local ctype =  g_qtypes[col:fldtype()]["ctype"]
            local str = ffi.cast(ctype.." *",cbuf)
            temp = tostring(str[0])
            
            -- to check if LL is present and then remove LL appended at end of I8 number
            if is_I8 then
              local index1, index2 = string.find(temp,"LL")
              local string_length = #temp
              if index1 == string_length-1 and index2 == string_length then
                temp = string.sub(temp, 1, -3) 
              end
            end
            
            
            if is_SC == true then
              temp = ffi.string(str)
            end
            
            if is_SV == true then 
               temp = str[0]
               local dictionary = col:get_meta("dir")
               temp = dictionary:get_string_by_index(temp)
            end
            
          end
        end
        
        table.insert(result, temp) 
        if colidx ~= num_cols then table.insert(result, ",") end
        
        if flag[3] then 
          assert(io.write(temp),g_err.INVALID_FILE_PATH)
          if colidx ~= num_cols then 
            assert(io.write(","),g_err.INVALID_FILE_PATH) 
          end
        end
        
      end

      table.insert(result,"\n") 
      if flag[3] then assert(io.write("\n"),g_err.INVALID_FILE_PATH) end
    end
  end
  

  if file then
    io.close(file)
  end
  final_result = table.concat(result)
  if flag[1] then return final_result end 
  if flag[2] then print(final_result) end 
  
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
