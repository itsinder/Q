local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
require 'Q/UTILS/lua/strict'
local q_data_dir = os.getenv("Q_DATA_DIR")
q_data_dir = q_data_dir .. "/"

local tests = {} 
tests.t1 = function()
  -- tests that memory is zero after Vector created, non-zeor after 
  -- put happens and zero again after Vector is deleted
  local mem = 0
  local y = Vector.new('I4', q_data_dir)
  local s = Scalar.new(123, "I4")
  io.output("_temp.txt")
  mem = Vector.print_mem()
  assert(mem == 0)
  local status = y:put1(s)
  mem = Vector.print_mem()
  assert(mem > 0)
  status = y:eov(true)
  y:delete()
  mem = Vector.print_mem()
  assert(mem == 0)
  print("Successfully completed test t1")
end
--==============================================
return tests
