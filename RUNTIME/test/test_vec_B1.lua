local cmem = require 'libcmem'
local lVector = require 'Q/RUNTIME/lua/lVector'
local ffi = require 'Q/UTILS/lua/q_ffi'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
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

tests.t1 = function()
  local vec_len = 65535
  local b1_virtual_len = math.ceil(vec_len / 8)
  local buf = cmem.new(b1_virtual_len, "I1", "buffer")
  local buf2 = ffi.cast("CMEM_REC_TYPE *", buf)
  local buf3 = ffi.cast("int8_t *", buf2[0].data)

  for i = 1, b1_virtual_len do
    buf3[i-1] = 85
  end

  -- Create B1 Vector
  local b1_vec = lVector({qtype = "B1", gen = true, has_nulls = false})
  b1_vec:put_chunk(buf, nil, vec_len)
  for i = 1, b1_virtual_len do
    buf_copy[i-1] = 255
  end
  b1_vec:put_chunk(buf, nil, 4)
  b1_vec:eov()

  for i = 1, vec_len do
    local exp_val
    if i % 2 == 1 then
      exp_val = 1
    else
      exp_val = 0
    end

    local val, nn_val = c_to_txt(b1_vec, i)
    if not val then val = 0 end
    assert(val == exp_val, "Mismatch, Expected = " .. tostring(exp_val) .. ", Actual = " .. tostring(val))
  end

  for i = 1, 4 do
    local exp_val = 1

    local val, nn_val = c_to_txt(b1_vec, i + vec_len)
    if not val then val = 0 end
    assert(val == exp_val, "Mismatch, Expected = " .. tostring(exp_val) .. ", Actual = " .. tostring(val))
  end

  --[[
  for i = 1, b1_vec:num_elements() do
    local val, nn_val = c_to_txt(b1_vec, i)
    if not val then val = 0 end
    print(i, val)
  end
  ]]
  print("COMPLETED")
end

return tests
