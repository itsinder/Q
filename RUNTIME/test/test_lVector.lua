local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/RUNTIME/test/"
assert(plpath.isdir(path_to_here))
require 'Q/UTILS/lua/strict'

local v
local ival
local databuf
local x
local T
local md -- meta data 

-- generating .bin files required for materialized vector
local status
status = os.execute("../../UTILS/src/asc2bin in1_I4.csv I4 _in1_I4.bin")
assert(status)
status = os.execute("../../UTILS/src/asc2bin in1_B1.csv B1 _nn_in1.bin")
assert(status)
status = os.execute("cp _in1_I4.bin _in2_I4.bin")
assert(status)

local tests = {} 
--===================
function pr_meta(x, file_name)
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
function compare(f1, f2)
  local s1 = plfile.read(f1)
  local s2 = plfile.read(f2)
  assert(s1 == s2, "mismatch in " .. f1 .. " and " .. f2)
end
--=========================
--
tests.t1 = function()
  x = lVector(
  { qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin"})
  assert(x:check())
  pr_meta(x, "_meta_data.csv")
  compare("_meta_data.csv", "in1_meta_data.csv")
  local len, base_data, nn_data = x:chunk(0)
  assert(base_data)
  assert(nn_data)
  print(len)
  print("Successfully completed test t1")
end
--=========

tests.t2 = function()
  x = lVector( { qtype = "I4", file_name = "_in2_I4.bin"})
  assert(x:check())
  local n = x:num_elements()
  assert(n == 10)
  --=========
  local len, base_data, nn_data = x:chunk(0)
  assert(base_data)
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
  --=========
end

--====== Testing nascent vector
tests.t3 = function()
  print("Creating nascent vector")
  x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, num_elements do
    iptr[i-1] = i*10
  end
  x:put_chunk(base_data, nil, num_elements)
  assert(x:check())
  x:eov()
  assert(x:check())
  pr_meta(x, "_xxx")
  print("Successfully completed test t3")
end

--====== Testing nascent vector with scalars
tests.t4 = function()
  x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, num_elements do
    local s1 = Scalar.new(i*11, "I4")
    x:put1(s1)
    assert(x:check())
  end
  x:eov()
  assert(x:check())
  md = pr_meta(x, "_meta_data")
  -- print(">>>> ", md.base.file_name)
  assert(plpath.getsize(md.base.file_name) == num_elements * field_size)
  -- Check that nn_file_name does not exist
  local s = plfile.read("_meta_data")
  local x, y = string.find(s, "nn_file_name")
  assert(not x)
  print("Successfully completed test t4")
end

tests.t5 = function()
  x = lVector( { qtype = "I4", gen = true})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  status = pcall(x.put_chunk, base_data, nil, num_elements)
  assert(not status)
  print("Successfully completed test t5")
end

tests.t6 = function()
  print("Testing nascent vector with scalars and nulls")
  x = lVector( { qtype = "I4", gen = true})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  print("----------------------_XXX----------")
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, num_elements do
    local s1 = Scalar.new(i*11, "I4")
    local s2
    if ( ( i % 2 ) == 0 ) then
      s2 = Scalar.new(true, "B1")
    else
      s2 = Scalar.new(false, "B1")
    end
    x:put1(s1, s2)
    assert(x:check())
  end
  x:eov()
  assert(x:check())
  md = pr_meta(x, "_meta_data")
  assert(plpath.getsize(md.base.file_name) == num_elements * field_size)
  assert(plpath.getsize(md.nn.file_name) == num_elements / 8)
  -- Check that nn_file_name exists
  local s = plfile.read("_meta_data")
  local x, y = string.find(s, "nn_file_name")
  assert(x)
  print("Successfully completed test t6")
end
--===========================================

--====== Testing nascent vector with generator
tests.t7 = function()
  print("Creating nascent vector with generator")
  local gen1 = require 'Q/RUNTIME/test/gen1'
  x = lVector( { qtype = "I4", gen = gen1, has_nulls = false} )
  x:persist(true)

  local x_num_chunks = 10
  local num_chunks = 0
  local chunk_size = qconsts.chunk_size
  for chunk_num = 1, x_num_chunks do 
    print("XX: ", chunk_num, x_num_chunks)
    local a, b, c = x:chunk(chunk_num-1)
    if ( a < chunk_size ) then 
      print("Breaking on chunk", chunk_num); 
      assert(x:is_eov() == true)
      break 
    end
    num_chunks = num_chunks + 1
    assert(a == chunk_size)
    x:check()
    print("XX: ", chunk_num, x_num_chunks)
  end
  status = pcall(x.eov)
  assert(not status)
  local T = x:meta()
  assert(plpath.getsize(T.base.file_name) == (num_chunks * chunk_size * 4))
  print("Successfully completed test t7")
end
--===========================================

--====== Testing nascent vector with generator and Vector's buffer
tests.t8 = function()
  print("Creating nascent vector with generator using Vector buffer")
  local gen2 = require 'Q/RUNTIME/test/gen2'
  x = lVector( { qtype = "I4", gen = gen2, has_nulls = false})

  local num_chunks = 2
  local chunk_size = qconsts.chunk_size
  print("===================")
  for chunk_num = 1, num_chunks do 
    local a, b, c = x:chunk(chunk_num-1)
    x:check()
  end
  assert(x:is_eov() == true)
  status = pcall(x.eov)
  assert(not status)
  local len, base_data, nn_data = x:chunk(0)
  assert(base_data)
  assert(not nn_data)
  assert(len == chunk_size )

  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, len do
    -- TODO P1 assert(iptr[i-1] == i)
  end
  print("Successfully completed test t8")
end

--====== Testing materialized vector for SC
tests.t9 = function()
  print("Testing materialized vector for SC")
  os.execute(" cp SC1.bin _SC1.bin " )
  x = lVector( { qtype = "SC", width = 8, file_name = '_SC1.bin' } )
  T = x:meta()
  -- local k, v
  for k, v in pairs(T.base)  do print(k,v) end 
  for k, v in pairs(T.aux)  do print(k,v) end 
  local num_aux = 0
  for k, v in pairs(T.aux)  do num_aux = num_aux + 1 end 
  assert(not T.nn) 
  assert(num_aux == 0) -- TODO WHY DO WE HAVE AUX DATA HERE?
  --===========================================
  print("Successfully completed test t9")
end

tests.t10 = function()
  -- testing setting and getting of meta data 
  local x = lVector( { qtype = "I4", file_name = "_in2_I4.bin"})
  x:set_meta("rand key", "rand val")
  v = x:get_meta("rand key")
  assert(v == "rand val")
  x:set_meta("rand key", "some other rand val")
  v = x:get_meta("rand key")
  assert(v == "some other rand val")
  plfile.delete("./_meta_data.csv")
  pr_meta(x, "_meta_data.csv")
  compare("_meta_data.csv", "in2_meta_data.csv")

  print("Successfully completed test t10")
end
--==============================================
tests.t11 = function()
  -- testing setting and getting of meta data with a Scalar
  local x = lVector( { qtype = "I4", file_name = "_in2_I4.bin"})
  local s = Scalar.new(1000, "I8")
  x:set_meta("rand scalar key", s)
  v = x:get_meta("rand scalar key")
  assert(v == s)
  print("Successfully completed test t11")
end

return tests
