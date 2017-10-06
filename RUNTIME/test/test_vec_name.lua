-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local lVector = require 'Q/RUNTIME/lua/lVector'
local Vector = require 'libvec' ; 
x = Vector.new('I4')
--=========================
-- Set and get should match
vname = "abc"
x:set_name(vname)
assert(x:get_name() == vname)
--=========================
-- cannot set more than 31 characters in name 
vname = "01234567890123456789012345678901"
status = pcall(x.set_name, vname)
assert(not status)
--=========================
-- test at lVector level
vname = "def"
x = lVector( { qtype = "I4", gen = true})
x:set_name(vname)
assert(x:get_name() == vname)
--=========================
print("Completed ", arg[0])
os.execute("rm -f _*.bin")
os.exit()
