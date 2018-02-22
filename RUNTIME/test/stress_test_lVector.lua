local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
-- TODO How to prevent hard coding below?
ffi.cdef([[
typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  char field_type[4]; // MAX_LEN_FIELD_TYPE TODO Fix hard coding
  char cell_name[16]; // 15 chaarcters + 1 for nullc, mainly for debugging
} CMEM_REC_TYPE;
]]
)
require 'Q/UTILS/lua/strict'
local tests = {} 
-- 
tests.t1 = function()
  local num_iters = 1024
  for i = 1, num_iters do
    local x = lVector( { qtype = "I4", gen = true, name = "x"})
    local num_elements = 1048576+3
    local field_size = 4
    local num_bytes = num_elements * field_size
    local base_data = cmem.new(num_bytes, "I4", "base")
    local b2 = ffi.cast("CMEM_REC_TYPE *", base_data)
    local iptr = ffi.cast("int32_t *", b2)
    local chunk_num = 0
    local chunk_idx = 1
    for i = 1, num_elements do
      local s1 = Scalar.new(i*11, "I4")
      local s2 
      if ( ( i % 2 ) == 0 ) then
        s2 = Scalar.new(true, "B1")
      else
        s2 = Scalar.new(false, "B1")
      end
      x:put1(s1, s2)

      local a, b, c, d = x:chunk(chunk_num)
      if ( ( i % qconsts.chunk_size ) == 0 ) then 
        chunk_num = chunk_num + 1
      end
      if ( ( i % qconsts.chunk_size ) == 1 ) then 
        chunk_idx = 1
      end
      assert(a == chunk_idx)
      --[[
      if ( a < qconsts.chunk_size ) then 
        assert(a == i)
      else
        assert(a == qconsts.chunk_size)
      end
      --]]
      assert(type(b) == "CMEM")
      assert(type(c) == "CMEM") -- because there is a null vector
      assert(d == nil)
      local s1, s2 = x:get_one(i-1)
      assert(type(s1) == "Scalar")
      assert(s1:fldtype() == "I4")
      assert(type(s2) == "Scalar")
      assert(s2:fldtype() == "B1")
      chunk_idx = chunk_idx + 1
    end
    x:eov()
    local T = x:meta()
    assert(plpath.isfile(T.base.file_name))
    print("Iter = ", i)
  end
  print("Successfully completed test t1")
end

return tests
