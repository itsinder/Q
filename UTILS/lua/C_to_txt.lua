require 'globals'
local ffi = require "ffi"

return function (col, rowidx)
  local temp=""
  local cbuf = col:get_element(rowidx-1)  
  
  local bufsz = 1024
  local buf = ffi.gc(ffi.C.malloc(bufsz), ffi.C.free) 
         
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
  
  return temp
end