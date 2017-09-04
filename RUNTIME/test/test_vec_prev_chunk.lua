local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local buf = cmem.new(4096)
local qconsts = require 'Q/UTILS/lua/q_consts'
-- for k, v in pairs(vec) do print(k, v) end 

local M
local is_memo
local chunk_size = qconsts.chunk_size
local rslt

--==============================================
-- Can get current chunk num but cannot get previous 
-- ret_len should be number of elements in chunk
s = Scalar.new(123, "I4")
orig_ret_addr = nil
num_iters = 1
if ( #arg == 1 ) then 
  num_iters = assert(tonumber(arg[1]))
  print("num_iters = ", num_iters)
end
for j = 1, num_iters do
  local y = Vector.new('I4')
  for i = 1, chunk_size do 
    status = y:put1(s)
    assert(status)
    ret_addr, ret_len = y:get_chunk(0);
    assert(ret_addr);
    assert(ret_len == i)
    if ( i == 1 ) then 
      orig_ret_addr = ret_addr
    else
      assert(ret_addr == orig_ret_addr)
    end
  end
  status = y:put1(s)
  ret_addr, ret_len = y:get_chunk(0);
  assert(ret_addr)
  assert(ret_len == chunk_size) -- can get previous chunk
  ret_addr, ret_len = y:get_chunk(1);
  assert(ret_len == 1)
  if ( ( j % 1000 ) == 0 )  then print("Iters ", j) end
end
