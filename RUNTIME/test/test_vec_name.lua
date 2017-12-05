-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}

local lVector = require 'Q/RUNTIME/lua/lVector'
local Vector = require 'libvec' ; 

tests.t1 = function()
-- Set and get should match
  x = Vector.new('I4')
  vname = "abc"
  x:set_name(vname)
  assert(x:get_name() == vname)
end
--=========================
tests.t2 = function()
  -- cannot set more than 31 characters in name 
  x = Vector.new('I4')
  vname = "01234567890123456789012345678901"
  status = pcall(x.set_name, vname)
  assert(not status)
end
--=========================
tests.t3 = function()
  -- cannot have comma in name 
  x = Vector.new('I4')
  vname = "abc,def"
  status = pcall(x.set_name, vname)
  assert(not status)
end
--=========================
tests.t4 = function()
  -- test at lVector level
  x = Vector.new('I4')
  vname = "def"
  x = lVector( { qtype = "I4", gen = true})
  x:set_name(vname)
  assert(x:get_name() == vname)
end
--=========================
tests.t5 = function()
  -- test at lVector level during initiualization
  x = Vector.new('I4')
  vname = "def"
  x = lVector( { qtype = "I4", gen = true, name = vname} )
  assert(x:get_name() == vname)
end
--=========================
return tests
