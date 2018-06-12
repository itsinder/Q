-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local q_src_root = os.getenv("Q_SRC_ROOT")
local so_dir_path = q_src_root .. "/OPERATORS/UNIQUE/src/"

ffi.cdef([[
int unique(int32_t *in_buf, int in_size, int32_t *out_buf, int out_size, int *num_in_out);  
]])

-- NOTE: Need to run Q/OPERATORS/UNIQUE/src/run_unique.sh to create unique.so file
local qc = ffi.load(so_dir_path .. 'unique.so')

-- lua test to check the working of UNIQUE operator only for I4 qtype
local tests = {}
tests.t1 = function ()
  local expected_result = {1, 2, 3, 4, 5}
  
  local num_elements = 100
  local qtype = "I4"
  
  local input = Q.period( {start = 1, by = 1, len = num_elements, period = 5, qtype = qtype} ):eval()
  -- unique operator assumes that the input vector is sorted
  local input_col = Q.sort(input, "asc")

  local sz_out_in_bytes = num_elements * qconsts.qtypes[input:fldtype()].width
  local out_buf = assert(cmem.new(sz_out_in_bytes))

  local n_out = assert(get_ptr(cmem.new(ffi.sizeof("int"))))
  n_out = ffi.cast("int *", n_out)
      
  local a_len, a_chunk, a_nn_chunk = input:chunk(0)
  
  local casted_a_chunk = ffi.cast( "int32_t *",  get_ptr(a_chunk))
  local casted_out_buf = ffi.cast( "int32_t *",  get_ptr(out_buf))
  local status = qc["unique"](casted_a_chunk, a_len, casted_out_buf, a_len, n_out)
  
  assert(status)
  assert(tonumber(n_out[0]) == #expected_result)
  -- Validate the result
  out_buf = ffi.cast("int32_t *", casted_out_buf)
  for i = 1, tonumber(n_out[0]) do
    print(out_buf[i-1])
    assert(out_buf[i-1] == expected_result[i] )
  end
  
  print("Test t1 succeeded")
end

return tests
