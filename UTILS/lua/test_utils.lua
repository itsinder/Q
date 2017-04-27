local ffi = require 'ffi'
local utils
utils = {
  arr_from_col = function (c)
    local sz, vec, nn_vec = c:chunk(-1)
    local ctype = g_valid_types[c:fldtype()] .. " *"
    return ffi.cast(ctype, vec)
  end,
  
  col_as_str = function (c) 
    local s = ""
    local vec = utils.arr_from_col(c)
    local N=c:length()
    for i=0,N-1 do
      s = s .. tostring(vec[i]) .. ","
    end
    return s
  end
}

return utils