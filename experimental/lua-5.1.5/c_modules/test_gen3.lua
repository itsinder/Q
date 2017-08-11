local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local dbg    = require 'Q/UTILS/lua/debugger'
require 'Q/UTILS/lua/strict'
--===========================================
--====== Testing nascent vector with generator
status = os.execute("../../../UTILS/src/asc2bin in1_I4.csv I4 _in1_I4.bin")
assert(status)
print("Creating nascent vector with generator gen3")
local expander_gen3 = require 'expander_gen3'

local v1 = lVector( { qtype = "I4", file_name = "_in1_I4.bin"})
local gen3 = expander_gen3(v1, v1)

x = lVector( { qtype = "I4", gen = gen3, has_nulls = false})
local chunk_idx = 0
repeat
  local len, addr, nn_addr = x:get_chunk(chunk_idx)
  print("len/chunk_idx = ", len, chunk_idx)
  chunk_idx = chunk_idx + 1
until (len == 0)
print("Completed ", arg[0])
os.exit()
