local ffi = require "ffi"
local g_err = require 'error_code'
local q = require 'q'
local q_core = require 'q_core'
local promote = require 'promote'
 
-- allocate chunk and prepare convertor function for calling C apis 
 local get_chunk = function(qtype_input1, qtype_input2, operation, ctype, input1)
  local chunk
  local convertor
  local length = #input1
  if ctype == "auto" then
    local qtype = promote(qtype_input1, qtype_input2)
    chunk = assert(q_core.new(g_qtypes[qtype].ctype .. "[?]", length), g_err.FFI_NEW_ERROR)
    convertor = operation .. "_" .. qtype_input1 .. "_" .. qtype_input2 .. "_" .. qtype
  else
    length = math.floor(length/ 64)
    if ((length * 64 ) ~= length) then length = length + 1 end
    --print("length = " ,length)
    chunk = assert(q_core.new("uint64_t[?]", length), g_err.FFI_NEW_ERROR)
    convertor = operation .. "_" .. qtype_input1 .. "_" .. qtype_input2
  end
  return chunk, length, convertor
end


 
-- Thin wrapper function on the top of C function ( vvadd_I1_I1_I1.c ) 
-- input args are in the order below
-- operation like vvadd, vvsub etc
-- qtype_input1 - qtype of first input argument
-- qtype_input2 - qtype of second input argument
-- input1 - lua table of values
-- input2 - lua table of values
-- qtype - qtype of output result



return function(operation, qtype_input1, qtype_input2, input1, input2, ctype)

  local chunk1 = assert(q_core.new(g_qtypes[qtype_input1].ctype .. "[?]", #input1, input1), g_err.FFI_NEW_ERROR)
  local chunk2 = assert(q_core.new(g_qtypes[qtype_input2].ctype .. "[?]", #input2, input2), g_err.FFI_NEW_ERROR)
  
  local chunk, length, convertor = get_chunk(qtype_input1, qtype_input2, operation, ctype, input1)
  
  -- convertor will be of the format -- e.g. - vvadd_I1_I1_I1
  --print(convertor)
  assert(q[convertor], g_err.CONVERTOR_FUNCTION_NULL)
  q[convertor](chunk1, chunk2, #input1, chunk)
  local ret = {}
  for i=1, length do
    table.insert(ret,chunk[i-1])
    --print(chunk[i-1])
  end
  return ret
end
