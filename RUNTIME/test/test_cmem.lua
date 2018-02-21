cmem = require 'libcmem' ; 
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
  -- basic test 
  local buf = cmem.new(128, "I4")
  assert(type(buf) == "CMEM")
  buf:set(65535, "I4")
  y = buf:to_str("I4")
  print(y)
  assert(y == "65535")
  print("test 1 passed")
end

tests.t2 = function()
  local buf = cmem.new(128)
  local num_trials = 10 -- 1024*1048576
  local sz = 65537
  for j = 1, num_trials do 
    local buf = cmem.new(sz, "I4", "inbuf")
    buf:set(j, "I4") -- for debugging
    -- print(buf, "I4")
    x = buf:to_str("I4")
    assert(j == tonumber(x))
    -- print(j, x)
    buf = nil
  end
  local num_elements = 1024
  local buf = cmem.new(num_elements * 4)
  local start = 123
  local incr  = 1
  buf:seq(start, incr, num_elements, "I4")
  x = buf:to_str("I4")
  assert(start == tonumber(x))
  -- check using FFI
  cbuf = ffi.cast("CMEM_REC_TYPE *", buf)
  iptr = ffi.cast("int *", cbuf[0].data)
  for i = 1, num_elements do
    assert(iptr[i-1] == start + (i-1) * incr)
  end
  --=======================
  print("test 2 passed")
end

tests.t3 = function()
  -- setting data using ffi and verifying using to_str()
  local buf = cmem.new(ffi.sizeof("int"))
  cbuf = ffi.cast("CMEM_REC_TYPE *", buf)
  ffi.C.strncpy(cbuf[0].field_type, "I4", 2)
  ffi.C.strncpy(cbuf[0].cell_name, "some bogus name", 15)
  iptr = ffi.cast("int *", cbuf[0].data)
  iptr[0] = 123456789;
  assert(type(buf) == "CMEM")
  y = buf:to_str("I4")
  assert(y == "123456789")
  assert(buf:fldtype() == "I4")
  assert(buf:name() == "some bogus name")
  print("test 3 passed")
end

tests.t4 = function()
  -- using set 
  local buf = cmem.new(ffi.sizeof("int"), "I4")
  buf:set(123456789)
  y = buf:to_str("I4")
  assert(y == "123456789")
  assert(buf:fldtype() == "I4")
  print("test t4 passed")
end


tests.t5 = function()

  -- test foreign functionality
  local size = 1024
  local qtype = "I4"
  local name = "some bigus name"
  local c1 = cmem.new(size, qtype, name)
  c1:set(123456789)

  local niters = 100000
  for i = 1, niters do 
    local iptr = c1:data()
    assert(type(iptr) == "userdata")
    local c2 = cmem.dupe(iptr, size, qtype, name)
    assert(c2:is_foreign() == true)
    c2:set(987654321)
  end
  assert(c1:to_str("I4") == "987654321")
  print("test t5 passed")
end

tests.t6 = function()
  -- test meta fucntionality
  local size = 1024
  local qtype = "I8"
  local name = "some bogus name"
  local c1 = assert(cmem.new(size, qtype, name))
  assert(c1:size() == size)
  assert(c1:fldtype() == qtype)
  assert(c1:name() == name)
  assert(c1:is_foreign() == false)
  print("test t6 passed")
end

tests.t7 = function()
  -- test SC
  local gval = {}
  gval[0] = "1234567";
  gval[1] = "123.567";
  gval[2] = ""
  gval[3] = " abcd "
  local size = 8
  local qtype = "SC"
  local name = "some bogus name"
  for k, v in ipairs(gval) do 
  local c1 = assert(cmem.new(size, qtype, name))
    c1:set(v)
    y = c1:to_str("I4")
    print(y)
    assert(y == v)
  end
  print("test t7 passed")
end
  
return tests
