local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local qconsts = require 'Q/UTILS/lua/q_consts'
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
  local buf = cmem.new(4096)
  local M
  local is_memo
  local chunk_size = qconsts.chunk_size
  local rslt

  --==============================================
  -- Can get current chunk num but cannot get previous 
  -- ret_len should be number of elements in chunk
  local s = Scalar.new(123, "I4")
  local orig_ret_addr = nil
  local num_iters = 1 -- default value 
  
  print("num_iters = ", num_iters)

  for j = 1, num_iters do
    local y = Vector.new('I4')
    for i = 1, chunk_size do 
      local status = y:put1(s)
      assert(status)
      local ret_cmem, ret_len = y:get_chunk(0);
      assert(ret_cmem);
      assert(type(ret_cmem) == "CMEM")
      assert(ret_len == i)
      if ( i == 1 ) then 
        local cbuf = ffi.cast("CMEM_REC_TYPE *", ret_cmem)
        orig_ret_addr = ffi.cast("int *", cbuf[0].data)
      else
        local cbuf = ffi.cast("CMEM_REC_TYPE *", ret_cmem)
        local ret_addr = ffi.cast("int *", cbuf[0].data)
        assert(ret_addr == orig_ret_addr)
      end
    end
    print("XXXXXXXXXXXX j = ", j)
    local status = y:put1(s)
    assert(status)
    local ret_addr, ret_len = y:get_chunk(0);
    assert(ret_addr)
    assert(type(ret_addr) == "CMEM")
    assert(ret_len == chunk_size) -- can get previous chunk
    ret_addr, ret_len = y:get_chunk(1);
    assert(ret_len == 1)
    if ( ( j % 1000 ) == 0 )  then print("Iters ", j) end
  end
  print("Completed test t1")
end
return tests
