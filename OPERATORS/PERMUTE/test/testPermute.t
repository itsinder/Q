--- BEGIN SETUP
--print(package.path)
package.path = package.path .. ';/home/srinath/Ramesh/Q/Q2/code/lua/?.lua;/home/srinath/Ramesh/Q/UTILS/lua/?.lua;/home/srinath/Ramesh/Q/OPERATORS/MK_COL/lua/?.lua'

-- for test data
package.path = package.path .. ';/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/test/?.lua'
--- END SETUP
ffi = require 'ffi'
package.terrapath = package.terrapath .. ";/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/terra/?.t"
--print(package.path)
require 'globals'
require 'terra_globals'
require 'error_code'
require 'permute'
require 'mk_col'

local Column = require 'Column'

local arr_from_col = function (c, ctype)
  local sz, vec, nn_vec = c:chunk(-1)
  return ffi.cast(ctype, vec)
end

local col_as_str = function (c) 
  local s = ""
  local vec = arr_from_col(c, "int *")
  local N=c:length()
  for i=0,N-1 do
    s = s .. tostring(vec[i]) .. ","
  end
  return s
end

local testdata = require 'testdata_permute'
for k,v in pairs(testdata) do
  print ("running test " .. k)
  status, res = pcall(permute, unpack(v.input))
  if v.fail then
    assert (status == false)
    assert (string.match(res, v.fail))
  else
    assert (status)
    assert (col_as_str(res) == v.output)
  end
  -- TODO assert out_col file size
end
print("Tests passed.")