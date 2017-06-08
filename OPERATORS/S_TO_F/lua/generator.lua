#!/usr/bin/env lua
local gen_code = require 'Q/UTILS/lua/gen_code'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"

local T = dofile 'const.tmpl'

local args = {}
qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

local const_specialize = require 'const_specialize'
args.val = 123 -- just to test const_specialize
args.len = 100 -- just to test const_specialize
for i, qtype in ipairs(qtypes) do 
  args.qtype = qtype
  status, subs, tmpl = pcall(const_specialize, args)
  assert(status, subs)
  gen_code.doth(subs, tmpl, incdir)
  gen_code.dotc(subs, tmpl, srcdir)
  print("produced ", subs.fn)
end
