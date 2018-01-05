local ffi    = require 'Q/UTILS/lua/q_ffi'
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem   = require 'libcmem' ; 
require 'Q/UTILS/lua/strict'
local buf = cmem.new(4096)

local tests = {} 

tests.t1 = function()
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
  local command = "od -c -v " .. M.file_name .. " > _temp1.txt"
  print(command)
  os.execute(command)
  s1 = plfile.read("_temp1.txt")
  s2 = plfile.read("out_SC2.txt")
  assert(s1 == s2)
  --=========================
  print("Testing SC Vector from file")
  local infile = 'SC2.bin'
  assert(plpath.isfile(infile), "Create the input files")
  y = assert(Vector.new('SC:8', infile, false))
  local ret_addr, ret_len = y:get_chunk(0);
  assert(ret_addr)
  assert(ret_len == 10)
  print("Successfully completed test t1")
end
--=========================
return tests
