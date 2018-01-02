local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
local fns = require 'Q/RUNTIME/test/generate_csv'
local genbin = require 'Q/RUNTIME/test/generate_bin'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local c_to_txt     = require 'Q/UTILS/lua/C_to_txt'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/RUNTIME/test/"
assert(plpath.isdir(path_to_here))
require 'Q/UTILS/lua/strict'

local v
local ival
local databuf
local x
local T
local md -- meta data

-- testcases for lVector ( materialized vector )
local tests = {} 

--===================
local function pr_meta(x, file_name)
  local T = x:meta()
  local temp = io.output() -- this is for debugger to work 
  io.output(file_name)
  io.write(" return { ")
  for k1, v1 in pairs(T) do 
    for k2, v2 in pairs(v1) do 
      io.write(k1 .. "_" ..  k2 .. " = \"" .. tostring(v2) .. "\",")
      io.write("\n")
    end
  end
  io.write(" } ")
  io.close()
  io.output(temp) -- this is for debugger to work 
  return T
end
--=========================
local function compare(f1, f2)
  local s1 = plfile.read(f1)
  local s2 = plfile.read(f2)
  assert(s1 == s2, "mismatch in " .. f1 .. " and " .. f2)
end
--=========================

--====== Testing materialized vector
tests.t1 = function()

  local num_values = 10
  local q_type = "I4"
  -- generating .bin files required for materialized vector
  genbin.generate_bin(num_values, q_type, path_to_here .. "_in1_I4.bin", "iter" )
  q_type = "B1"
  genbin.generate_bin(num_values, q_type, path_to_here .. "_nn_in1.bin")
  
  x = lVector(
  { qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin"})
  assert(x:check())
  pr_meta(x, "_t1_meta_data.csv")
  compare("_t1_meta_data.csv", "in1_meta_data.csv")
  local len, base_data, nn_data = x:chunk(0)
  assert(base_data)
  assert(nn_data)
  print(len)
  print("Successfully completed test t1")

  --plfile.delete(path_to_here .. "/_in1_I4.bin")
  --plfile.delete(path_to_here .. "/_nn_in1.bin")
end
--=========


tests.t2 = function()

  local num_values = 10
  local q_type = "I4"
  -- generating .bin files required for materialized vector
  genbin.generate_bin(num_values,q_type, path_to_here .. "_in2_I4.bin", "iter" )
  
  x = lVector( { qtype = "I4", file_name = "_in2_I4.bin"})
  assert(x:check())
  local n = x:num_elements()
  print(x:meta().base.file_name)
  assert(n == 10)
  --=========
  local len, base_data, nn_data = x:chunk(0)
  assert(base_data)
  for i = 1, len do
    local val = c_to_txt(x, i)
    print("value:",val)
  end
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, len do
    assert(iptr[i-1] == (i*10))
  end
  assert(not nn_data)
  assert(len == 10)
  --=========
  len, base_data, nn_data = x:chunk(100)
  assert(not base_data)
  assert(not nn_data)
  print("Successfully completed test t2")
  --plfile.delete(path_to_here .. "/in2_I4.csv")
  --plfile.delete(path_to_here .. "/_in2_I4.bin")
  --=========
end

--====== Testing materialized vector for SC
tests.t3 = function()
  print("Testing materialized vector for SC")
  -- os.execute(" cp SC1.bin _SC1.bin " )
  x = lVector( { qtype = "SC", width = 8, file_name = 'SC1.bin' } )
  T = x:meta()
  -- local k, v
  for k, v in pairs(T.base)  do print(k,v) end 
  for k, v in pairs(T.aux)  do print(k,v) end 
  local num_aux = 0
  for k, v in pairs(T.aux)  do num_aux = num_aux + 1 end 
  assert(not T.nn) 
  assert(num_aux == 0) -- TODO WHY DO WE HAVE AUX DATA HERE?
  --===========================================
  print("Successfully completed test t3")
end

tests.t4 = function()
  
  local num_values = 10
  local q_type = "I4"
  -- generating .bin files required for materialized vector
  genbin.generate_bin(num_values,q_type, path_to_here .. "_in3_I4.bin", "iter" )
  
  -- testing setting and getting of meta data 
  local x = lVector( { qtype = "I4", file_name = "_in3_I4.bin"})
  x:set_meta("rand key", "rand val")
  v = x:get_meta("rand key")
  assert(v == "rand val")
  x:set_meta("rand key", "some other rand val")
  v = x:get_meta("rand key")
  assert(v == "some other rand val")
  plfile.delete("./_meta_data.csv")
  pr_meta(x, "_t4_meta_data.csv")
  compare("_t4_meta_data.csv", "in2_meta_data.csv")

  print("Successfully completed test t4")
  --plfile.delete(path_to_here .. "/in3_I4.csv")
  --plfile.delete(path_to_here .. "/_in3_I4.bin")
end

--==============================================
tests.t5 = function()
    local num_values = 10
  local q_type = "I4"
  -- generating .bin files required for materialized vector
  genbin.generate_bin(num_values,q_type, path_to_here .. "_in4_I4.bin", "iter" )
  
  -- testing setting and getting of meta data with a Scalar
  local x = lVector( { qtype = "I4", file_name = "_in4_I4.bin"})
  local s = Scalar.new(1000, "I8")
  x:set_meta("rand scalar key", s)
  v = x:get_meta("rand scalar key")
  assert(v == s)
  print("Successfully completed test t5")
  --plfile.delete(path_to_here .. "/in4_I4.csv")
  --plfile.delete(path_to_here .. "/_in4_I4.bin")
end

return tests