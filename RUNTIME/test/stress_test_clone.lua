local Q		= require 'Q'
local lVector	= require 'Q/RUNTIME/lua/lVector'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local cmem      = require 'libcmem'
local ffi       = require 'Q/UTILS/lua/q_ffi'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'

local tests = {}
local niters = 100
--====== Testing with more than chunk size
tests.t1 = function()
  local num = 10
  local len = qconsts.chunk_size * 2 + 1
  local x = Q.const( {val = num, qtype = "I4", len = len })
  for i = 1, niters do y = Q.clone(x) end
  x:eval()
  for i = 1, niters do y = Q.clone(x) end
  print("Successfully completed test t1")
end
--====== Testing with less than chunk size 
tests.t2 = function()
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local len = qconsts.chunk_size - 1
  local field_size = 4
  local base_data = cmem.new(len * field_size)
  local iptr = get_ptr(base_data, "I4")
  for i = 1, len do
    iptr[i-1] = i*10
  end
  x:put_chunk(base_data, nil, len)
  for i = 1, niters do y = Q.clone(x) end
  x:eov()
  for i = 1, niters do y = Q.clone(x) end
  print("Successfully completed test t2")
end

return tests
