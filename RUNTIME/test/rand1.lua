local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local rand_qtype = require 'rand_qtype'
require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/lua/lVector'
math.randomseed(os.time())

local xtype = rand_qtype()
local x = lVector( { qtype = xtype, gen = true, has_nulls = false})
local base_data = cmem.new(1024)
ffi.fill(base_data, 1024)
local ctype = qconsts.qtypes[xtype].ctype
local vptr = ffi.cast(ctype .. " * ", base_data)
local counter = 0
local num_trials = 100000
for i = 1, num_trials do
  local qtype = rand_qtype()
  local s1 = Scalar.new(i % 127, qtype)
  if ( qtype == xtype ) then counter = counter + 1 end
  pcall(x.put1, x, s1)
  -- Note that it is okay for the pcall to fail
  -- x:put1(s1)
  assert(x:check())
end
x:eov()
assert(x:check())
assert(x:num_elements() == counter)
print("DONE")
