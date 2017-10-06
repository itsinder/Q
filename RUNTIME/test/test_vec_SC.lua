os.execute("rm -f _*.bin")
local ffi    = require 'Q/UTILS/lua/q_ffi'
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem   = require 'libcmem' ; 
require 'Q/UTILS/lua/strict'
local buf = cmem.new(4096)

local y
local M
local num_elements 
local s1, s2
ffi.copy(buf, "ABCD123")
-- create a nascent vector
y = assert(Vector.new('SC:8'))
num_elements = 10
for j = 1, num_elements do 
  assert(y:put1(buf))
end
y:eov()
y:persist()
assert(y:check())
M = loadstring(y:meta())(); 
command = "od -c -v " .. M.file_name .. " > _temp1.txt"
print(command)
os.execute(command)
s1 = plfile.read("_temp1.txt")
s2 = plfile.read("out_SC1.txt")
assert(s1 == s2)
--=========================
print("Testing SC Vector from file")
local infile = 'SC1.bin'
os.execute("cp " .. infile .. " _SC1.bin ")
infile = "_" .. infile
assert(plpath.isfile(infile), "Create the input files")
y = assert(Vector.new('SC:8', infile, false))
ret_addr, ret_len = y:get_chunk(0);
assert(ret_addr)
assert(ret_len == 10)

--=========================
print("Completed ", arg[0])
os.exit()
