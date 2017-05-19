local ffi = require "ffi"
local g_err = require 'error_code'
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local utils = require 'test_utils'
local q_src_root = os.getenv("Q_SRC_ROOT")
local q_root = os.getenv("Q_ROOT")
local q_core = require 'q_core'
assert(plpath.isdir(q_root))

-- To do - check whether ffi.cdef can be done in the same way,
-- as done in the q_core.lua. In this, q_core.h was included to
-- contain all the function declarations in one file q_core.h
local incfile = q_src_root .. "/OPERATORS/F1F2OPF3/gen_inc/_vvadd_I1_I1_I1.h"
assert(plpath.isfile(incfile))
ffi.cdef([[
int
vvadd_I1_I1_I1(
      const int8_t * restrict in1,  
      const int8_t * restrict in2,  
      uint64_t nR,  
      int8_t * restrict out 
      );
int
vvsub_I1_I1_I1(
      const int8_t * restrict in1,  
      const int8_t * restrict in2,  
      uint64_t nR,  
      int8_t * restrict out 
      );
int
vvmul_I1_I1_I1(
      const int8_t * restrict in1,  
      const int8_t * restrict in2,  
      uint64_t nR,  
      int8_t * restrict out 
      );
int
vvdiv_I1_I1_I1(
      const int8_t * restrict in1,  
      const int8_t * restrict in2,  
      uint64_t nR,  
      int8_t * restrict out 
      );
]])

-- same for so file. the below command can be done in one file
-- in the same way as q_core.lua
local sofile = q_root .. "/lib/libf1f2opf3.so"
assert(plpath.isfile(sofile))
local cee =  ffi.load(sofile)
  
-- input args are in the order below
-- operation like vvadd, vvsub etc.
-- qtype_output - qtype of output result
-- qtype_input1 - qtype of first input argument
-- qtype_input2 - qtype of second input argument
-- input1 - lua table of values
-- input2 - lua table of values

return function(operation, qtype_input1, qtype_input2, input1, input2, qtype)

  assert(g_qtypes[qtype], g_err.INVALID_QTYPE)
  assert(g_qtypes[qtype_input1], g_err.INVALID_QTYPE)
  assert(g_qtypes[qtype_input2], g_err.INVALID_QTYPE)
  assert(#input1 == #input2, g_err.LENGTH_NOT_EQUAL_ERROR)
  assert(#input1 > 0, g_err.INVALID_LENGTH)
  assert(#input2 > 0, g_err.INVALID_LENGTH)
  
  local chunk1 = assert(q_core.new(g_qtypes[qtype_input1].ctype .. "[?]", #input1, input1), g_err.FFI_NEW_ERROR)
  local chunk2 = assert(q_core.new(g_qtypes[qtype_input2].ctype .. "[?]", #input2, input2), g_err.FFI_NEW_ERROR)
  local chunk = assert(q_core.new(g_qtypes[qtype].ctype .. "[?]", #input1), g_err.FFI_NEW_ERROR)
  
  local convertor = operation .. "_" .. qtype_input1 .. "_" .. qtype_input2 .. "_" .. qtype
  -- convertor will be of the format -- e.g. - vvadd_I1_I1_I1
  print(convertor)
  assert(cee[convertor], g_err.CONVERTOR_FUNCTION_NULL)
  cee[convertor](chunk1, chunk2, #input1, chunk)
  local s = ""
  for i=1,#input1 do
      s = s .. tostring(chunk[i-1]) .. ","
  end
  return s
end

