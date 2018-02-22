local Scalar	= require 'libsclr'
local lVector	= require 'Q/RUNTIME/lua/lVector'
local cmem	= require 'libcmem'
local ffi	= require 'Q/UTILS/lua/q_ffi'
local c_to_txt	= require 'Q/UTILS/lua/C_to_txt'
local ffi = require 'ffi'
-- TODO How to prevent hard coding below?
ffi.cdef([[
extern char *strcpy(char *dest, const char *src);
extern char *strncpy(char *dest, const char *src, size_t n);

typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  char field_type[4]; // MAX_LEN_FIELD_TYPE TODO Fix hard coding
  char cell_name[16]; // 15 chaarcters + 1 for nullc, mainly for debugging
} CMEM_REC_TYPE;
]]
)

local tests = {}
--====== Testing vector cloning
tests.t1 = function()
  print("Creating vector")
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 1024
  local field_size = 4
  local c = cmem.new(num_elements * field_size, "I4")
  local c2 = ffi.cast("CMEM_REC_TYPE *", c)
  local iptr = ffi.cast("int32_t *", c2[0].data)
  for i = 1, num_elements do
    iptr[i-1] = i*10
  end
  x:put_chunk(c, nil, num_elements)
  x:eov()
  x:persist(true)
  
  -- set metadata
  x:set_meta("key1", "val1")

  print("Cloning vector")
  local x_clone = x:clone()
  assert(x_clone:num_elements() == num_elements)

  x_meta = x:meta()
  x_clone_meta = x_clone:meta()

  -- persist flag should be false
  assert(x_clone_meta.base.is_persist == false)

  -- OPEN_MODE should be zero
  assert(x_clone_meta.base.open_mode == "NOT_OPEN")

  -- compare base metadata
  for i, v in pairs(x_meta.base) do
    if not ( i == "file_name" or i == "open_mode" or i == "is_persist" ) then
      assert(v == x_clone_meta.base[i])
    end
  end

  -- compare aux metadata
  for i, v in pairs(x_meta.aux) do
    print(i, v)
    assert(v == x_clone_meta.aux[i])
  end

  -- compare vector elements
  for i = 1, x_clone:num_elements() do
    val, nn_val = x_clone:get_one(i-1)
    assert(val)
    assert(type(val) == "Scalar")
    assert(val == Scalar.new(i*10, "I4"))
  end

  print("Successfully completed test t1")
end

return tests
