local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem    = require 'libcmem' ; 
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'

local buf = cmem.new(4096)
local M
local chunk_size = qconsts.chunk_size
local rslt

local infile = '_in1_I4.bin'
assert(plpath.isfile(infile), "Create the input files")
local y = Vector.new('I4', infile, false)
assert(y:start_write())
-- Second call to start_write should fail
print("START: Deliberate error attempt")
assert(y:start_write() == nil)
print("STOP : Deliberate error attempt")
s = Scalar.new(987654, "I4")
status = y:set(s, 0)
assert(status)
assert(y:end_write())
-- Second call to end_write should fail
print("START: Deliberate error attempt")
assert(y:end_write() == nil)
print("STOP: Deliberate error attempt")
-- Verify that write of 987654 took
ret_addr, ret_len = y:get_chunk(0)
ret_addr = ffi.cast("int32_t *", ret_addr)
assert(ret_addr[0] == 987654)
-- Now try to write without opening for write. Should fail
print("START: Deliberate error attempt")
status = y:set(s, 0)
print("STOP : Deliberate error attempt")
assert(not status)
--=========================
print("Completed ", arg[0])
-- os.execute("rm -f _*.bin")
os.exit()
