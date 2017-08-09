local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require "Q/UTILS/lua/q_ffi"

return function (col, rowidx)
  local chunk_num = math.floor((rowidx-1)/qconsts.chunk_size)
  local chunk_idx = (rowidx-1) % qconsts.chunk_size
  --print("Chunk Num "..tostring(chunk_num))
  --print("Chunk_idx "..tostring(chunk_idx))
  local temp=""
  local len, base_data, nn_data = col:get_chunk(chunk_num)
  local qtype = col:qtype() 
  if base_data == ffi.NULL then
    temp = ""
  else
    local is_SC = qtype == "SC"    -- if field type is SC , then pass field size, else nil
    local is_SV = qtype == "SV"    -- if field type is SV , then get value from dictionary
    local is_I8 = qtype == "I8" 
    
    local ctype =  qconsts.qtypes[qtype]["ctype"]
    local str = ffi.cast(ctype.." *", base_data)
    temp = tostring(str[chunk_idx])
            
    -- to check if LL is present and then remove LL appended at end of I8 number
    if is_I8 then
      local index1, index2 = string.find(temp,"LL")
      local string_length = #temp
      if index1 == string_length-1 and index2 == string_length then
        temp = string.sub(temp, 1, -3) 
      end
    end
            
            
    if is_SC == true then
      temp = ffi.string(str + chunk_idx * col:field_width())
    end
            
    if is_SV == true then 
      temp = str[0]
      local dictionary = col:get_meta("dir")
      temp = dictionary:get_string_by_index(temp)
    end
  end
  --print("Returning "..tostring(temp))  
  return temp
end
