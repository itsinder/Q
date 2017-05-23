local ffi = require "ffi"
local g_err = require 'error_code'
local q = require 'q'
local q_core = require 'q_core'
  
-- input args are in the order below
-- operation like vvadd, vvsub etc
-- qtype_input1 - qtype of first input argument
-- qtype_input2 - qtype of second input argument
-- input1 - lua table of values
-- input2 - lua table of values
-- qtype - qtype of output result

return function(operation, qtype_input1, qtype_input2, input1, input2, qtype)

  local chunk1 = assert(q_core.new(g_qtypes[qtype_input1].ctype .. "[?]", #input1, input1), g_err.FFI_NEW_ERROR)
  local chunk2 = assert(q_core.new(g_qtypes[qtype_input2].ctype .. "[?]", #input2, input2), g_err.FFI_NEW_ERROR)
  
  local chunk
  local convertor 
  
  if qtype == 0 then
    chunk = assert(q_core.new("uint64_t[?]", #input1), g_err.FFI_NEW_ERROR)
    convertor = operation .. "_" .. qtype_input1 .. "_" .. qtype_input2
  else
    chunk = assert(q_core.new(g_qtypes[qtype].ctype .. "[?]", #input1), g_err.FFI_NEW_ERROR)
    convertor = operation .. "_" .. qtype_input1 .. "_" .. qtype_input2 .. "_" .. qtype
  end
  
  -- convertor will be of the format -- e.g. - vvadd_I1_I1_I1
  print(convertor)
  assert(q[convertor], g_err.CONVERTOR_FUNCTION_NULL)
  q[convertor](chunk1, chunk2, #input1, chunk)
  local ret = {}
  for i=1,#input1 do
    table.insert(ret,chunk[i-1])
    --print(chunk[i-1])
  end
  return ret
end

