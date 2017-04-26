------- BEGIN GLOBALS
-- TODO check/complete it and move to globals
terra_types = {} 
terra_types['I1'] = int8
terra_types['I2'] = int16
terra_types['I4'] = int32
terra_types['I8'] = int64
terra_types['F4'] = float
terra_types['F8'] = double
terra_types['SV'] = int32
-- terra_types['SC'] = "char"
terra_types['B1'] = uint64  

C = terralib.includec("stdlib.h")

-- TODO belongs in utils
function Array(typ)
    -- TODO HOW TO FREE IT ?!
    return terra(N : int)
        var r : &typ = [&typ](C.malloc(sizeof(typ) * N))
        return r
    end
end

-- TODO search for simpler way using FFI in terra ...
arr_elem_setter = function(typ)
  return terra (a: &typ, i: int, v: typ)
    a[i]=v
  end
end

init_arr = function(qtyp, a, sz, t)
  -- set array elems (similar approach can be used for str-to-typ conversions)
  for k,v in pairs(t) do
    arr_elem_setter(terra_types[qtyp])(a, k-1, v)
  end
end

-- TODO added temporarily for use with Terra due to Vector code; discard later
g_chunk_size = nil
g_valid_meta = nil
------- END GLOBALS

--- BEGIN SETUP
--print(package.path)
package.path = package.path .. ';/home/srinath/Ramesh/Q/Q2/code/lua/?.lua;/home/srinath/Ramesh/Q/UTILS/lua/?.lua'

-- for test data
package.path = package.path .. ';/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/test/?.lua'
--- END SETUP
ffi = require 'ffi'
package.terrapath = package.terrapath .. ";/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/terra/?.t"
--print(package.path)
require 'globals'
require 'error_code'
require 'permute'

local Column = require 'Column'

col_from_tab = function(qtyp, data)
  local c = Column{
            field_type=qtyp, 
            write_vector=true}
  
  local N = #data
  local arr = Array(terra_types[qtyp])(N)
  init_arr(qtyp, arr, N, data)
  c:put_chunk(N, arr, nil)
  c:eov()
  return c
end

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