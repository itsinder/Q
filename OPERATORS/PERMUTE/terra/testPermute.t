------- BEGIN GLOBALS
-- TODO check/complete it and move to globals
terra_types = {} 
terra_types["I2"] = int
terra_types["I4"] = int

C = terralib.includec("stdlib.h")

-- TODO belongs in utils
function Array(typ)
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

init_arr = function(ctype, a, sz, t)
  -- set array elems (similar approach can be used for str-to-typ conversions)
  for k,v in pairs(t) do
    arr_elem_setter(ctype)(a, k-1, v)
  end
end

-- TODO added temporarily for use with Terra due to Vector code; discard later
g_chunk_size = nil
g_valid_meta = nil
------- END GLOBALS

--- BEGIN SETUP
--print(package.path)
package.path = package.path .. ';/home/srinath/Ramesh/Q/Q2/code/lua/?.lua;/home/srinath/Ramesh/Q/UTILS/lua/?.lua'
--- END SETUP
ffi = require 'ffi'
package.terrapath = package.terrapath .. ";/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/terra/?.t"
--print(package.path)
require 'globals'
require 'error_code'
require 'permute'
local Column = require 'Column'

local in_col = Column{
          field_type="I4", 
          write_vector=true}
local data = {10, 20, 30, 40, 50, 60}
local N = #data
local in_arr = Array(int)(N)
init_arr(int, in_arr, N, data)
in_col:put_chunk(N, in_arr, nil)
in_col:eov()

local arr_from_col = function (c, ctype)
  local sz, vec, nn_vec = c:chunk(0)
  return ffi.cast(ctype, vec)
end

local col_as_str = function (c) 
  local s = ""
  local vec = arr_from_col(c, "int *")
  for i=0,N-1 do
    s = s .. tostring(vec[i]) .. ","
  end
  return s
end

--print("----")
--print(col_as_str(in_col))

--for i=1,4 do
local out_col = permute(in_col, {0, 5, 1, 4, 2, 3})
--print("----")
--print(col_as_str(out_col))

assert(col_as_str(out_col) == "10,60,20,50,30,40,")
--end

print("Tests passed.")