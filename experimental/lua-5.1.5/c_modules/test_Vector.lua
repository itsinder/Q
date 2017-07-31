local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local lVector = require 'lVector';
--=========================
--
x = lVector(
{ qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin"})
assert(x:check())

x = lVector( { qtype = "I4", file_name = "_in1_I4.bin"})
assert(x:check())
n = x:num_elements()
assert(n == 10)

print("Completed ", arg[0])
os.exit()
