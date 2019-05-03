local plpath = require 'pl.path'
local lDictionary = require 'Q/RUNTIME/lua/lDictionary'
local qconsts    = require 'Q/UTILS/lua/q_consts'
local qc         = require 'Q/UTILS/lua/q_core'
require 'Q/UTILS/lua/strict'

local tests = {} 
--
tests.t1 = function()
  local fmap = {}
  fmap[1] = "abc"
  fmap[2] = "def"
  fmap[3] = "ghi"
  local D = lDictionary(fmap)
  assert(D:check())
  D:pr("reverse")
  D:pr("forward")
  print("Successfully completed test t1")
end
tests.t2 = function()
  local fmap = {}
  fmap[1] = "abc"
  fmap[2] = "def"
  fmap[3] = "ghi"
  fmap[4] = "ghi"
  local status, msg = pcall(lDictionary, fmap)
  assert(not status)
  print("Successfully completed test t2")
end
return tests
